unit ProcessThread;

interface
uses Windows, Classes, Math, SyncObjs, Graphics, Chart, Series,
StdCtrls, SysUtils, ltr24api, ltr34api, ltrapi, WriterThread, Config;

type TProcessThread = class(TThread)
  public
    //элементы управлени€ дл€ отображени€ результатов обработки
    visChAvg : array [0..LTR24_CHANNEL_NUM-1] of TChart;
    ShowSignal: TCheckBox;
    WriterThread : TWriter;
    debugFile:TextFile;
    MilisecsToWork:  Int64;
    MilisecsProcessed:  Int64;
    phltr34: pTLTR34;
    phltr24: pTLTR24; //указатель на описатель модул€
    bnStart:  TButton;
    skipAmount: integer;
    WindowPercent: integer;
    PrevHistoryIndex: Integer;

    path:string;
    frequency:string;

    doUseCalibration:boolean;
    err : Integer; //код ошибки при выполнении потока сбора
    stop : Boolean; //запрос на останов (устанавливаетс€ из основного потока)

    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    { Private declarations }
    // признак, что есть вычесленные данные по каналам в ChAvg
    ChValidData : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
    AccelerationSign: array [0..LTR24_CHANNEL_NUM-1] of Integer;
    OptimalDACSignal , LastCalibrateSignal, OptimalPoint: array [0..LTR24_CHANNEL_NUM-1] of DOUBLE;
    data     : array of Double;    //обработанные данные
    calibration_signal_step: double;
    DevicesAmount   : Integer;  //количество разрешенных каналов
    ChannelPackageSize : Integer;
    History: THistory;
    HistoryIndex, HistoryPage : Integer;
    historyPagesAmount : Integer;
    amplitude: Double;

    //YWindowVariables
    YWindowMax, YWindowMin: Double;
    Median: array [0..DevicesAmount-1, 0..MedianDeep-1] of Double;
    CurrentMedianIndex : array [0..DevicesAmount-1] of Integer;

    procedure NextTick();
    procedure ParseChannelsData;
    procedure sendDAC(channel: Integer; signal: Double);
    procedure CalibrateData(deviceNumber: Integer);
    procedure doWorkPointShift(deviceNumber: Integer);
    function GetLowFreq(deviceNumber: Integer) : Double;
    procedure RecalculateOptimumPoint(deviceNumber: Integer);
    procedure doBigSignal(deviceNumber: Integer);
    procedure DryData(wetData: array of LongWord; out dryData: array of Double);
   protected
    procedure Execute; override;
  end;
