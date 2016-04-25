unit LTR24_ProcessThread;

interface
uses Classes, Math, SyncObjs, Graphics, Chart, Series, StdCtrls,SysUtils, ltr24api, ltrapi;
// �����, �� ������� ����� ������������ ���� (� ��)
const RECV_BLOCK_TIME          = 500;
// ��������������  ���������� ������� �� ����� ������ (� ��)
const RECV_TOUT                = 1000;


type TLTR24_ProcessThread = class(TThread)
  public
    //�������� ���������� ��� ����������� ����������� ���������
    visChAvg : array [0..LTR24_CHANNEL_NUM-1] of TChart;
    MilisecsToWork:  Int64;
    MilisecsProcessed:  Int64;
    phltr24: pTLTR24; //��������� �� ��������� ������

    err : Integer; //��� ������ ��� ���������� ������ �����
    stop : Boolean; //������ �� ������� (��������������� �� ��������� ������)
    Files : array of TextFile;
    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    { Private declarations }
    // �������, ��� ���� ����������� ������ �� ������� � ChAvg
    ChValidData : array [0..LTR24_CHANNEL_NUM-1] of Boolean;
    data     : array of Double;    //������������ ������
    ch_cnt   : Integer;  //���������� ����������� �������
    recv_size : Integer;
    
    procedure updateData;
  protected
    procedure Execute; override;
  end;
implementation


  constructor TLTR24_ProcessThread.Create(SuspendCreate : Boolean);
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     err:=LTR_OK;
  end;

  destructor TLTR24_ProcessThread.Free();
  begin
      Inherited Free();
  end;

  { ���������� ����������� ����� ������������ ���������� ���������.
   ����� ������ ����������� ������ ����� Synchronize, ������� �����
   ��� ������� � ��������� VCL �� �� ��������� ������ }
  procedure TLTR24_ProcessThread.updateData;
  var
    ch,i: Integer;
  begin
    if visChAvg[0].Series[0].Count = 0 then begin
      for i := 0 to recv_size-1 do begin
        visChAvg[0].Series[0].Add(0);
        visChAvg[1].Series[0].Add(0);
      end;
    end;
    
      for ch:=0 to LTR24_CHANNEL_NUM-1 do
      begin
        if ChValidData[ch] then
        begin
          for i := 0 to recv_size-1 do begin
            writeln(Files[ch], data[ch_cnt*i + ch]);
            visChAvg[ch].Series[0].YValue[i] := data[ch_cnt*i + ch];
          end;
        end;
      end;
  end;


  procedure TLTR24_ProcessThread.Execute;
  type WordArray = array[0..0] of LongWord;
  type PWordArray = ^WordArray;
  var
    stoperr,i : Integer;
    rcv_buf  : array of LongWord;  //����� �������� ����� �� ������

    ch       : Integer;

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
    Synchronize(updateData);

    //���������, ������� � ����� ������ ���������
    ch_cnt := 0;
    for ch:=0 to LTR24_CHANNEL_NUM-1 do
    begin
      if phltr24^.ChannelMode[ch].Enable then
      begin
        ch_nums[ch_cnt] := ch;
        ch_cnt := ch_cnt+1;
      end;
    end;

    { ����������, ������ �������������� ����� ���������� �� �������� �����
      => ����� ��������� ������ ������� ������ ������� }
    recv_data_cnt:=  Round(phltr24^.ADCFreq*RECV_BLOCK_TIME/1000) * ch_cnt;
    { � 24-������ ������� ������� ������� ������������� ��� ����� �� ������,
                   � � 20-������ - ���� }
    if phltr24^.DataFmt = LTR24_FORMAT_24 then
      recv_wrd_cnt :=  2*recv_data_cnt
    else
      recv_wrd_cnt :=  recv_data_cnt;




    { �������� ������� ��� ������ ������ }
    SetLength(rcv_buf, recv_wrd_cnt);
    SetLength(data, recv_data_cnt);
    err:= LTR24_Start(phltr24^);
    if err = LTR_OK then
    begin
      while not stop and (err = LTR_OK) do
      begin
        { ��������� ������ (����� ������������ ������� ��� �����������, �� ����
          � ������������� ������� � ����) }
        recv_size := LTR24_Recv(phltr24^, rcv_buf, recv_wrd_cnt, RECV_TOUT + RECV_BLOCK_TIME);
        MilisecsProcessed := MilisecsProcessed +  RECV_BLOCK_TIME;

        if MilisecsProcessed > MilisecsToWork then
          stop := true;

        //�������� ������ ���� ������������� ���� ������
        if recv_size < 0 then
          err:=recv_size
        else  if recv_size < recv_wrd_cnt then
          err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
        else
        begin
          err:=LTR24_ProcessData(phltr24^, rcv_buf, data, recv_size,
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

            // �������� ���-�� �������� �� �����
            recv_size := Trunc(recv_size/ch_cnt) ;
            for ch:=0 to ch_cnt-1 do
            begin
              ChValidData[ch] := True;
            end;

            // ��������� �������� ��������� ����������
            Synchronize(updateData);
          end;
        end;

      end; //while not stop and (err = LTR_OK) do

      { �� ������ �� ����� ������������� ���� ������.
        ����� �� �������� ��� ������ (���� ����� �� ������)
        ��������� �������� ��������� � ��������� ���������� }
      stoperr:= LTR24_Stop(phltr24^);
      if err = LTR_OK then
        err:= stoperr;

    end;

      for i := 0 to recv_size-1 do begin
        visChAvg[0].Series[0].YValue[i] := 0;
        visChAvg[1].Series[0].YValue[i] := 0;
      end;

    for i := 0 to ch_cnt-1 do
      CloseFile(Files[i]);
  end;
  {
  

  }
  {
procedure TMainForm.SaveChannelsData;
var
  channel: Integer;
  i: Integer;
begin
  for i := 0 to ChannelPackageSize do begin
    chGraph.Series[0].YValue[i] := chGraph.Series[0].YValue[ChannelPackageSize+i];
    chGraph2.Series[0].YValue[i] := chGraph2.Series[0].YValue[ChannelPackageSize+i];
  end;

  for channel := 1 to ChannelsAmount do
    for i := 1 to ChannelPackageSize do begin
      writeln(Files[channel], ChannelData[channel, i]);
      if channel = SelectedChannel1 then
          chGraph.Series[0].YValue[ChannelPackageSize+i-1] := ChannelData[channel, i];
      if channel = SelectedChannel2 then
          chGraph2.Series[0].YValue[ChannelPackageSize+i-1] := ChannelData[channel, i];

    end;

    for i := 1 to ChannelPackageSize do
        writeln(Files[DEBUG_DATA], LastCalibrateSignal[1]);
end;
      }
      {
procedure TMainForm.RecalculateConfigValues;
begin
  doUseCalibration:= CheckBox1.Checked;
  SelectedChannel1:=StrToInt(Ch1.Text);
  SelectedChannel2:=StrToInt(Ch2.Text);
  MinutesWork := StrToInt(txWorkTime.Text);  // ����� ����� ������ � �������, ������� 1 ������!!!
  if cbTimeMetric.Text = '�����' then
    MinutesWork := MinutesWork*60;
  if cbTimeMetric.Text = '����' then
    MinutesWork := MinutesWork*60*24;
  //CalibrationDelay := BlockAccseleration* 60 * StrToInt(txCalibrationDelay.Text);  //������ ���������� � ������ (1 ���� = 1 �)
  CyclesWork := Round((MinutesWork * 60) / (BufferSize / (1000 * (Frequency))));
end;   }

end.

