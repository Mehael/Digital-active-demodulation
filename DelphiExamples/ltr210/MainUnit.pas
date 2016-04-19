unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, Spin,
  ltrapi, ltrapitypes, ltrapidefine, ltr210api, LTR210_ProcessThread;

{ ����������, ����������� ��� ������������ ���������� � ������� }
type TLTR_MODULE_LOCATION = record
  csn : string; //�������� ����� ������
  slot : Word; //����� �����
end;

type
  TMainForm = class(TForm)
    btnRefreshDevList: TButton;
    cbbModulesList: TComboBox;
    btnOpen: TButton;
    pbFpgaLoad: TProgressBar;
    grpDevInfo: TGroupBox;
    edtDevSerial: TEdit;
    lblDevSerial: TLabel;
    edtVerFPGA: TEdit;
    edtVerPld: TEdit;
    lblVerPld: TLabel;
    lblVerFPGA: TLabel;
    grpConfig: TGroupBox;
    grpCfgCh1: TGroupBox;
    btnStart: TButton;
    btnStop: TButton;
    chkChEn1: TCheckBox;
    cbbRange1: TComboBox;
    cbbMode1: TComboBox;
    edtSyncLevelL1: TEdit;
    edtSyncLevelH1: TEdit;
    grp1: TGroupBox;
    chkChEn2: TCheckBox;
    cbbRange2: TComboBox;
    cbbMode2: TComboBox;
    edtSyncLevelL2: TEdit;
    edtSyncLevelH2: TEdit;
    cbbDigBit1: TComboBox;
    cbbDigBit2: TComboBox;
    lblRange1: TLabel;
    lblChMode1: TLabel;
    lblSyncLevelL1: TLabel;
    lblSyncLevelH1: TLabel;
    lblDigBit1: TLabel;
    lblSyncMode: TLabel;
    cbbSyncMode: TComboBox;
    cbbGroupMode: TComboBox;
    lblGroupMode: TLabel;
    seFrameSize: TSpinEdit;
    seHistSize: TSpinEdit;
    lblFrameSize: TLabel;
    lblHistSize: TLabel;
    lblAdcFreqDiv: TLabel;
    lblAdcDcm: TLabel;
    chkKeepaliveEn: TCheckBox;
    chkWriteAutoSusp: TCheckBox;
    grpResult: TGroupBox;
    grpFrameCntrs: TGroupBox;
    lblValidFrameCntr: TLabel;
    lblInvalidFrameCntr: TLabel;
    lblSyncSkip: TLabel;
    lblOverlapCntr: TLabel;
    lblInvalidHistCntr: TLabel;
    edtValidFrameCntr: TEdit;
    edtInvalidFrameCntr: TEdit;
    edtSyncSkipCntr: TEdit;
    edtOverlapCntr: TEdit;
    edtInvalidHistCntr: TEdit;
    edtCh1Avg: TEdit;
    edtCh2Avg: TEdit;
    lblCh1Avg: TLabel;
    lblCh2Avg: TLabel;
    btnFrameStart: TButton;
    lblFpgaLoadProgr: TLabel;
    edtAdcFreq: TEdit;
    edtFrameFreq: TEdit;
    procedure btnRefreshDevListClick(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnFrameStartClick(Sender: TObject);
  private
    { Private declarations }
    ltr210_list: array of TLTR_MODULE_LOCATION; //������ ��������� �������
    hltr210 : TLTR210; // ��������� ������, � ������� ���� ������
    load_progr : Boolean;  // �������, ��� ������ ���� �������� ��������

    thread : TLTR210_ProcessThread; //������ ������ ��� ���������� ����� ������
    threadRunning : Boolean; // �������, ������� �� ����� ����� ������


    procedure updateControls();
    procedure refreshDeviceList();
    procedure closeDevice();
    procedure updateProg(var hnd: TLTR210; done_size: LongWord; full_size : LongWord); stdcall;
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
  module_opened:=LTR210_IsOpened(hltr210)=LTR_OK;
  devsel := (Length(ltr210_list) > 0) and (cbbModulesList.ItemIndex >= 0);

  //���������� ������ ��������� � ����� ����� ������ ������ ���� �� ������� ���������� ����������
  btnRefreshDevList.Enabled := not module_opened;
  cbbModulesList.Enabled := not module_opened;

  //���������� ����� ����� ������ ���� ������� ����������
  btnOpen.Enabled := devsel and not load_progr;
  if module_opened then
    btnOpen.Caption := '������� ����������'
  else
    btnOpen.Caption := '���������� ����������';


  btnStart.Enabled := module_opened and not threadRunning and not load_progr;
  btnStop.Enabled := module_opened and threadRunning;
  //���������� ������ ����� ����� ����� ������ ��� SyncMode = LTR210_SYNC_MODE_INTERNAL
  btnFrameStart.Enabled := threadRunning and (hltr210.Cfg.SyncMode = LTR210_SYNC_MODE_INTERNAL);

  //��������� �������� �������� ������ ��� �������� ���������� � �� ���������� �����
  change_en:= module_opened and not threadRunning and not load_progr;
  chkChEn1.Enabled := change_en;
  chkChEn2.Enabled := change_en;
  cbbRange1.Enabled := change_en;
  cbbRange2.Enabled := change_en;
  cbbMode1.Enabled := change_en;
  cbbMode2.Enabled := change_en;
  edtSyncLevelL1.Enabled := change_en;
  edtSyncLevelL2.Enabled := change_en;
  edtSyncLevelH1.Enabled := change_en;
  edtSyncLevelH2.Enabled := change_en;
  cbbDigBit1.Enabled := change_en;
  cbbDigBit2.Enabled := change_en;
  seFrameSize.Enabled := change_en;
  seHistSize.Enabled := change_en;
  edtAdcFreq.Enabled := change_en;
  edtFrameFreq.Enabled := change_en;
  cbbSyncMode.Enabled := change_en;
  cbbGroupMode.Enabled := change_en;
  chkKeepaliveEn.Enabled := change_en;
  chkWriteAutoSusp.Enabled := change_en;
end;

procedure TMainForm.updateProg(var hnd: TLTR210; done_size: LongWord; full_size : LongWord); stdcall
var
  pos : Word;
begin
  //��������� ProgressBar � ������������ � ��������� �������� ��������
  pos :=  Round(100.0*done_size/full_size);
  pbFpgaLoad.Position := pos;
  //����� ��������� ������������ � ���������� ��������� ��������� ��������� ����������
  Application.ProcessMessages;
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
  SetLength(ltr210_list, 0);

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
                if mids[module_ind]=MID_LTR210 then
                begin
                    // ��������� ���������� � ��������� ������, ����������� ���
                    // ������������ ������������ ���������� � ���, � ������
                    modules_cnt:=modules_cnt+1;
                    SetLength(ltr210_list, modules_cnt);
                    ltr210_list[modules_cnt-1].csn := serial_list[crate_ind];
                    ltr210_list[modules_cnt-1].slot := module_ind+CC_MODULE1;
                    // � ��������� � ComboBox ��� ����������� ������ �������
                    cbbModulesList.Items.Add('����� ' + ltr210_list[modules_cnt-1].csn +
                                            ', ���� ' + IntToStr(ltr210_list[modules_cnt-1].slot));
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

procedure TMainForm.closeDevice();
begin
  // ��������� ����� � �������� ���������� ������
  if threadRunning then
  begin
    thread.stop:=True;
    thread.WaitFor;
  end;

  LTR210_Close(hltr210);
end;


//�������, ���������� �� ���������� ������ ����� ������
//��������� ����� ������, ������������� threadRunning
procedure TMainForm.OnThreadTerminate(par : TObject);
begin
    if thread.err <> LTR_OK then
    begin
        MessageDlg('���� ������ �������� � �������: ' + LTR210_GetErrorString(thread.err),
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
  if LTR210_IsOpened(hltr210)<>LTR_OK then
  begin
    // ���������� � ������ � ����� ����� �� ������������ ������ �� �������
    // ������� ��������� ������
    location := ltr210_list[ cbbModulesList.ItemIndex ];
    LTR210_Init(hltr210);
    res:=LTR210_Open(hltr210, SADDR_DEFAULT, SPORT_DEFAULT, location.csn, location.slot);
    if res<>LTR_OK then
      MessageDlg('�� ������� ���������� ����� � �������: ' + LTR210_GetErrorString(res), mtError, [mbOK], 0)
    else
    begin
      if LTR210_FPGAIsLoaded(hltr210) <> LTR_OK then
      begin
        load_progr:=True;
        updateControls;

        { ��������� ��������, ���������� � ����������. ��� ����������� ���������
          ���������� ���������� ����� ������. ����� �� ���������� ��� ����, ���
          ��������� �� ��� ������ � ����� ���������� ������ ����������, � ������
          �������� ��������� ������� ���������� ��������, ��� �� �������
          � �������� 4-�� �������� LTR210_LoadFPGA(). ����� ������������ �
          ��������� ������� ��� ���������, �� � ��� ������ ���� ����� ��������
          �������������� ������ �������� ���� Pointer }
        res:=LTR210_LoadFPGA(hltr210, '', @TMainForm.updateProg, Self);//@pbFpgaLoad);

        load_progr:=False;
        updateControls;
        if res<>LTR_OK then
          MessageDlg('�� ������� ��������� �������� ����: ' + LTR210_GetErrorString(res), mtError, [mbOK], 0);
      end
      else
      begin
        //���� ���� �������� ����� ������������� ��������� �� 100%
        pbFpgaLoad.Position := 100;
      end;
    end;

    if res=LTR_OK then
    begin
      edtDevSerial.Text := hltr210.ModuleInfo.Serial;
      edtVerPld.Text := IntToStr(hltr210.ModuleInfo.VerPLD);
      edtVerFPGA.Text := IntToStr(hltr210.ModuleInfo.VerFPGA);
    end
    else
    begin
      LTR210_Close(hltr210);
    end;
  end
  else
  begin
    closeDevice;
  end;

  updateControls();
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  load_progr:=False;
  LTR210_Init(hltr210);
  refreshDeviceList;   
end;

procedure TMainForm.btnStartClick(Sender: TObject);
var
  res: Integer;
  freq : double;
begin
  { ��������� �������� �� ��������� ���������� � ���������������
    ���� ��������� ������. ��� �������� ����� �� �������� ���. ��������, ���
    ������� ������ ��������... }

  hltr210.Cfg.Ch[0].Enabled := chkChEn1.Checked;
  hltr210.Cfg.Ch[1].Enabled := chkChEn2.Checked;

  hltr210.Cfg.Ch[0].Range := cbbRange1.ItemIndex;
  hltr210.Cfg.Ch[1].Range := cbbRange2.ItemIndex;

  hltr210.Cfg.Ch[0].Mode := cbbMode1.ItemIndex;
  hltr210.Cfg.Ch[1].Mode := cbbMode2.ItemIndex;

  hltr210.Cfg.Ch[0].SyncLevelL := StrToFloat(edtSyncLevelL1.Text);
  hltr210.Cfg.Ch[1].SyncLevelL := StrToFloat(edtSyncLevelL2.Text);
  hltr210.Cfg.Ch[0].SyncLevelH := StrToFloat(edtSyncLevelH1.Text);
  hltr210.Cfg.Ch[1].SyncLevelH := StrToFloat(edtSyncLevelH2.Text);

  hltr210.Cfg.Ch[0].DigBitMode := cbbDigBit1.ItemIndex;
  hltr210.Cfg.Ch[1].DigBitMode := cbbDigBit2.ItemIndex;

  hltr210.Cfg.SyncMode  := cbbSyncMode.ItemIndex;
  hltr210.Cfg.GroupMode := cbbGroupMode.ItemIndex;
  hltr210.Cfg.FrameSize := seFrameSize.Value;
  hltr210.Cfg.HistSize  := seHistSize.Value;




  hltr210.Cfg.Flags := 0;
  if chkKeepaliveEn.Checked then
    hltr210.Cfg.Flags := hltr210.Cfg.Flags or LTR210_CFG_FLAGS_KEEPALIVE_EN;
  if chkWriteAutoSusp.Checked then
    hltr210.Cfg.Flags := hltr210.Cfg.Flags or LTR210_CFG_FLAGS_WRITE_AUTO_SUSP;

  res:=LTR210_FillAdcFreq(  hltr210.Cfg, StrToFloat(edtAdcFreq.Text), 0);
  if res = LTR_OK then
    res:=LTR210_FillFrameFreq(  hltr210.Cfg, StrToFloat(edtFrameFreq.Text));
  if res = LTR_OK then
    res:= LTR210_SetADC(hltr210);
  if res <> LTR_OK then
     MessageDlg('�� ������� ���������� ���������: ' + LTR210_GetErrorString(res), mtError, [mbOK], 0);

  { �� ���������� ������ �������� ��������� ��������� ������������ ���� ��� ��� ���������  }
  if res = LTR_OK then
  begin
    res:= LTR210_MeasAdcZeroOffset(hltr210, 0);
    if res <> LTR_OK then
      MessageDlg('�� ������� ��������� ��������� ������������ ����: ' + LTR210_GetErrorString(res), mtError, [mbOK], 0);
  end;

  if res = LTR_OK then
  begin
    if thread <> nil then
    begin
      FreeAndNil(thread);
    end;

    { ��������� �������� ������ �� ������� ������������� }
    edtAdcFreq.Text := FloatToStrF(hltr210.State.AdcFreq, ffFixed	, 8, 2);
    if hltr210.Cfg.SyncMode = LTR210_SYNC_MODE_PERIODIC then
      edtFrameFreq.Text := FloatToStrF(hltr210.State.FrameFreq, ffFixed	, 8, 2);

    thread := TLTR210_ProcessThread.Create(True);
    { ��� ��� ��������� ������ ���� ���� � �� ��, ��� ������������ �������,
     ��� � ������ ��������� ����, �� ��������� �������� �� ��� pointer }
    thread.phltr210 := @hltr210;
    { ��������� �������� ����������, ������� ������ ���������� ��������������
      ������� � ����� ������ }
    thread.edtValidFrameCntr := edtValidFrameCntr;
    thread.edtInvalidFrameCntr := edtInvalidFrameCntr;
    thread.edtSyncSkipCntr := edtSyncSkipCntr;
    thread.edtOverlapCntr := edtOverlapCntr;
    thread.edtInvalidHistCntr := edtInvalidHistCntr;
    thread.edtChAvg[0]:=edtCh1Avg;
    thread.edtChAvg[1]:=edtCh2Avg;




    { ������������� ������� �� ������� ���������� ������ (� ���������,
    ����� ���������, ���� ����� ���������� ��� ��-�� ������ ��� �����
    ������) }
    thread.OnTerminate := OnThreadTerminate;
    thread.Resume; //��� Delphi 2010 � ���� ������������� ������������ Start
    threadRunning := True;

    updateControls;
  end;


end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
    // ������������� ������ �� ���������� ������
    if threadRunning then
        thread.stop:=True;
    btnStop.Enabled:= False;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  closeDevice;
  if thread <> nil then
    FreeAndNil(thread);
end;

procedure TMainForm.btnFrameStartClick(Sender: TObject);
var res : Integer;
begin
  res := LTR210_FrameStart(hltr210);
  if res <> LTR_OK then
     MessageDlg('�� ������� ��������� ����������� ������ �����: ' + LTR210_GetErrorString(res), mtError, [mbOK], 0)
end;

end.
