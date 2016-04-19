unit LTR51_ProcessThread;



interface
uses Classes, Math, SyncObjs,StdCtrls,SysUtils, ltr51api, ltrapi;



type TLTR51_ProcessThread = class(TThread)
  public

    phltr51: pTLTR51; //��������� �� ��������� ������
    IntervalMax : Double; //������������ ���������� ��������
    ReqFrontCnt : LongWord; //��������� ���-�� �������, ����� �������� �������������� ��������
    err : Integer; //��� ������ ��� ���������� ������ �����
    stop : Boolean; //������ �� ������� (��������������� �� ��������� ������)
    mmoLog : TMemo; //������� ���������� ��� ������ ���������



    constructor Create(SuspendCreate : Boolean);
    destructor Free();

  private
    cur_msg : string;
    procedure sendLogText(msg: string);
    procedure sendChMsg(ch: Integer; msg : string);
    procedure showCurMsg();
  protected
    procedure Execute; override;
  end;
implementation
  type TCH_INFO = record
      fnd_fronts: LongWord ;
      cntr : LongWord ;
  end;

  constructor TLTR51_ProcessThread.Create(SuspendCreate : Boolean);
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     err:=LTR_OK;
  end;

  destructor TLTR51_ProcessThread.Free();
  begin
      Inherited Free();
  end;

  { ����� ������ � ��� ���������.
   ����� ������ ����������� ������ ����� Synchronize, ������� �����
   ��� ������� � ��������� VCL �� �� ��������� ������ }
  procedure TLTR51_ProcessThread.showCurMsg;
  begin
    mmoLog.Lines.Add(cur_msg);
  end;

  procedure TLTR51_ProcessThread.sendLogText(msg: string);
  begin
    cur_msg := msg;
    Synchronize(showCurMsg);
  end;

  procedure TLTR51_ProcessThread.sendChMsg(ch: Integer; msg : string);
  begin
    sendLogText('����� ' + IntToStr(ch+1) + ': ' + msg);
  end;


  procedure TLTR51_ProcessThread.Execute;
  var
    stoperr : Integer;             //��� ������ ���������� �����
    ch_info : array of TCH_INFO;  //���������� �� ������� ��� �������� ���������
    i, ch: LongWord;
    rcv_buf  : array of LongWord;  //����� �������� ����� �� ������
    data     : array of LongWord;  //������������ ������ (����� n,m)
    max_cntr : LongWord;           //������������ �������� �������� �������� �����.
    recv_wrd_cnt : Integer;       //���������� ����������� ����� ���� �� ���
    proc_wrd_cnt : Integer;       //������ ������� ������������ ����
    cur_proc_size, recv_size : LongWord;     //��������� ���������� ��� ���������� ������� ��������
    perios_ms : double;  //���������� ��� ���������� ������������� �������
    check_drop : Boolean; //�������, ��� ���� ���������, �� �������� �� ����. ��������
    n,m : Word; //������� �������� m � n
    tout: LongWord; //������� �� �����
  begin
    SetLength(ch_info, phltr51^.LChQnt);
    for ch:=0 to phltr51^.LChQnt-1 do
    begin
      ch_info[ch].fnd_fronts := 0;
      ch_info[ch].cntr := 0;
    end;

    max_cntr :=  Round(IntervalMax*phltr51^.Fs/1000);
    { ��������� ������ ����� �� ���� �������, ��� ���� �� 2 ����� �� ������ }
    recv_wrd_cnt := 2 * LTR51_CHANNEL_CNT * phltr51^.TbaseQnt;
    SetLength(rcv_buf, recv_wrd_cnt);
    { ����� ��������� �������� ������ ����� �� ��� �������, ������� ���������,
      � �� ������ ����� �� ������ }
    proc_wrd_cnt :=  phltr51^.LChQnt* phltr51^.TbaseQnt;
    SetLength(data, proc_wrd_cnt);

    tout := LTR51_CalcTimeOut(phltr51^, phltr51^.TbaseQnt);


    err:= LTR51_Start(phltr51^);
    if err = LTR_OK then
    begin
      sendLogText('���� ������ �������');
      while not stop and (err = LTR_OK) do
      begin
        { ��������� ������ (����� ������������ ������� ��� �����������, �� ����
          � ������������� ������� � ����) }
        recv_size := LTR51_Recv(phltr51^, rcv_buf, recv_wrd_cnt, tout);
        //�������� ������ ���� ������������� ���� ������
        if recv_size < 0 then
          err:=recv_size
        else  if recv_size < recv_wrd_cnt then
          err:=LTR_ERROR_RECV_INSUFFICIENT_DATA
        else
        begin
          cur_proc_size := recv_size;
          err:=LTR51_ProcessData(phltr51^, rcv_buf, data, cur_proc_size);
          if err = LTR_OK then
          begin
            cur_proc_size := Trunc(cur_proc_size/phltr51^.LChQnt ) ;
            for i:=0 to cur_proc_size-1 do
            begin
              for ch:=0 to phltr51^.LChQnt-1 do
              begin
                check_drop := false;
                { n ���������� � ������� 16-����� ��������� �����, m - � ������� }
                n:= (data[i*phltr51^.LChQnt + ch] shr 16) and $FFFF;
                m:= (data[i*phltr51^.LChQnt + ch]) and $FFFF;
                if n <> 0 then
                begin
                  if n > 1 then
                  begin
                    { ���� ������ ������ ������,
                      �� ����� ���������� ����� ������ ����� ����������.
                      ���� ���� ��������, �� ��� ���������� ����������� �
                      �������� ������� ������ ������� � ���������� ������ }
                    sendChMsg(ch, IntToStr(n) + ' ������� �� ���� �������� ���������!! ������������ ���������!');
                    ch_info[ch].fnd_fronts := 1;
                    ch_info[ch].cntr := m;
                  end
                  else
                  begin
                    if ch_info[ch].fnd_fronts = 0 then
                    begin
                      { ���� ������ ������ ����� - �������� ������� ��������
                        �� ��� ����� }
                      sendChMsg(ch, '������ ������ �����');
                      ch_info[ch].fnd_fronts := 1;
                      ch_info[ch].cntr := m;
                    end
                    else if ch_info[ch].fnd_fronts = (ReqFrontCnt-1) then
                    begin
                      { ������ ��������� �����. ��������� ����� �� ����� ������,
                        ������������ �������� � �������� ������ ������ }
                      ch_info[ch].cntr := ch_info[ch].cntr + phltr51^.Base - m;
                      perios_ms := 1000. * ch_info[ch].cntr/phltr51^.Fs;
                      sendChMsg(ch, '������ ��������� �����. �������� � �������: ' +
                                    FloatToStrF(perios_ms, ffFixed, 8, 2) + ' ��');

                      {�������� ����� ������ ��������� � ���������� ������ }
                      ch_info[ch].cntr := m;
                      ch_info[ch].fnd_fronts := 1;
                    end
                    else
                    begin
                       { ��� ������������� ������� ������ ���������� ���� ��������
                         � ����������� ���-�� ��������� �������}
                       ch_info[ch].fnd_fronts:=ch_info[ch].fnd_fronts+1;
                       ch_info[ch].cntr:=ch_info[ch].cntr + phltr51^.Base;
                       check_drop := TRUE;
                       sendChMsg(ch, '������ ������������� ����� ' + IntToStr(ch_info[ch].fnd_fronts));
                    end;
                  end;
                end
                else
                begin
                  { n==0 => hltr51.Base �������� ���� ��� ������ => ����������
                    � �������� ��������� }
                  if ch_info[ch].fnd_fronts <> 0 then
                  begin
                      ch_info[ch].cntr := ch_info[ch].cntr + phltr51^.Base;
                      check_drop := TRUE;
                  end;
                end;

                { ��������, ��� �������� ������������ �������� � ����� �������� �������� }
                if check_drop and (ch_info[ch].cntr > max_cntr) then
                begin
                  sendChMsg(ch, '�� ���� ������������ ������ �� �������� ��������');
                  ch_info[ch].fnd_fronts := 0;
                  ch_info[ch].cntr := 0;
                end;
              end;
            end;
          end;
        end;
      end;

      { �� ������ �� ����� ������������� ���� ������.
        ����� �� �������� ��� ������ (���� ����� �� ������)
        ��������� �������� ��������� � ��������� ���������� }
      stoperr := LTR51_Stop(phltr51^);
      if err = LTR_OK then
         err:= stoperr;

      sendLogText('���� ������ ����������');   
    end;
  end;
end.