implementation

  constructor TProcessThread.Create(SuspendCreate : Boolean);
  var i:integer;
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     err:=LTR_OK;

     for i := 0 to DAC_packSize - 1 do
      LastCalibrateSignal[i]:=0;
  end;

  destructor TProcessThread.Free();
  begin
      Inherited Free();
  end;

  procedure TProcessThread.sendDAC(channel: Integer; signal: Double);
  var
    i: integer;
    DATA:array[0..DAC_packSize-1] of Double;
    WORD_DATA:array[0..DAC_packSize-1] of Double;
    ph: pTLTR34;
  begin
    LastCalibrateSignal[channel]:= signal;

    for i := 0 to DAC_packSize - 1 do
      DATA[i]:= LastCalibrateSignal[i];

    ph:= phltr34;
    LTR34_ProcessData(ph,@DATA,@WORD_DATA, ph.ChannelQnt, 0); //1- указываем что значени€ в ¬ольтах
    LTR34_Send(ph,@WORD_DATA, ph.ChannelQnt, DAC_possible_delay);
  end;

  procedure TProcessThread.DryData(wetData: array of LongWord; out dryData: array of Double);
  var
     i, b, c,  size: integer;
     bitMask, newValue: LongWord;

  begin
    size := Length(wetData);

    for i:=0 to size-1 do begin
      c := 0;
      newValue := 0;
      for b:=16 to 31 do begin
        bitMask := 1 shl b;
        newValue := newValue or (bitMask and wetData[i]);
      end;

      newValue := newValue shr 16;

      for b:=0 to 3 do begin
        bitMask := 1 shl b;
        newValue := newValue or ((bitMask and wetData[i]) shl 16);
      end;
      dryData[i] :=  newValue;
    end;

  end;

  procedure TProcessThread.Execute;
  var
    stoperr,i : Integer;
    rcv_buf  : array of LongWord;  //сырые прин€тые слова от модул€

    ch, steps_amount       : Integer;

    recv_wrd_cnt : Integer;  //количество принимаемых сырых слов за раз
    recv_data_cnt : Integer; //количество обработанных слов, которые должны прин€ть за раз
    // номера разрешенных каналов
    ch_nums  : array [0..LTR24_CHANNEL_NUM-1] of Byte;
    // временные переменные дл€ вычислени€. в конце обновл€ютс€ уже пол€
    // класса - ChAvg и ChDataValid
    ch_avg   : array [0..LTR24_CHANNEL_NUM-1] of Double;
    ch_valid : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
  begin
    //обнул€ем переменные
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
      ChValidData[ch]:=False;

    System.Assign(debugFile, 'D:\debug.txt');
    ReWrite(debugFile);

    //ѕровер€ем, сколько и какие каналы разрешены
    DevicesAmount := 0;
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
    begin
      if phltr24^.ChannelMode[ch].Enable then
      begin
        ch_nums[DevicesAmount] := ch;
        DevicesAmount := DevicesAmount+1;
      end;
    end;

    { ќпредел€ем, сколко преобразований будет выполненно за заданное врем€
      => будем принимать данные блоками такого размера }
    recv_data_cnt:=  Round(phltr24^.ADCFreq*ADC_reading_time/1000) * DevicesAmount;
    { ¬ 24-битном формате каждому отсчету соответствует два слова от модул€,
                   а в 20-битном - одно }
    if phltr24^.DataFmt = LTR24_FORMAT_24 then
      recv_wrd_cnt :=  2*recv_data_cnt
    else
      recv_wrd_cnt :=  recv_data_cnt;

    { выдел€ем массивы дл€ приема данных }
    SetLength(rcv_buf, recv_wrd_cnt);
    SetLength(data, recv_data_cnt);

    DAC_max_signal := VoltToCode(DAC_max_VOLT_signal);
    DAC_min_signal := VoltToCode(DAC_min_VOLT_signal);

    historyPagesAmount :=   Trunc((recv_data_cnt*InnerBufferPagesAmount)/DevicesAmount);

    steps_amount :=  Trunc(CalibrateMiliSecondsCut/ADC_reading_time);
    calibration_signal_step := (DAC_max_signal-DAC_min_signal)/steps_amount;
    for i := 0 to ChannelsAmount - 1 do begin
       SetLength(History[i], historyPagesAmount);
    end;
    err:= LTR24_Start(phltr24^);

    WriterThread := TWriter.Create(path, frequency, skipAmount, True);
    WriterThread.Priority := tpHighest;
    WriterThread.History := @History;

    if err = LTR_OK then
    begin
      while not stop and (err = LTR_OK) do
      begin
        { ѕринимаем данные (здесь используетс€ вариант без синхрометок, но есть
          и перегруженна€ функци€ с ними) }
        ChannelPackageSize := LTR24_Recv(phltr24^, rcv_buf, recv_wrd_cnt, ADC_possible_delay + ADC_reading_time);
        MilisecsProcessed := MilisecsProcessed +  ADC_reading_time;

        if MilisecsProcessed > MilisecsToWork then
          stop := true;

        //«начение меньше нул€ соответствуют коду ошибки
        if ChannelPackageSize < 0 then
          err:=ChannelPackageSize
        else  if ChannelPackageSize < recv_wrd_cnt then
          err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
        else
        begin
          err:=LTR24_ProcessData(phltr24^, rcv_buf, data, ChannelPackageSize, LTR24_PROC_FLAG_VOLT);
          //DryData(rcv_buf, data);
          if err=LTR_OK then
          begin
            for ch:=0 to LTR24_CHANNEL_NUM-1 do
            begin
              ch_avg[ch] :=  0;
              ch_valid[ch] := False;
            end;

            // получаем кол-во отсчетов на канал
            ChannelPackageSize := Trunc(ChannelPackageSize/DevicesAmount);
            for ch:=0 to DevicesAmount-1 do
            begin
              ChValidData[ch] := True;
            end;

            NextTick();
          end;
        end;

      end; //while not stop and (err = LTR_OK) do

      NextTick();

      visChAvg[0].Series[0].Clear();
      visChAvg[1].Series[0].Clear();

      HistoryIndex:= HistoryPage*ChannelPackageSize;

      for ch:=0 to DevicesAmount-1 do
          for i := HistoryIndex to Length(History[0])-1 do
             History[ch, i] := 0;

      WriterThread.Save();

      WriterThread.Terminate();

      { ѕо выходу из цикла отсанавливаем сбор данных.
        „тобы не сбросить код ошибки (если вышли по ошибке)
        результат останова сохран€ем в отдельную переменную }

      stoperr:= LTR24_Stop(phltr24^);
      if err = LTR_OK then
        err:= stoperr;

    end;
    CloseFile(debugFile);

    bnStart.Caption := '—тарт';
  end;


  function TProcessThread.GetLowFreq(deviceNumber: Integer) : Double;
  var i: Integer;
  aver,startValue, dif, memory : Double;

  begin
     startValue:=History[deviceNumber, HistoryIndex];
     aver:=0;
     for i := 0 to ChannelPackageSize-1 do begin
        aver:=aver+History[deviceNumber, HistoryIndex+i];
     end;

        Median[deviceNumber, CurrentMedianIndex[deviceNumber]]:=aver/ChannelPackageSize;

        memory:= 0;
        for i := 0 to MedianDeep-1 do begin
           if (i<>CurrentMedianIndex[deviceNumber]) then
             memory:=memory+Median[deviceNumber, i];
        end;

        if MedianDeep>1 then memory:=memory/(MedianDeep-1)
        else memory:= Median[deviceNumber, CurrentMedianIndex[deviceNumber]];

        //dif:= Median[deviceNumber, CurrentMedianIndex[deviceNumber]]-memory;
        //if Abs(dif)> amplitude*0.4 then
        //    Median[deviceNumber, CurrentMedianIndex[deviceNumber]] :=
        //       memory+ Sign(dif)*amplitude*0.4;//;

        //GetLowFreq:= Median[deviceNumber, CurrentMedianIndex[deviceNumber]];

        GetLowFreq:=  memory;

     CurrentMedianIndex[deviceNumber]:=CurrentMedianIndex[deviceNumber]+1;
     if (CurrentMedianIndex[deviceNumber] = MedianDeep) then CurrentMedianIndex[deviceNumber]:=0;

  end;

  procedure TProcessThread.doWorkPointShift(deviceNumber: Integer);
  var
    Shift, newCalibrateSignal: Double;
  begin
    newCalibrateSignal := GetLowFreq(deviceNumber);
    Shift := 0;
    Shift := OptimalPoint[deviceNumber] - newCalibrateSignal;

    writeln(debugFile, FloatToStr(Shift));

    if ((newCalibrateSignal > YWindowMin) and (newCalibrateSignal < YWindowMax)) then exit;

    Shift :=  Shift * AccelerationSign[deviceNumber]*0.01;
    Shift := VoltToCode(Shift);
    newCalibrateSignal := LastCalibrateSignal[deviceNumber] + Shift;

    if newCalibrateSignal > DAC_max_signal then
     newCalibrateSignal := newCalibrateSignal - VoltToCode(VoltResetByDevice[deviceNumber]);
    if newCalibrateSignal < DAC_min_signal then
      newCalibrateSignal := newCalibrateSignal + VoltToCode(VoltResetByDevice[deviceNumber]);

    SendDAC(deviceNumber, newCalibrateSignal);

  end;

  Procedure TProcessThread.RecalculateOptimumPoint(deviceNumber: Integer);
  var i: integer;
    indexMin,indexMax:longint;
    OpHistoryPage, OpHistoryIndex: longint ;
    BefPageSignal, SignalStepByIndex, PageSignalChange: single;
    valueMax,valueMin, CalibrationEndIndex: Double;
  begin
    valueMin := History[0,0] ; valueMax := History[0,0] ;
    indexMin := 0; indexMax := 0;

    for i := 0 to Length(History[deviceNumber])-1 do begin
    if (History[deviceNumber,i] = 0) then break;

      if valueMin >= History[deviceNumber,i] then begin
        valueMin := History[deviceNumber,i];
        indexMin := i;
      end;
      if valueMax <= History[deviceNumber,i] then begin
        valueMax := History[deviceNumber,i];
        indexMax := i;
      end;
    end;
    OptimalPoint[deviceNumber] := (valueMax+valueMin)/2;     //оптим положение раб точки

    amplitude := (valueMax-valueMin)*WindowPercent*0.005;
    YWindowMin:= OptimalPoint[deviceNumber] - amplitude;
    YWindowMax:= OptimalPoint[deviceNumber] + amplitude;

    Log('OptVal: ' + FloatToStr(OptimalPoint[deviceNumber]));

    if indexMax > indexMin then
      AccelerationSign[deviceNumber]:= 1
    else
      AccelerationSign[deviceNumber]:= -1;

    //DAC signal calculating
    CalibrationEndIndex:= 26000;
    calibration_signal_step:= DAC_max_VOLT_signal/CalibrationEndIndex;

    OpHistoryIndex := Round((indexMax+indexMin)/2);

    OptimalDACSignal[deviceNumber] :=  VoltToCode(OpHistoryIndex*calibration_signal_step);
    Log('Dac: ' + FloatToStr(OpHistoryIndex*calibration_signal_step));

    SendDAC(deviceNumber, OptimalDACSignal[deviceNumber]);
  end;

  procedure TProcessThread.doBigSignal(deviceNumber: Integer);
  begin
      EnterCriticalSection(DACSection);
      sendDAC(deviceNumber, LastCalibrateSignal[deviceNumber]+calibration_signal_step);
      LeaveCriticalSection(DACSection);
  end;

  procedure TProcessThread.CalibrateData(deviceNumber: Integer);
  begin
    if MilisecsProcessed = CalibrateMiliSecondsCut then begin
      RecalculateOptimumPoint(deviceNumber);

      Log(IntToStr(HistoryIndex));
    end else
    if MilisecsProcessed > CalibrateMiliSecondsCut then begin
      doWorkPointShift(deviceNumber);
    end;
  end;

  procedure TProcessThread.ParseChannelsData;
  var
    ch: Integer;
    i: Integer;
    IndexShift: Integer;
  begin
    if visChAvg[0].Series[0].Count = 0 then begin
      for i := 0 to ChannelPackageSize-1 do begin
        visChAvg[0].Series[0].Add(0);
        visChAvg[1].Series[0].Add(0);
      end;
    end;

  EnterCriticalSection(HistorySection);
    for ch:=0 to LTR24_CHANNEL_NUM-1 do begin
      if ChValidData[ch] then begin
        for i := 0 to ChannelPackageSize-1 do begin
          IndexShift := DevicesAmount*i + ch;
          History[ch, HistoryIndex+i] := data[IndexShift];

          if ShowSignal.Checked then
            visChAvg[ch].Series[0].YValue[i] := data[IndexShift];
        end;
      end;
    end;
  LeaveCriticalSection(HistorySection);
  end;

  procedure TProcessThread.NextTick();
  var i:Integer;
  begin
    if HistoryPage >= InnerBufferPagesAmount then begin
      WriterThread.Save();
      HistoryPage := 0;
    end;

    HistoryIndex:= HistoryPage*ChannelPackageSize;

    ParseChannelsData;

    if doUseCalibration then  begin
      for i := 0 to DevicesAmount - 1 do
        CalibrateData(i);
    end;

    HistoryPage:= HistoryPage+1;
  end;

end.

