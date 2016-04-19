unit MainUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  ltrapi, ltrapitypes, ltrapidefine, ltr24api, LTR24_ProcessThread;

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
    lblVerPld: TLabel;
    lblVerFPGA: TLabel;
    edtDevSerial: TEdit;
    edtICPSupport: TEdit;
    edtVerPld: TEdit;
    grpConfig: TGroupBox;
    lblRange1: TLabel;
    lblChAc1: TLabel;
    lblDigBit1: TLabel;
    lblAdcFreq: TLabel;
    grpCfgCh1: TGroupBox;
    chkChEn1: TCheckBox;
    cbbRange1: TComboBox;
    cbbAC1: TComboBox;
    cbbICPMode1: TComboBox;
    cbbAdcFreq: TComboBox;
    chkTestModes: TCheckBox;
    cbbDataFmt: TComboBox;
    lblDataFmt: TLabel;
    cbbISrcValue: TComboBox;
    lblISrcVal: TLabel;
    lblChAc2: TLabel;
    grp1: TGroupBox;
    chkChEn2: TCheckBox;
    cbbRange2: TComboBox;
    cbbAC2: TComboBox;
    cbbICPMode2: TComboBox;
    grp2: TGroupBox;
    chkChEn3: TCheckBox;
    cbbRange3: TComboBox;
    cbbAC3: TComboBox;
    cbbICPMode3: TComboBox;
    grp3: TGroupBox;
    chkChEn4: TCheckBox;
    cbbRange4: TComboBox;
    cbbAC4: TComboBox;
    cbbICPMode4: TComboBox;
    grpResult: TGroupBox;
    edtCh1Avg: TEdit;
    edtCh2Avg: TEdit;
    edtCh3Avg: TEdit;
    edtCh4Avg: TEdit;
    procedure btnRefreshDevListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnOpenClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStopClick(Sender: TObject);
    procedure cfgChanged(Sender: TObject);

  private
    { Private declarations }
    ltr24_list: array of TLTR_MODULE_LOCATION; //������ ��������� �������
    hltr24 : TLTR24; // ��������� ������, � ������� ���� ������
    threadRunning : Boolean; // �������, ������� �� ����� ����� ������
    thread : TLTR24_ProcessThread; //������ ������ ��� ���������� ����� ������

    procedure updateControls();
    procedure refreshDeviceList();
    procedure closeDevice();
    procedure OnThreadTerminate(par : TObject);

    procedure assignComboList(comboBox: TComboBox; list : TStrings);
    procedure setRangeComboList(rangeBox: TComboBox; icpBox : TComboBox);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;



implementation

{$R *.dfm}

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
  SetLength(ltr24_list, 0);

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
                if mids[module_ind]=MID_LTR24 then
                begin
                    // ��������� ���������� � ��������� ������, ����������� ���
                    // ������������ ������������ ���������� � ���, � ������
                    modules_cnt:=modules_cnt+1;
                    SetLength(ltr24_list, modules_cnt);
                    ltr24_list[modules_cnt-1].csn := serial_list[crate_ind];
                    ltr24_list[modules_cnt-1].slot := module_ind+CC_MODULE1;
                    // � ��������� � ComboBox ��� ����������� ������ �������
                    cbbModulesList.Items.Add('����� ' + ltr24_list[modules_cnt-1].csn +
                                            ', ���� ' + IntToStr(ltr24_list[modules_cnt-1].slot));
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

// ���������� ��������� ComboBox'� � ����������� ���������� �������
procedure TMainForm.assignComboList(comboBox: TComboBox; list : TStrings);
var
  index : Integer;
begin
  index := comboBox.ItemIndex;
  comboBox.Items.Assign(list);
  comboBox.ItemIndex := index;
end;


// ��������� ������� ������ � ���� ������ ��������� � ����������� �� ����, ������� �� ICP-�����
procedure TMainForm.setRangeComboList(rangeBox: TComboBox; icpBox : TComboBox);
var
  rangeStrings : TStrings;
begin
  rangeStrings := TStringList.Create;
  if icpBox.ItemIndex = 0 then
  begin
    rangeStrings.Add(String('+/- 2�'));
    rangeStrings.Add(String('+/- 10�'));
  end
  else
  begin
    rangeStrings.Add(String('~ 1�'));
    rangeStrings.Add(String('~ 5�'));
  end;
  assignComboList(rangeBox, rangeStrings);
  rangeStrings.Destroy;
end;


procedure TMainForm.updateControls();
var
  module_opened, devsel, cfg_en, icp_support: Boolean;
  modeStrings : TStrings;

