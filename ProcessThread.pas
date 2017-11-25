unit ProcessThread;

interface
uses Windows, Classes, Math, SyncObjs, Graphics, Chart, Series,
StdCtrls, SysUtils, ltr24api, ltr34api, ltrapi, WriterThread, Config;
                                                           
type TProcessThread = class(TThread)
  public
    //�������� ���������� ��� ����������� ����������� ���������
    visChAvg : array [0..LTR24_CHANNEL_NUM-1] of TChart;
    ShowSignal: TCheckBox;
    WriterThread : TWriter;
    MilisecsToWork:  Int64;
    MilisecsProcessed:  Int64;
    phltr34: pTLTR34;
    phltr24: pTLTR24; //��������� �� ��������� ������
    bnStart:  TButton;
    skipAmount: integer;
    WindowPercent: integer;
    PrevHistoryIndex: Integer;
    Config:TConfig;

    path:string;
    frequency:string;

    doUseCalibration:boolean;
    err : Integer; //��� ������ ��� ���������� ������ �����
    stop : Boolean; //������ �� ������� (��������������� �� ��������� ������)

    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    { Private declarations }
    // �������, ��� ���� ����������� ������ �� ������� � ChAvg
    ChValidData : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
    AccelerationSign: array [0..LTR24_CHANNEL_NUM-1] of Integer;
    OptimalDACSignal , OptimalPoint, Scale: array [0..LTR24_CHANNEL_NUM-1] of DOUBLE;
    LastCalibrateSignal: array of DOUBLE;
    data     : array of Double;    //������������ ������
    calibration_signal_step: double;
    ActiveChannelsAmount   : Integer;  //���������� ����������� �������
    ChannelPackageSize : Integer;
    History: THistory;
    HistoryIndex, HistoryPage : Integer;
    historyPagesAmount : Integer;
    amplitude: Double;
    WORD_DATA : array of Double;

    //YWindowVariables
    YWindowMax, YWindowMin, LastLowFreq: array of Double;
    Median: array of array of Double;
    CurrentMedianIndex : array of Integer;

    procedure NextTick();
    procedure ParseChannelsData;
    procedure sendDAC(channel: Integer; signal: Double);
    procedure CalibrateData(deviceNumber: Integer);
    procedure doWorkPointShift(deviceNumber: Integer);
    function GetLowFreq(deviceNumber: Integer) : Double;
    procedure RecalculateOptimumPoint(deviceNumber: Integer);
    procedure doBigSignal(deviceNumber: Integer);
    procedure DryData(wetData: array of LongWord; out dryData: array of Double);
    procedure SafeSaveData;
    procedure CreateFilesForWriting;
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

     SetLength(Median, DevicesAmount, MedianDeep);
     SetLength(LastCalibrateSignal,DAC_packSize);
     SetLength(WORD_DATA, DAC_packSize);

     SetLength(YWindowMax, DevicesAmount);
     SetLength(YWindowMin, DevicesAmount);
     SetLength(LastLowFreq, DevicesAmount);
     SetLength(CurrentMedianIndex, DevicesAmount);

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
    ph: pTLTR34;
  begin
    LastCalibrateSignal[channel]:= signal;

    LTR34_ProcessData(phltr34,@LastCalibrateSignal, WORD_DATA, phltr34.ChannelQnt, 0); //1- ��������� ��� �������� � �������
    LTR34_Send(phltr34,@WORD_DATA, phltr34.ChannelQnt, DAC_possible_delay);
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
    rcv_buf  : array of LongWord;  //����� �������� ����� �� ������

    ch, steps_amount       : Integer;

    recv_wrd_cnt : Integer;  //���������� ����������� ����� ���� �� ���
    recv_data_cnt : Integer; //���������� ������������ ����, ������� ������ ������� �� ���
    // ������ ����������� �������
    ch_nums  : array [0..LTR24_CHANNEL_NUM-1] of Byte;
    // ��������� ���������� ��� ����������. � ����� ����������� ��� ����
    // ������ - ChAvg � ChDataValid
    ch_avg   : array [0..LTR24_CHANNEL_NUM-1] of Double;
    ch_valid : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
  begin
    //�������� ����������
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
      ChValidData[ch]:=False;

    if doUseCalibration then
     LTR34_DACStart(phltr34);

    //���������, ������� � ����� ������ ���������
    ActiveChannelsAmount := 0;
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
    begin
      if phltr24^.ChannelMode[ch].Enable then
      begin
        ch_nums[ActiveChannelsAmount] := ch;
        ActiveChannelsAmount := DevicesAmount+1;
      end;
    end;

    { ����������, ������ �������������� ����� ���������� �� �������� �����
      => ����� ��������� ������ ������� ������ ������� }
    recv_data_cnt:=  Round(phltr24^.ADCFreq*ADC_reading_time/1000) * DevicesAmount;
    { � 24-������ ������� ������� ������� ������������� ��� ����� �� ������,
                   � � 20-������ - ���� }
    if phltr24^.DataFmt = LTR24_FORMAT_24 then
      recv_wrd_cnt :=  2*recv_data_cnt
    else
      recv_wrd_cnt :=  recv_data_cnt;

    { �������� ������� ��� ������ ������ }
    SetLength(rcv_buf, recv_wrd_cnt);
    SetLength(data, recv_data_cnt);

    DAC_max_signal := VoltToCode(DAC_max_VOLT_signal);
    DAC_min_signal := VoltToCode(DAC_min_VOLT_signal);

    historyPagesAmount :=   Trunc((recv_data_cnt*InnerBufferPagesAmount)/DevicesAmount);

    steps_amount :=  Trunc(CalibrateMiliSecondsCut/ADC_reading_time);
    calibration_signal_step := (DAC_max_signal-DAC_min_signal)/steps_amount;
    SetLength(History, ChannelsAmount, historyPagesAmount);
    err:= LTR24_Start(phltr24^);

    CreateFilesForWriting;
    if err = LTR_OK then
    begin
      while not stop and (err = LTR_OK) do
      begin
        { ��������� ������ (����� ������������ ������� ��� �����������, �� ����
          � ������������� ������� � ����) }
        ChannelPackageSize := LTR24_Recv(phltr24^, rcv_buf, recv_wrd_cnt, ADC_possible_delay + ADC_reading_time);
        MilisecsProcessed := MilisecsProcessed +  ADC_reading_time;

        if MilisecsProcessed > MilisecsToWork then
          stop := true;

        //�������� ������ ���� ������������� ���� ������
        if ChannelPackageSize < 0 then
          err:=ChannelPackageSize
        else  if ChannelPackageSize < recv_wrd_cnt then
          err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
        else
        begin
          err:=LTR24_ProcessData(phltr24^, rcv_buf, data, ChannelPackageSize, LTR24_PROC_FLAG_VOLT); //  LTR24_PROC_FLAG_NONCONT_DATA
          //DryData(rcv_buf, data);
          if err=LTR_OK then
          begin
            for ch:=0 to LTR24_CHANNEL_NUM-1 do
            begin
              ch_avg[ch] :=  0;
              ch_valid[ch] := False;
            end;

            // �������� ���-�� �������� �� �����
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

      if doUseCalibration then begin
        LTR34_Reset(phltr34);
        LTR34_DACStop(phltr34);
      end;

      visChAvg[0].Series[0].Clear();
      visChAvg[1].Series[0].Clear();

      HistoryIndex:= HistoryPage*ChannelPackageSize;

      for ch:=0 to DevicesAmount-1 do
          for i := HistoryIndex to Length(History[0])-1 do
             History[ch, i] := 0;

      SafeSaveData;

      stoperr:= LTR24_Stop(phltr24^);
      if err = LTR_OK then
        err:= stoperr;

      Sleep(500);
      WriterThread.Terminate();

    end;
    bnStart.Caption := 'Старт';
  end;

  procedure TProcessThread.CreateFilesForWriting;
  begin
    WriterThread := TWriter.Create(path, frequency, skipAmount, True, Config);
    WriterThread.Priority := tpHighest;
    WriterThread.History := History;
  end;

  procedure TProcessThread.SafeSaveData;
  begin
    if (WriterThread <> nil) then
      WriterThread.Save();
  end;

  function TProcessThread.GetLowFreq(deviceNumber: Integer) : Double;
  var i, fresh_moar, fresh_less: Integer;
  aver,startValue, dif, memory, fresh : Double;

  begin
     startValue:=History[deviceNumber, HistoryIndex];
     aver:=0;
     for i := 0 to ChannelPackageSize-1 do begin
        aver:=aver+History[deviceNumber, HistoryIndex+i];
     end;

        Median[deviceNumber, CurrentMedianIndex[deviceNumber]]:=aver/ChannelPackageSize;

        fresh:=0;
        memory:= 0;

        fresh_moar:=CurrentMedianIndex[deviceNumber];
        fresh_less:=fresh_moar+freshDeep;
        if (fresh_less>MedianDeep) then begin
          fresh_less:=fresh_less-MedianDeep;
           for i := 0 to MedianDeep-1 do begin
           if ((i>=fresh_moar) or (i<fresh_less)) then
              fresh:=fresh+Median[deviceNumber, i]
           else
              memory:=memory+Median[deviceNumber, i];
          end;
        end else begin
          for i := 0 to MedianDeep-1 do begin
           if ((i>=fresh_moar) and (i<fresh_less)) then
              fresh:=fresh+Median[deviceNumber, i]
           else
              memory:=memory+Median[deviceNumber, i];
          end;
        end;

        if MedianDeep>1 then memory:=memory/(MedianDeep-1)
        else memory:= Median[deviceNumber, CurrentMedianIndex[deviceNumber]];

        //dif:= Median[deviceNumber, CurrentMedianIndex[deviceNumber]]-memory;
        //dif:=fresh-memory;
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
    Shift, newCalibrateSignal, lowFreq, shiftPercentFromAmplitude: Double;
  begin
    newCalibrateSignal := GetLowFreq(deviceNumber);
    Shift := 0;
    Shift := OptimalPoint[deviceNumber] - newCalibrateSignal;

    if deviceNumber = 0 then
      WriterThread.DebugWrite(LastCalibrateSignal[deviceNumber]);

    if ((newCalibrateSignal > YWindowMin[deviceNumber]) and
    (newCalibrateSignal < YWindowMax[deviceNumber])) then exit;

    Shift :=  Shift * AccelerationSign[deviceNumber]*Scale[deviceNumber]*0.007;
    Shift := VoltToCode(Shift);
    newCalibrateSignal := LastCalibrateSignal[deviceNumber] + Shift;

    if newCalibrateSignal > DAC_max_signal then
     newCalibrateSignal := newCalibrateSignal - VoltToCode(VoltResetByDevice[deviceNumber]);
    if newCalibrateSignal < DAC_min_signal then
      newCalibrateSignal := newCalibrateSignal + VoltToCode(VoltResetByDevice[deviceNumber]);

    SendDAC(deviceNumber, newCalibrateSignal);
    LastLowFreq[deviceNumber]:=lowFreq;
  end;

  Procedure TProcessThread.RecalculateOptimumPoint(deviceNumber: Integer);
  var i: integer;
    indexMin,indexMax:longint;
    OpHistoryPage, OpHistoryIndex: longint ;
    BefPageSignal, SignalStepByIndex, PageSignalChange: single;
    valueMax,valueMin, CalibrationEndIndex,toPersentMult: Double;
  begin
    valueMin := History[0,0] ; valueMax := History[0,0] ;
    indexMin := 0; indexMax := 0;

    for i := 0 to Length(History[deviceNumber])-1 do begin
    if (History[deviceNumber,i] = 0) then break;
      //visChAvg[deviceNumber].Series[0].Add(History[deviceNumber,i]);
      if valueMin >= History[deviceNumber,i] then begin
        valueMin := History[deviceNumber,i];
        indexMin := i;
      end;
      if valueMax <= History[deviceNumber,i] then begin
        valueMax := History[deviceNumber,i];
        indexMax := i;
      end;
    end;
    OptimalPoint[deviceNumber] := 0;//(valueMax+valueMin)/2;     //����� ��������� ��� �����

    amplitude := (valueMax-valueMin)*WindowPercent*0.005;
    YWindowMax[deviceNumber]:= OptimalPoint[deviceNumber] + amplitude;
    YWindowMin[deviceNumber]:= OptimalPoint[deviceNumber] - amplitude;
                                                                      
    Log('Ampl: ' + FloatToStr(valueMax-valueMin));

    //amplitude 4.575, scale 0.087, period Scalex0.64
    Scale[deviceNumber] :=  4/(valueMax-valueMin); // 4/

    Log('Scale: ' + FloatToStr(Scale[deviceNumber]));
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
      SafeSaveData;
      HistoryPage := 0;
    end;

    HistoryIndex:= HistoryPage*ChannelPackageSize;
    ParseChannelsData;

    if doUseCalibration then
      for i := 0 to DevicesAmount - 1 do
        CalibrateData(i);

    HistoryPage:= HistoryPage+1;
  end;

end.

