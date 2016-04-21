unit EU2_Form;
interface uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FileCtrl, StdCtrls, Buttons, ExtCtrls,
  Math, TeeProcs, TeEngine, Chart, Series, ComCtrls,
  ltrapi, ltrapitypes, ltrapidefine, ltr24api, LTR24_ProcessThread;

{ ����������, ����������� ��� ������������ ���������� � ������� }
type TLTR_MODULE_LOCATION = record
  csn : string; //�������� ����� ������
  slot : Word; //����� �����
end;

const
  DevicesAmount     = 1;
  ChannelsPerDevice = 2;
  ChannelsAmount    = DevicesAmount*ChannelsPerDevice;

type
  TMainForm = class(TForm)
    bnStart:  TButton;
    txWorkTime: TEdit;
    lbWorkTime: TLabel;
    chGraph: TChart;
    Series1: TFastLineSeries;
    StatusBar1: TStatusBar;
    Label1: TLabel;
    txPath: TEdit;
    cbTimeMetric: TComboBox;
    Button1: TButton;
    chGraph2: TChart;
    FastLineSeries1: TFastLineSeries;
    Label2: TLabel;
    Edit1: TEdit;
    CheckBox1: TCheckBox;
    grpConfig: TGroupBox;
    lblRange1: TLabel;
    lblChAc1: TLabel;
    lblAdcFreq: TLabel;
    lblDataFmt: TLabel;
    lblChAc2: TLabel;
    cbbAdcFreq: TComboBox;
    cbbDataFmt: TComboBox;
    cbbAC1: TComboBox;
    cbbRange1: TComboBox;
    procedure FormDestroy(Sender: TObject);

    private
      ltr24_list: array of TLTR_MODULE_LOCATION; //������ ��������� �������
      hltr24 : TLTR24; // ��������� ������, � ������� ���� ������
      threadRunning : Boolean; // �������, ������� �� ����� ����� ������
      thread : TLTR24_ProcessThread; //������ ������ ��� ���������� ����� ������
      Files : array[0..ChannelsAmount] of TextFile;

      procedure refreshDeviceList();
      procedure closeDevice();
      procedure OnThreadTerminate(par : TObject);
      procedure OpenCreate();
      procedure StartProcess();
      procedure CreateFiles();
    published
      procedure Button1Click(Sender: TObject);
      procedure bnStartClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
  end;

var
  MainForm:     TMainForm;

//  Files :       array[0..ChannelsAmount] of TextFile;

implementation
{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var newDir: string;
begin
 SelectDirectory(newDir,[],0);
 txPath.Text:= newDir;
end;

procedure TMainForm.bnStartClick(Sender: TObject);
var i: integer;
begin
  if (bnStart.Caption = '�����') then begin
     bnStart.Caption := '����';
    CreateFiles();
    StartProcess();

  end else begin
    bnStart.Caption := '�����';
    if threadRunning then
      thread.stop:=True;


  end;
end;
//----------------------------------------------------------------
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
      bnStartClick(par);
    end;

    threadRunning := false;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LTR24_Init(hltr24);
  refreshDeviceList;
  OpenCreate();
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  closeDevice;
  if thread <> nil then
    FreeAndNil(thread);
end;

procedure TMainForm.OpenCreate();
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
end;

procedure TMainForm.StartProcess();
var
  i, res : Integer;
  MilisecsWork:  Int64; 
begin
   { ��������� �������� �� ��������� ���������� � ���������������
    ���� ��������� ������. ��� �������� ����� �� �������� ���. ��������, ���
    ������� ������ ��������... }
   hltr24.ADCFreqCode := cbbAdcFreq.ItemIndex;
   hltr24.DataFmt     := cbbDataFmt.ItemIndex;
   hltr24.ISrcValue   := 0;
   hltr24.TestMode    := false; //��������� ����

   for i := 0 to ChannelsAmount - 1 do
   begin
    hltr24.ChannelMode[i].Enable   := true;
    hltr24.ChannelMode[i].AC       := cbbAC1.ItemIndex <> 0;
    hltr24.ChannelMode[i].Range    := cbbRange1.ItemIndex;
    hltr24.ChannelMode[i].ICPMode  := false;
   end;
   for i := ChannelsAmount to 3 do
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
    thread.visChAvg[0]:= chGraph;
    thread.visChAvg[1]:= chGraph2;

    thread.Files := @Files;

    MilisecsWork := StrToInt(txWorkTime.Text);  // ����� ����� ������ � �������, ������� 1 ������!!!
    if cbTimeMetric.Text = '�����' then
      MilisecsWork := MilisecsWork*60;
    if cbTimeMetric.Text = '����' then
      MilisecsWork := MilisecsWork*60*24;

    thread.MilisecsToWork := MilisecsWork*60*1000;
    { ������������� ������� �� ������� ���������� ������ (� ���������,
    ����� ���������, ���� ����� ���������� ��� ��-�� ������ ��� �����
    ������) }
    thread.OnTerminate := OnThreadTerminate;
    thread.Resume; //��� Delphi 2010 � ���� ������������� ������������ Start
    threadRunning := True;
  end;

  end;
procedure TMainForm.CreateFiles;
var
  TimeMark, Path: string;
  i,deviceN,fileIndex: integer;
begin
  TimeSeparator := '-';
  TimeMark := DateToStr(Now) + TimeSeparator + TimeToStr(Now);
  TimeMark := StringReplace(TimeMark, '/', TimeSeparator, [rfReplaceAll]);
  TimeMark := StringReplace(TimeMark, ' ', TimeSeparator, [rfReplaceAll]);
  Path:= txPath.Text+'\EU2.' + cbbAdcFreq.Text + '.' + TimeMark;
  System.MkDir(Path);

  for deviceN := 0 to DevicesAmount-1 do  begin
    for i := 0 to ChannelsPerDevice-1 do begin
      fileIndex :=   i+deviceN*(ChannelsPerDevice);
      System.Assign(Files[fileIndex], Path + '\Device'+
         InttoStr(deviceN) +'-Cn' + InttoStr(i) + '.txt');
      ReWrite(Files[fileIndex]);
    end;
  end;
end;
end.
