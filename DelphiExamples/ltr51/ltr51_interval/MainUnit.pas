unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  ltrapi, ltrapitypes, ltrapidefine, ltr51api, LTR51_ProcessThread;


  { ����������, ����������� ��� ������������ ���������� � ������� }
type TLTR_MODULE_LOCATION = record
  csn : string; //�������� ����� ������
  slot : Word; //����� �����
end;

type
  TMainForm = class(TForm)
    cbbModulesList: TComboBox;
    btnRefreshDevList: TButton;
    btnOpen: TButton;
    btnStart: TButton;
    btnStop: TButton;
    grpDevInfo: TGroupBox;
    lblDevSerial: TLabel;
    lblVerAvrFirm: TLabel;
    lblVerFPGA: TLabel;
    edtDevSerial: TEdit;
    edtVerFPGA: TEdit;
    edtVerAvrFirm: TEdit;
    lbl1: TLabel;
    edtAvrFirmDate: TEdit;
    grpConfig: TGroupBox;
    lblSyncLevelL1: TLabel;
    edtTresholdL: TEdit;
    lbl2: TLabel;
    edtTresholdH: TEdit;
    edtIntervalMin: TEdit;
    lbl3: TLabel;
    edtIntervalMax: TEdit;
    lbl4: TLabel;
    cbbTreshRange: TComboBox;
    lbl5: TLabel;
    cbbEdge: TComboBox;
    mmoLog: TMemo;
    edtReqFrontCnt: TEdit;
    lbl6: TLabel;
    lbl7: TLabel;
    procedure btnRefreshDevListClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
  private
    { Private declarations }
    ltr51_list: array of TLTR_MODULE_LOCATION; //������ ��������� �������
    hltr51 : TLTR51; // ��������� ������, � ������� ���� ������

    thread : TLTR51_ProcessThread; //������ ������ ��� ���������� ����� ������
    threadRunning : Boolean; // �������, ������� �� ����� ����� ������


    procedure updateControls();
    procedure refreshDeviceList();
    procedure closeDevice();
    procedure OnThreadTerminate(par : TObject);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{ ����� ���������/��������� ������ �������� ���������� � ����������� ��
  �������� ��������� ��������� }
procedure TMainForm.updateControls();
var
  module_opened, devsel, change_en: Boolean;
begin
  module_opened:=LTR51_IsOpened(hltr51)=LTR_OK;
  devsel := (Length(ltr51_list) > 0) and (cbbModulesList.ItemIndex >= 0);

  //���������� ������ ��������� � ����� ����� ������ ������ ���� �� ������� ���������� ����������
  btnRefreshDevList.Enabled := not module_opened;
  cbbModulesList.Enabled := not module_opened;

  //���������� ����� ����� ������ ���� ������� ����������
  btnOpen.Enabled := devsel;
  if module_opened then
    btnOpen.Caption := '������� ����������'
  else
    btnOpen.Caption := '���������� ����������';


  btnStart.Enabled := module_opened and not threadRunning;
  btnStop.Enabled := module_opened and threadRunning;

  //��������� �������� �������� ������ ��� �������� ���������� � �� ���������� �����
  change_en:= module_opened and not threadRunning;
  edtTresholdL.Enabled := change_en;
  edtTresholdH.Enabled := change_en;
  edtIntervalMin.Enabled := change_en;
  edtIntervalMax.Enabled := change_en;
  edtReqFrontCnt.Enabled := change_en;
  cbbTreshRange.Enabled := change_en;
  cbbEdge.Enabled := change_en;
end;

procedure TMainForm.refreshDeviceList();
var
  srv : TLTR; //��������� ��� ������������ ���������� � LTR-��������
  crate: TLTR; //��������� ��� ���������� � �������
  res, crates_cnt, crate_ind, module_ind, modules_cnt : integer;
  serial_list : array [0..CRATE_MAX-1] of string; //������ ������� �������
  mids : array [0..MODULE_MAX-1] of Word; //������ ��������������� ������� ��� �������� ������
begin
  //�������� ������ ����� ��������� �������
  modules_cnt:=0;
  cbbModulesList.Items.Clear;
  SetLength(ltr51_list, 0);

  // ������������� ����� � ����������� ������� �������, ����� �������� ������ �������
  LTR_Init(srv);
  srv.cc := CC_CONTROL;    //���������� ����������� �����
  { �������� ����� CSN_SERVER_CONTROL ��������� ���������� ����� � ��������, ����
    ���� ��� �� ������ ������ }
  LTR_FillSerial(srv, CSN_SERVER_CONTROL);
  res:=LTR_Open(srv);
  if res <> LTR_OK then
    MessageDlg('�� ������� ���������� ����� � ��������: ' + LTR_GetErrorString(res), mtError, [mbOK], 0)
  else
  begin
    //�������� ������ �������� ������� ���� ������������ �������
    res:=LTR_GetCrates(srv, serial_list, crates_cnt);
    //��������� ���������� ������ �� ����� - ����� �������
    LTR_Close(srv);

    if (res <> LTR_OK) then
      MessageDlg('�� ������� �������� ������ �������: ' + LTR_GetErrorString(res), mtError, [mbOK], 0)
    else
    begin
      for crate_ind:=0 to crates_cnt-1 do
      begin
        //������������� ����� � ������ �������, ����� �������� ������ �������
        LTR_Init(crate);
        crate.cc := CC_CONTROL;
        LTR_FillSerial(crate, serial_list[crate_ind]);
        res:=LTR_Open(crate);
        if res=LTR_OK then
        begin
          //�������� ������ �������
          res:=LTR_GetCrateModules(crate, mids);
          if res = LTR_OK then
          begin
            for module_ind:=0 to MODULE_MAX-1 do
            begin
              //���� ������ LTR210
              if mids[module_ind]=MID_LTR51 then
              begin
                // ��������� ���������� � ��������� ������, ����������� ���
                // ������������ ������������ ���������� � ���, � ������
                modules_cnt:=modules_cnt+1;
                SetLength(ltr51_list, modules_cnt);
                ltr51_list[modules_cnt-1].csn := serial_list[crate_ind];
                ltr51_list[modules_cnt-1].slot := module_ind+CC_MODULE1;
                // � ��������� � ComboBox ��� ����������� ������ �������
                cbbModulesList.Items.Add('����� ' + ltr51_list[modules_cnt-1].csn +
                                         ', ���� ' + IntToStr(ltr51_list[modules_cnt-1].slot));
              end;
            end;
          end;
          //��������� ���������� � �������
          LTR_Close(crate);
        end;
      end;
    end;

    cbbModulesList.ItemIndex := 0;
    updateControls;

  end;
end;


//�������, ���������� �� ���������� ������ ����� ������
//��������� ����� ������, ������������� threadRunning
procedure TMainForm.OnThreadTerminate(par : TObject);
begin
    if thread.err <> LTR_OK then
    begin
        MessageDlg('���� ������ �������� � �������: ' + LTR51_GetErrorString(thread.err),
                  mtError, [mbOK], 0);
    end;

    threadRunning := false;
    updateControls;
end;

{$R *.dfm}

procedure TMainForm.btnRefreshDevListClick(Sender: TObject);
begin
  refreshDeviceList;
end;

procedure TMainForm.btnOpenClick(Sender: TObject);
var
  location :  TLTR_MODULE_LOCATION;
  res : Integer;
begin
// ���� ���������� � ������� ������� - �� ��������� �����
  if LTR51_IsOpened(hltr51)<>LTR_OK then
  begin
    // ���������� � ������ � ����� ����� �� ������������ ������ �� �������
    // ������� ��������� ������
    location := ltr51_list[ cbbModulesList.ItemIndex ];
    LTR51_Init(hltr51);
    res:=LTR51_Open(hltr51, SADDR_DEFAULT, SPORT_DEFAULT, location.csn, location.slot, 'ltr51.ttf');
    if res<>LTR_OK then
      MessageDlg('�� ������� ���������� ����� � �������: ' + LTR51_GetErrorString(res), mtError, [mbOK], 0)
    else
    begin
      edtDevSerial.Text := hltr51.ModuleInfo.Serial;
      edtVerAvrFirm.Text := hltr51.ModuleInfo.FirmwareVersion;
      edtAvrFirmDate.Text := hltr51.ModuleInfo.FirmwareDate;
      edtVerFPGA.Text := hltr51.ModuleInfo.FPGA_Version;
    end;

    if res<>LTR_OK then
      LTR51_Close(hltr51);
  end
  else
  begin
    closeDevice;
  end;

  updateControls();
end;


procedure TMainForm.closeDevice();
begin
  // ��������� ����� � �������� ���������� ������
  if threadRunning then
  begin
    thread.stop:=True;
    thread.WaitFor;
  end;

  LTR51_Close(hltr51);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LTR51_Init(hltr51);
  refreshDeviceList;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  closeDevice;
  if thread <> nil then
    FreeAndNil(thread);