begin
  module_opened:=LTR24_IsOpened(hltr24)=LTR_OK;
  devsel := (Length(ltr24_list) > 0) and (cbbModulesList.ItemIndex >= 0);

  icp_support := hltr24.ModuleInfo.SupportICP;

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
  cfg_en:= module_opened and not threadRunning;


  cbbAdcFreq.Enabled := cfg_en;
  cbbDataFmt.Enabled := cfg_en;
  cbbISrcValue.Enabled := cfg_en and icp_support;
  chkTestModes.Enabled := cfg_en;

  //���� ��� ��������� ICP, �� ���� ��� ��������� ICP-�����, ���������� �� ���. ����
  if cfg_en and not icp_support then
  begin
     cbbICPMode1.ItemIndex := 0;
     cbbICPMode2.ItemIndex := 0;
     cbbICPMode3.ItemIndex := 0;
     cbbICPMode4.ItemIndex := 0;
  end;


  chkChEn1.Enabled := cfg_en;
  chkChEn2.Enabled := cfg_en;
  chkChEn3.Enabled := cfg_en;
  chkChEn4.Enabled := cfg_en;

  cbbRange1.Enabled := cfg_en;
  cbbRange2.Enabled := cfg_en;
  cbbRange3.Enabled := cfg_en;
  cbbRange4.Enabled := cfg_en;

  // AC �� ����� �������� ��� ICP-������ => ������ ������
  cbbAC1.Enabled := cfg_en and (cbbICPMode1.ItemIndex=0);
  cbbAC2.Enabled := cfg_en and (cbbICPMode2.ItemIndex=0);
  cbbAC3.Enabled := cfg_en and (cbbICPMode3.ItemIndex=0);
  cbbAC4.Enabled := cfg_en and (cbbICPMode4.ItemIndex=0);

  cbbICPMode1.Enabled := cfg_en and icp_support;
  cbbICPMode2.Enabled := cfg_en and icp_support;
  cbbICPMode3.Enabled := cfg_en and icp_support;
  cbbICPMode4.Enabled := cfg_en and icp_support;

  { � ����������� �� ����, ������ �� �������� ����� ���
    �������, ������������� ��������������� �������� ��������� ComboBox'�.
    ��� ���� ��������� ������ ���������� �������� ���������� }
  modeStrings := TStringList.Create;
  if chkTestModes.Checked then
  begin
    modeStrings.Add(String('������. ����'));
    modeStrings.Add(String('ICP ����'));
  end
  else
  begin
    modeStrings.Add(String('���. ����'));
    modeStrings.Add(String('ICP ����'));
  end;

  assignComboList(cbbICPMode1, modeStrings);
  assignComboList(cbbICPMode2, modeStrings);
  assignComboList(cbbICPMode3, modeStrings);
  assignComboList(cbbICPMode4, modeStrings);
  modeStrings.Destroy;


  setRangeComboList(cbbRange1, cbbICPMode1);
  setRangeComboList(cbbRange2, cbbICPMode2);
  setRangeComboList(cbbRange3, cbbICPMode3);
  setRangeComboList(cbbRange4, cbbICPMode4);


end;

procedure TMainForm.closeDevice();
begin
  // ��������� ����� � �������� ���������� ������
  if threadRunning then
  begin
    thread.stop:=True;
    thread.WaitFor;
  end;

  LTR24_Close(hltr24);
end;

//�������, ���������� �� ���������� ������ ����� ������
//��������� ����� ������, ������������� threadRunning
procedure TMainForm.OnThreadTerminate(par : TObject);
begin
    if thread.err <> LTR_OK then
    begin
        MessageDlg('���� ������ �������� � �������: ' + LTR24_GetErrorString(thread.err),
                  mtError, [mbOK], 0);
    end;

    threadRunning := false;
    updateControls;
end;


procedure TMainForm.btnRefreshDevListClick(Sender: TObject);
begin
  refreshDeviceList
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LTR24_Init(hltr24);
  refreshDeviceList;
end;

procedure TMainForm.btnOpenClick(Sender: TObject);
var
  location :  TLTR_MODULE_LOCATION;
  res : Integer;
