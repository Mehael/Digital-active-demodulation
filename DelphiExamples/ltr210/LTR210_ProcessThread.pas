unit LTR210_ProcessThread;



interface
uses Classes, Math, SyncObjs,StdCtrls,SysUtils, ltr210api, ltrapi;
// ������� �� ����� ����� ������ �� ������
const RECV_TOUT          = 1000;
// ���� �� ������ ����� �� ������ �� ������ ����� �� ������, �� ������� ��� �����������
const KEEPALIVE_TOUT     = 10000;



type TLTR210_ProcessThread = class(TThread)
  public
    //�������� ���������� ��� ����������� ����������� ���������
    edtChAvg : array [0..LTR210_CHANNEL_CNT-1] of TEdit;
    edtValidFrameCntr : TEdit;
    edtInvalidFrameCntr : TEdit;
    edtSyncSkipCntr : TEdit;
    edtOverlapCntr : TEdit;
    edtInvalidHistCntr  : TEdit;

    phltr210: pTLTR210; //��������� ������

    err : LongInt; //��� ������ ��� ���������� ������ �����
    stop : Boolean; //������ �� ������� (��������������� �� ��������� ������)

    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    { Private declarations }
    // ������� � ����� �� ������� ������
    ChAvg : array [0..LTR210_CHANNEL_CNT-1] of Double;
    // �������, ��� ���� ����������� ������ �� ������� � ChAvg
    ChValidData : array [0..LTR210_CHANNEL_CNT-1] of Boolean;
    // ������� ��������� �������� ������
    ValidFrameCntr : LongWord;
    // ������� ������, �������� � �������
    InvalidFrameCntr : LongWord;
    // ������� ������ � ��������� ������� �������������
    SyncSkipCntr : LongWord;
    // ������� ������ ��� ��������� ������ ������� ��������� ������
    OverlapCntr : LongWord;
    // ������� ������ � �������� ������������
    InvalidHistCntr  : LongWord;



    procedure updateData;
    procedure checkFrameStatusFlags(status_flags: Word);
  protected
    procedure Execute; override;
  end;