end;

procedure TMainForm.btnStartClick(Sender: TObject);
var
  res: Integer;
  TreshL, TreshH, IntervalMin, IntervalMax : Double;
  ReqFrontCnt : Integer;
  range, edge : Integer;
  ch: Integer;
begin
  { ������������� �������� �� ��������� ���������� � ���������������
    ���� ��������� ������. ��� �������� ����� �� �������� ���. ��������, ���
    ������� ������ ��������... }

  TreshL := StrToFloat(edtTresholdL.Text);
  TreshH := StrToFloat(edtTresholdH.Text);
  IntervalMin := StrToFloat(edtIntervalMin.Text);
  IntervalMax := StrToFloat(edtIntervalMax.Text);
  ReqFrontCnt := StrToInt(edtReqFrontCnt.Text);

  if cbbTreshRange.ItemIndex = 0 then
    range := LTR51_TRESHOLD_RANGE_10V
  else
    range := LTR51_TRESHOLD_RANGE_1_2V;

  if cbbEdge.ItemIndex = 0 then
    edge := LTR51_EDGE_MODE_RISE
  else
    edge := LTR51_EDGE_MODE_FALL;

  if ReqFrontCnt < 2 then
    MessageDlg('���������� ������� ������ ���� �� ������ 2-�', mtError, [mbOK], 0)
  else if  IntervalMin >= IntervalMax then
    MessageDlg('������������ �������� ������ ���� ������ ������������', mtError, [mbOK], 0)
  else
  begin
    { ��� ������� ��������� ��� �������������� ������ � ����������� �� ����������
      ��������� ������� }
    hltr51.LChQnt := 0;
    for ch:=0 to LTR51_CHANNEL_CNT do
    begin
      if ((1 shl ch) and hltr51.ChannelsEna) <> 0 then
      begin
         hltr51.LChTbl[hltr51.LChQnt] := LTR51_CreateLChannel(ch+1, TreshH, TreshL, range, edge);
         hltr51.LChQnt:=hltr51.LChQnt+1;
      end;
    end;
    hltr51.AcqTime := 500;
    { �������� Base � FS ������ ������� }
    hltr51.SetUserPars := true;
    hltr51.Fs := LTR51_FS_MAX; { ������������� ����. ������� ��� ����. ����������
                                 500 K�� }
      { ������������ base, ����� ������ ��������� ��� ���� �� � 2 ����
         ������ ������������ ��������� ���������� �������, ��� ��� ���
         ��������� ������������ ��������� ���������� �����, �����
         ������ ����� ��� � ����� ��������� ��������� }
    hltr51.Base := Trunc(((IntervalMin * hltr51.Fs)/1000)/2);

    res := LTR51_Config(hltr51);
    if res<>LTR_OK then
       MessageDlg('"�� ������� ��������� ������: ' + LTR51_GetErrorString(res), mtError, [mbOK], 0)
    else
    begin
      if thread <> nil then
      begin
        FreeAndNil(thread);
      end;

      { ��������� �������� ������ �� ������� ������������� }
      edtTresholdH.Text := FloatToStrF(TreshH, ffFixed	, 8, 3);
      edtTresholdL.Text := FloatToStrF(TreshL, ffFixed	, 8, 3);

      thread := TLTR51_ProcessThread.Create(True);
      { ��� ��� ��������� ������ ���� ���� � �� ��, ��� ������������ �������,
         ��� � ������ ��������� ����, �� ��������� �������� �� ��� pointer }
      thread.phltr51 := @hltr51;
      { ��������� �������� ����������, ������� ������ ���������� ��������������
         ������� � ����� ������ }
      thread.IntervalMax := IntervalMax;
      thread.ReqFrontCnt := ReqFrontCnt;

      thread.mmoLog := mmoLog;
      mmoLog.Lines.Clear;

      { ������������� ������� �� ������� ���������� ������ (� ���������,
        ����� ���������, ���� ����� ���������� ��� ��-�� ������ ��� �����
        ������) }
      thread.OnTerminate := OnThreadTerminate;
      thread.Resume; //��� Delphi 2010 � ���� ������������� ������������ Start
      threadRunning := True;

      updateControls;
    end;    
  end;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
    // ������������� ������ �� ���������� ������
    if threadRunning then
        thread.stop:=True;
    btnStop.Enabled:= False;
end;

end.