begin
  // ���� ���������� � ������� ������� - �� ��������� �����
  if LTR24_IsOpened(hltr24)<>LTR_OK then
  begin
    // ���������� � ������ � ����� ����� �� ������������ ������ �� �������
    // ������� ��������� ������
    location := ltr24_list[ cbbModulesList.ItemIndex ];
    LTR24_Init(hltr24);
    res:=LTR24_Open(hltr24, SADDR_DEFAULT, SPORT_DEFAULT, location.csn, location.slot);
    if res<>LTR_OK then
      MessageDlg('�� ������� ���������� ����� � �������: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

    if res=LTR_OK then
    begin
      // ������ ���������� �� Flash-������ (������� ������������� ������������) 
      res:=LTR24_GetConfig(hltr24);
      if res <> LTR_OK then
        MessageDlg('�� ������� ��������� ������������ �� ������: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);
    end;

    if res=LTR_OK then
    begin
      edtDevSerial.Text := String(hltr24.ModuleInfo.Serial);
      edtVerPld.Text := IntToStr(hltr24.ModuleInfo.VerPLD);
      if hltr24.ModuleInfo.SupportICP then
        edtICPSupport.Text := '����'
      else
        edtICPSupport.Text := '���';
    end
    else
    begin
      LTR24_Close(hltr24);
    end;
  end
  else
  begin
    closeDevice;
  end;

  updateControls;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
var
  res : Integer;
begin
   { ��������� �������� �� ��������� ���������� � ���������������
    ���� ��������� ������. ��� �������� ����� �� �������� ���. ��������, ���
    ������� ������ ��������... }
   hltr24.ADCFreqCode := cbbAdcFreq.ItemIndex;
   hltr24.DataFmt     := cbbDataFmt.ItemIndex;
   hltr24.ISrcValue   := cbbISrcValue.ItemIndex;
   hltr24.TestMode    := chkTestModes.Checked;

   hltr24.ChannelMode[0].Enable   := chkChEn1.Checked;
   hltr24.ChannelMode[0].AC       := cbbAC1.ItemIndex <> 0;
   hltr24.ChannelMode[0].Range    := cbbRange1.ItemIndex;
   hltr24.ChannelMode[0].ICPMode  := cbbICPMode1.ItemIndex <> 0;

   hltr24.ChannelMode[1].Enable   := chkChEn2.Checked;
   hltr24.ChannelMode[1].AC       := cbbAC2.ItemIndex <> 0;
   hltr24.ChannelMode[1].Range    := cbbRange2.ItemIndex;
   hltr24.ChannelMode[1].ICPMode  := cbbICPMode2.ItemIndex <> 0;

   hltr24.ChannelMode[2].Enable   := chkChEn3.Checked;
   hltr24.ChannelMode[2].AC       := cbbAC3.ItemIndex <> 0;
   hltr24.ChannelMode[2].Range    := cbbRange3.ItemIndex;
   hltr24.ChannelMode[2].ICPMode  := cbbICPMode3.ItemIndex <> 0;

   hltr24.ChannelMode[3].Enable   := chkChEn4.Checked;
   hltr24.ChannelMode[3].AC       := cbbAC4.ItemIndex <> 0;
   hltr24.ChannelMode[3].Range    := cbbRange4.ItemIndex;
   hltr24.ChannelMode[3].ICPMode  := cbbICPMode4.ItemIndex <> 0;

   res:= LTR24_SetADC(hltr24);
   if res <> LTR_OK then
      MessageDlg('�� ������� ���������� ���������: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

  if res = LTR_OK then
  begin
    if thread <> nil then
    begin
      FreeAndNil(thread);
    end;

    thread := TLTR24_ProcessThread.Create(True);
    { ��� ��� ��������� ������ ���� ���� � �� ��, ��� ������������ �������,
     ��� � ������ ��������� ����, �� ��������� �������� �� ��� pointer }
    thread.phltr24 := @hltr24;
    { ��������� �������� ����������, ������� ������ ���������� ��������������
      ������� � ����� ������ }
    thread.edtChAvg[0]:=edtCh1Avg;
    thread.edtChAvg[1]:=edtCh2Avg;
    thread.edtChAvg[2]:=edtCh3Avg;
    thread.edtChAvg[3]:=edtCh4Avg;


    { ������������� ������� �� ������� ���������� ������ (� ���������,
    ����� ���������, ���� ����� ���������� ��� ��-�� ������ ��� �����
    ������) }
    thread.OnTerminate := OnThreadTerminate;
    thread.Resume; //��� Delphi 2010 � ���� ������������� ������������ Start
    threadRunning := True;

    updateControls;
  end;


end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  closeDevice;
  if thread <> nil then
    FreeAndNil(thread);
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
   // ������������� ������ �� ���������� ������
    if threadRunning then
        thread.stop:=True;
    btnStop.Enabled:= False;
end;

procedure TMainForm.cfgChanged(Sender: TObject);
begin
  updateControls();
end;

end.
