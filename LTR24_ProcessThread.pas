unit LTR24_ProcessThread;

interface
uses Classes, Math, SyncObjs,StdCtrls,SysUtils, ltr24api, ltrapi;
// �����, �� ������� ����� ������������ ������� �������� (� ��)
const RECV_BLOCK_TIME          = 500;
// ��������������  ���������� ������� �� ����� ������ (� ��)
const RECV_TOUT                = 4000;


type TLTR24_ProcessThread = class(TThread)
  public
    //�������� ���������� ��� ����������� ����������� ���������
    edtChAvg : array [0..LTR24_CHANNEL_NUM-1] of TEdit;

    phltr24: pTLTR24; //��������� �� ��������� ������

    err : Integer; //��� ������ ��� ���������� ������ �����
    stop : Boolean; //������ �� ������� (��������������� �� ��������� ������)

    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    { Private declarations }
    // ������� � ����� �� ������� ������
    ChAvg : array [0..LTR24_CHANNEL_NUM-1] of Double;
    // �������, ��� ���� ����������� ������ �� ������� � ChAvg
    ChValidData : array [0..LTR24_CHANNEL_NUM-1] of Boolean;

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
    ch: Integer;
  begin
      for ch:=0 to LTR24_CHANNEL_NUM-1 do
      begin
        if ChValidData[ch] then
          edtChAvg[ch].Text := FloatToStrF(ChAvg[ch], ffFixed, 4, 8)
        else
          edtChAvg[ch].Text := '';
      end;
  end;


  procedure TLTR24_ProcessThread.Execute;
  type WordArray = array[0..0] of LongWord;
  type PWordArray = ^WordArray;
  var
    stoperr, recv_size : Integer;
    rcv_buf  : array of LongWord;  //����� �������� ����� �� ������
    data     : array of Double;    //������������ ������
    i        : Integer;
    ch       : Integer;
    ch_cnt   : Integer;  //���������� ����������� �������
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

            // ������� ��������
            for i:=0 to recv_size-1 do
            begin
              for ch:=0 to ch_cnt-1 do
              begin
                ch_avg[ch_nums[ch]] :=  ch_avg[ch_nums[ch]] + data[ch_cnt*i + ch];
                ch_valid[ch_nums[ch]] := True;
              end;
            end;

            for ch:=0 to LTR24_CHANNEL_NUM-1 do
            begin
              if ch_valid[ch] then
                ChAvg[ch]:=ch_avg[ch]/recv_size;
              ChValidData[ch]:= ch_valid[ch];
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

  end;
end.