implementation


  constructor TLTR210_ProcessThread.Create(SuspendCreate : Boolean);
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     err:=LTR_OK;
  end;

  destructor TLTR210_ProcessThread.Free();
  begin
      Inherited Free();
  end;

  { ���������� ����������� ����� ������������ ���������� ���������.
   ����� ������ ����������� ������ ����� Syncronize, ������� �����
   ��� ������� � ��������� VCL �� �� ��������� ������ }
  procedure TLTR210_ProcessThread.updateData;
  var
    ch: Integer;
  begin
      edtValidFrameCntr.Text   := IntToStr(ValidFrameCntr);
      edtInvalidFrameCntr.Text := IntToStr(InvalidFrameCntr);
      edtSyncSkipCntr.Text     := IntToStr(SyncSkipCntr);
      edtOverlapCntr.Text      := IntToStr(OverlapCntr);
      edtInvalidHistCntr.Text  := IntToStr(InvalidHistCntr);
      for ch:=0 to LTR210_CHANNEL_CNT-1 do
      begin
        if ChValidData[ch] then
          edtChAvg[ch].Text := FloatToStrF(ChAvg[ch], ffFixed, 4, 8)
        else
          edtChAvg[ch].Text := '';
      end;
  end;


  procedure TLTR210_ProcessThread.checkFrameStatusFlags(status_flags: Word);
  begin
    //����������� ����� ������� ��������� ����� � ��������� ��������������� ��������
    if (status_flags and LTR210_STATUS_FLAG_SYNC_SKIP)<>0 then
      SyncSkipCntr:=SyncSkipCntr+1;
    if (status_flags and LTR210_STATUS_FLAG_OVERLAP) <> 0 then
      OverlapCntr:=OverlapCntr+1;
    if (status_flags and LTR210_STATUS_FLAG_INVALID_HIST) <> 0 then
      InvalidHistCntr:=InvalidHistCntr+1;
  end;

  procedure TLTR210_ProcessThread.Execute;
  type WordArray = array[0..0] of LongWord;
  type PWordArray = ^WordArray;
  var
    stoperr, recv_size : Integer;
    rd_pos   : LongWord;
    rcv_buf  : array of LongWord;
    buf_slice: PWordArray;
    data     : array of Double;
    info     : array of TLTR210_DATA_INFO;
    evt      : LongWord;
    interval : LongWord;
    frame_st : TLTR210_FRAME_STATUS;
    i        : LongWord;
    ch       : LongWord;
    ch_avg   : array [0..LTR210_CHANNEL_CNT-1] of Double;
    ch_size  : array [0..LTR210_CHANNEL_CNT-1] of LongWord;
    ch_valid : array [0..LTR210_CHANNEL_CNT-1] of Boolean;
  begin
    //�������� ����������
    ValidFrameCntr:=0;
    InvalidFrameCntr:=0;
    SyncSkipCntr:=0;
    OverlapCntr:=0;
    InvalidHistCntr:=0;
    for ch:=0 to LTR210_CHANNEL_CNT-1 do
      ChValidData[ch]:=False;
    Synchronize(updateData);


    { �������� ������� ��� ������ ������. ���������� ������ �����������
      ������ �� ����, ������������ ����������� }
    SetLength(rcv_buf, phltr210^.State.RecvFrameSize);
    SetLength(data, phltr210^.State.RecvFrameSize);
    SetLength(info, phltr210^.State.RecvFrameSize);
    err:= LTR210_Start(phltr210^);
    if err = LTR_OK then
    begin
      while not stop and (err = LTR_OK) do
      begin
        // ������� ������� ������ �� ������
        err := LTR210_WaitEvent(phltr210^, evt, 100);

        if err=LTR_OK then
        begin
          //������, ��� �� ������� ���������
          case evt of
            LTR210_RECV_EVENT_SOF:
            begin
              rd_pos := 0;
              { ����� �� ������������ ������� ������� �� ����� (� �������
                �������� �� �� ����� �������� ����), ��������� �����������
                ������ ����� ����������� �������. ��� ���� ��������
                RECV_TOUT �����, ����� ���� �� ����� ������ �� ���� �������. }
              while (rd_pos < phltr210^.State.RecvFrameSize) and (err=LTR_OK) and not stop do
              begin
                { ����� ����� ������������ � ������ ������� � ������� rd_pos.
                  ��� ��� Slice() ���� ����������� ������ ����� ����� ������� �� ������,
                  �� ����� ����� ����� ������� �� ������������� �����, ����������
                  ���. ���������� � ���������� �� ��������� }
                buf_slice := @rcv_buf[rd_pos];
                recv_size:= LTR210_Recv(phltr210^, buf_slice^, phltr210^.State.RecvFrameSize-rd_pos, RECV_TOUT);
                if recv_size < 0 then
                  err:= recv_size
                else if recv_size = 0 then
                  err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
                else
                  rd_pos:=rd_pos + LongWord(recv_size);

              end;

              if (err=LTR_OK) and not stop then
              begin
                recv_size:=rd_pos;
                err:=LTR210_ProcessData(phltr210^, rcv_buf, data, recv_size,
                                        LTR210_PROC_FLAG_VOLT or
                                        LTR210_PROC_FLAG_AFC_COR or
                                        LTR210_PROC_FLAG_ZERO_OFFS_COR,
                                        frame_st, info);
                if err = LTR_OK then
                begin
                  // �� ���� Result ������ ����� �����, ������������� �� ������
                  if frame_st.Result = LTR210_FRAME_RESULT_OK then
                  begin
                    ValidFrameCntr:=ValidFrameCntr+1;
                    checkFrameStatusFlags(frame_st.Flags);

                    // ��� ������� ������������ ������ ������� �� ������� ������

                    for ch:=0 to LTR210_CHANNEL_CNT-1 do
                    begin
                      ch_size[ch]:=0;
                      ch_avg[ch]:=0;
                      ch_valid[ch]:=false;
                    end;

                    { � ������ ������� ���������� �������������� ������� ��
                      ���. ����������. ���� �� ����� �� � ��������������� ������,
                      ��� ������ ���� ��������� (��� ���� ����������� �������:
                      1-�� ������ 1-�� ������, 1-�� 2-�� ������, 2-�� 1-�� ������ � �.�.) }
                    for i:=0 to recv_size-1 do
                    begin
                      //��� ������� ������ ������� ������� � �������
                      ch_size[info[i].Ch]:= ch_size[info[i].Ch]+1;
                      ch_avg[info[i].Ch]:= ch_avg[info[i].Ch] + data[i];
                      ch_valid[info[i].Ch]:=true;
                    end;

                    for ch:=0 to LTR210_CHANNEL_CNT-1 do
                    begin
                      if ch_valid[ch] then
                      begin
                        ChAvg[ch]:=ch_avg[ch]/ch_size[ch];
                      end;
                      ChValidData[ch]:=ch_valid[ch];
                    end;
                  end
                  else if frame_st.Result = LTR210_FRAME_RESULT_ERROR then
                  begin
                    InvalidFrameCntr:=InvalidFrameCntr+1;
                    checkFrameStatusFlags(frame_st.Flags);
                  end;

                  // ��������� �������� ��������� ����������
                  Synchronize(updateData);
                end;
              end;
            end;
            LTR210_RECV_EVENT_TIMEOUT:
            begin
              if (phltr210^.Cfg.Flags and LTR210_CFG_FLAGS_KEEPALIVE_EN) <> 0 then
              begin
                { ��� ���������� ������� ������������� ��������,
                  ���� ������ �� ������, �� ���������, ��� �� ��������� ����������
                  �������� �������� }
                err:= LTR210_GetLastWordInterval(phltr210^, interval);
                if (err=LTR_OK) and (interval > KEEPALIVE_TOUT) then
                  err:= LTR210_ERR_KEEPALIVE_TOUT_EXCEEDED;
              end;
            end;
          end;


        end;
      end;

      { �� ������ �� ����� ������������� ���� ������.
        ����� �� �������� ��� ������ (���� ����� �� ������)
        ��������� �������� ��������� � ��������� ���������� }
      stoperr:= LTR210_Stop(phltr210^);
      if err = LTR_OK then
        err:= stoperr;


    end;



  end;
end.
