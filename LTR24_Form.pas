unit LTR24_Form;

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

const
 ChanelsAmount: integer = 2;
type
  TMainForm = class(TForm)
    btnStart: TButton;
    btnStop: TButton;
    grpConfig: TGroupBox;
    lblRange1: TLabel;
    lblChAc1: TLabel;
    lblAdcFreq: TLabel;
    cbbRange1: TComboBox;
    cbbAC1: TComboBox;
    cbbAdcFreq: TComboBox;
    cbbDataFmt: TComboBox;
    lblDataFmt: TLabel;
    lblChAc2: TLabel;
    grpResult: TGroupBox;
    edtCh1Avg: TEdit;
    edtCh2Avg: TEdit;
    edtCh3Avg: TEdit;
    edtCh4Avg: TEdit;
    procedure btnRefreshDevListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);

    procedure btnStartClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure btnStopClick(Sender: TObject);
    procedure cfgChanged(Sender: TObject);
    procedure edtDevSerial2Change(Sender: TObject);

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

    procedure Open();
    procedure assignComboList(comboBox: TComboBox; list : TStrings);
    procedure setRangeComboList(rangeBox: TComboBox; icpBox : TComboBox);
  public
    { Public declarations }
  end;

var
  Form24: TMainForm;



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
                end;
              end;
          end;
          //��������� ���������� � �������
          LTR_Close(crate);
        end;
      end;
    end;

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
  devsel := (Length(ltr24_list) > 0);

  icp_support := hltr24.ModuleInfo.SupportICP;

  btnStart.Enabled := module_opened and not threadRunning;
  btnStop.Enabled := module_opened and threadRunning;

  //��������� �������� �������� ������ ��� �������� ���������� � �� ���������� �����
  cfg_en:= module_opened and not threadRunning;


  cbbAdcFreq.Enabled := cfg_en;
  cbbDataFmt.Enabled := cfg_en;
  cbbRange1.Enabled := cfg_en;

  { � ����������� �� ����, ������ �� �������� ����� ���
    �������, ������������� ��������������� �������� ��������� ComboBox'�.
    ��� ���� ��������� ������ ���������� �������� ���������� }
  modeStrings := TStringList.Create;

    modeStrings.Add(String('���. ����'));
    modeStrings.Add(String('ICP ����'));

  modeStrings.Destroy;
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

procedure TMainForm.edtDevSerial2Change(Sender: TObject);
begin

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
  Open();
end;

procedure TMainForm.Open();
var
  location :  TLTR_MODULE_LOCATION;
  res : Integer;
begin
  // ���� ���������� � ������� ������� - �� ��������� �����
  if LTR24_IsOpened(hltr24)<>LTR_OK then
  begin
    // ���������� � ������ � ����� ����� �� ������������ ������ �� �������
    // ������� ��������� ������
    location := ltr24_list[ 0 ];
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

    if res<>LTR_OK then
      LTR24_Close(hltr24);
  end
  else
    closeDevice;

  updateControls;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
var
  i, res : Integer;
begin
   { ��������� �������� �� ��������� ���������� � ���������������
    ���� ��������� ������. ��� �������� ����� �� �������� ���. ��������, ���
    ������� ������ ��������... }
   hltr24.ADCFreqCode := cbbAdcFreq.ItemIndex;
   hltr24.DataFmt     := cbbDataFmt.ItemIndex;
   hltr24.ISrcValue   := 0;
   hltr24.TestMode    := false; //��������� ����

   for i := 0 to ChanelsAmount - 1 do
   begin
    hltr24.ChannelMode[i].Enable   := true;
    hltr24.ChannelMode[i].AC       := cbbAC1.ItemIndex <> 0;
    hltr24.ChannelMode[i].Range    := cbbRange1.ItemIndex;
    hltr24.ChannelMode[i].ICPMode  := false;
   end;
   for i := ChanelsAmount to 3 do
    hltr24.ChannelMode[i].Enable   := false;


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
