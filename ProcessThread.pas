unit ProcessThread;

interface
uses Classes, Math, SyncObjs, Graphics, Chart, Series,
StdCtrls, SysUtils, ltr24api, ltr34api, ltrapi, DACThread, Config;

type TProcessThread = class(TThread)
  public
    //элементы управления для отображения результатов обработки
    visChAvg : array [0..LTR24_CHANNEL_NUM-1] of TChart;
    DACthread : TDACThread; //Объект потока для выполнения сбора данных
    MilisecsToWork:  Int64;
    MilisecsProcessed:  Int64;
    phltr34: pTLTR34;
    phltr24: pTLTR24; //указатель на описатель модуля
    bnStart:  TButton;
    doUseCalibration:boolean;
    err : Integer; //код ошибки при выполнении потока сбора
    stop : Boolean; //запрос на останов (устанавливается из основного потока)
    Files : array of TextFile;
    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    { Private declarations }
    // признак, что есть вычесленные данные по каналам в ChAvg
    ChValidData : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
    data     : array of Double;    //обработанные данные
    DevicesAmount   : Integer;  //количество разрешенных каналов
    ChannelPackageSize : Integer;
    ChannelData: array of array of integer; //массивы одного буфера разложенного по каналам
    Cycle, AccelerationSign, OptimalPoint, OptimalDACSignal, Period, LastCalibrateSignal : Integer;

    procedure sendDAC(signal: Integer);
    {
    procedure SaveChannelsData;
    procedure NextTick();
    procedure SaveBigSignalData(deviceNumber: Integer; cycle: Integer);
    procedure doWorkPointShift(deviceNumber: Integer);
    procedure CalibrateData(deviceNumber: Integer; cycle: Integer);
    procedure RecalculateOptimumPoint(deviceNumber: Integer);
    procedure doBigSignal(deviceNumber: Integer; Cycle: Integer);
    procedure ParseChannelsData;                             //}
  protected
    procedure Execute; override;
  end;
implementation


  constructor TProcessThread.Create(SuspendCreate : Boolean);
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     err:=LTR_OK;
  end;

  destructor TProcessThread.Free();
  begin
      if DACthread <> nil then
        FreeAndNil(DACthread);
      Inherited Free();
  end;

  procedure TProcessThread.sendDAC(signal: Integer);
  begin
    DACthread.send(0,signal);

    //LastCalibrateSignal[deviceNumber]:= signal;
  end;


  procedure TProcessThread.Execute;
  type WordArray = array[0..0] of LongWord;
  type PWordArray = ^WordArray;
  var
    stoperr,i,test : Integer;
    rcv_buf  : array of LongWord;  //сырые принятые слова от модуля

    ch       : Integer;

    recv_wrd_cnt : Integer;  //количество принимаемых сырых слов за раз
    recv_data_cnt : Integer; //количество обработанных слов, которые должны принять за раз
    // номера разрешенных каналов
    ch_nums  : array [0..LTR24_CHANNEL_NUM-1] of Byte;
    // временные переменные для вычисления. в конце обновляются уже поля
    // класса - ChAvg и ChDataValid
    ch_avg   : array [0..LTR24_CHANNEL_NUM-1] of Double;
    ch_valid : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
  begin
    //обнуляем переменные
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
      ChValidData[ch]:=False;
    Cycle:=0;
    //Проверяем, сколько и какие каналы разрешены
    DevicesAmount := 0;
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
    begin
      if phltr24^.ChannelMode[ch].Enable then
      begin
        ch_nums[DevicesAmount] := ch;
        DevicesAmount := DevicesAmount+1;
      end;
    end;

    { Определяем, сколко преобразований будет выполненно за заданное время
      => будем принимать данные блоками такого размера }
    recv_data_cnt:=  Round(phltr24^.ADCFreq*ADC_reading_time/1000) * DevicesAmount;
    { В 24-битном формате каждому отсчету соответствует два слова от модуля,
                   а в 20-битном - одно }
    if phltr24^.DataFmt = LTR24_FORMAT_24 then
      recv_wrd_cnt :=  2*recv_data_cnt
    else
      recv_wrd_cnt :=  recv_data_cnt;

    { выделяем массивы для приема данных }
    SetLength(rcv_buf, recv_wrd_cnt);
    SetLength(data, recv_data_cnt);
    err:= LTR24_Start(phltr24^);
    err:=LTR34_DACStart(phltr34);

    if doUseCalibration then begin
      DACthread := TDACThread.Create(phltr34, True);
      DACthread.Resume;
    end;

    if err = LTR_OK then
    begin
      while not stop and (err = LTR_OK) do
      begin
        { Принимаем данные (здесь используется вариант без синхрометок, но есть
          и перегруженная функция с ними) }
        ChannelPackageSize := LTR24_Recv(phltr24^, rcv_buf, recv_wrd_cnt, ADC_possible_delay + ADC_reading_time);
        MilisecsProcessed := MilisecsProcessed +  ADC_reading_time;

        if MilisecsProcessed > MilisecsToWork then
          stop := true;

        //Значение меньше нуля соответствуют коду ошибки
        if ChannelPackageSize < 0 then
          err:=ChannelPackageSize
        else  if ChannelPackageSize < recv_wrd_cnt then
          err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
        else
        begin
          err:=LTR24_ProcessData(phltr24^, rcv_buf, data, ChannelPackageSize,
                                  LTR24_PROC_FLAG_CALIBR or
                                  LTR24_PROC_FLAG_VOLT or
                                  LTR24_PROC_FLAG_AFC_COR);
          if err=LTR_OK then
          begin
            for ch:=0 to LTR24_CHANNEL_NUM-1 do
            begin
              ch_avg[ch] :=  0;
              ch_valid[ch] := False;
            end;

            // получаем кол-во отсчетов на канал
            ChannelPackageSize := Trunc(ChannelPackageSize/DevicesAmount) ;
            for ch:=0 to DevicesAmount-1 do
            begin
              ChValidData[ch] := True;
            end;

            //SendDAC(0);
            //NextTick();
          end;
        end;

      end; //while not stop and (err = LTR_OK) do

      visChAvg[0].Series[0].Clear();
      visChAvg[1].Series[0].Clear();

      for i := 0 to DevicesAmount-1 do
        CloseFile(Files[i]);

      { По выходу из цикла отсанавливаем сбор данных.
        Чтобы не сбросить код ошибки (если вышли по ошибке)
        результат останова сохраняем в отдельную переменную }

      stoperr:= LTR24_Stop(phltr24^);
      if err = LTR_OK then
        err:= stoperr;

    end;
    if doUseCalibration then
       DACthread.stopThread();

    bnStart.Caption := 'Старт';
  end;
   {
  procedure TProcessThread.doWorkPointShift(deviceNumber: Integer);
  var
    Shift, newCalibrateSignal: Integer;
  begin
    Shift := OptimalPoint[deviceNumber] - ChannelData[deviceNumber*ChannelsPerDevice+LOW_FREQ_CHANNEL, ChannelPackageSize];
    Shift := Round(Shift * AccelerationSign[deviceNumber] * 0.1);
    newCalibrateSignal := LastCalibrateSignal[deviceNumber] + Shift;

    if newCalibrateSignal > 1400 then
      newCalibrateSignal := newCalibrateSignal - (2 * Period[deviceNumber]);
    if newCalibrateSignal < 1 then
      newCalibrateSignal := newCalibrateSignal + (2 * Period[deviceNumber]);

    SendDAC(deviceNumber, newCalibrateSignal);
  end;

  procedure TProcessThread.SaveBigSignalData(deviceNumber: Integer; cycle: Integer);
  var
    indexShift: Integer;
    i: Integer;
  begin
  indexShift := cycle * ChannelPackageSize;
  for i := 1 to ChannelPackageSize do
    BigSignal[deviceNumber, indexShift + i] :=
      ChannelData[deviceNumber*ChannelsPerDevice+NATIVE_CHANNEL, i];
  end;

  Procedure TProcessThread.RecalculateOptimumPoint(deviceNumber: Integer);
  var i: integer;
    AmplitudeWidth,indexMin,indexMax:integer;
    valueMax,valueMin:Short;
  begin
    valueMin := 14000; valueMax := -14000;
    indexMin := 0; indexMax := 0;

    for i := 20 to Length(BigSignal[deviceNumber])-1 do begin
      if valueMin >= BigSignal[deviceNumber,i] then begin
        valueMin := BigSignal[deviceNumber,i];
        indexMin := i;
      end;
      if valueMax <= BigSignal[deviceNumber,i] then begin
        valueMax := BigSignal[deviceNumber,i];
        indexMax := i;
      end;
    end;
    OptimalPoint[deviceNumber] := Ceil((valueMax+valueMin)/2);     //оптим положение раб точки
    AmplitudeWidth := Round((indexMax+indexMin)/2);
    if indexMax > indexMin then
      AccelerationSign[deviceNumber]:= 1
    else
      AccelerationSign[deviceNumber]:= -1;

    if (DeviceNumber=1) then
        AccelerationSign[deviceNumber]:= AccelerationSign[deviceNumber]*(-1);

    Period[0]:= 383; //383 Round((BigSignal[deviceNumber,indexMax]-BigSignal[deviceNumber,indexMin])*AccelerationSign[deviceNumber]/2.45);
    Period[1]:= 433; //433

    OptimalDACSignal[deviceNumber] := Round(BigSignalStep*(indexMax+indexMin)/ChannelPackageSize/2);
    SendDAC(deviceNumber, OptimalDACSignal[deviceNumber]);

  end;

  procedure TProcessThread.CalibrateData(deviceNumber: Integer; cycle: Integer);
  begin
    if cycle < BlockAccseleration*CalibrateSecondsCut then begin
      doBigSignal(deviceNumber, Cycle);
      SaveBigSignalData(deviceNumber, cycle);
    end else
    if cycle = BlockAccseleration*CalibrateSecondsCut then begin
       RecalculateOptimumPoint(deviceNumber);
    end else
    if cycle > BlockAccseleration*CalibrateSecondsCut+3 then
      doWorkPointShift(deviceNumber);

  end;

  // обновление индикаторов формы результатами последнего измерения.
  // Метод должен выполняться только через Synchronize, который нужен
  // для доступа к элементам VCL не из основного потока
  procedure TProcessThread.SaveChannelsData;
  var
    ch,i: Integer;
  begin
    if visChAvg[0].Series[0].Count = 0 then begin
      for i := 0 to ChannelPackageSize-1 do begin
        visChAvg[0].Series[0].Add(0);
        visChAvg[1].Series[0].Add(0);
      end;
    end;
      for ch:=0 to DevicesAmount-1 do
      begin
        for i := 0 to ChannelPackageSize-1 do begin
          writeln(Files[ch], ChannelData[ch, i]);
          visChAvg[ch].Series[0].YValue[i] := ChannelData[ch, i];
        end;
      end;
  end;


  procedure TProcessThread.ParseChannelsData;
  var
    ch: Integer;
    i: Integer;
    IndexShift: Integer;
  begin
    for ch:=0 to LTR24_CHANNEL_NUM-1 do begin
      if ChValidData[ch] then begin
        for i := 0 to ChannelPackageSize-1 do begin
          IndexShift := DevicesAmount*i + ch;
          ChannelData[ch, i] := data[IndexShift];
        end;
      end;
    end;
  end;

  procedure TProcessThread.doBigSignal(deviceNumber: Integer; Cycle: Integer);
  var
    i,j: Integer;
  begin
    //for j := 0  to DevicesAmount - 1 do begin
      SendDAC(deviceNumber, Cycle * BigSignalStep);
    //end;
  end;

  procedure TProcessThread.NextTick();
  var i:Integer;
  begin
    ParseChannelsData;
    if doUseCalibration then  begin
      for i := 0  to DevicesAmount - 1 do
        CalibrateData(i, MilisecsProcessed);
    end;
    Synchronize(SaveChannelsData);
  end;  //}
end.

