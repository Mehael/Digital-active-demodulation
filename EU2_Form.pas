unit EU2_Form;
interface uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FileCtrl, StdCtrls, Buttons, ExtCtrls,
  Math, TeeProcs, TeEngine, Chart, Series, ComCtrls,
  ltrapi, ltrapitypes, ltrapidefine, ltr24api, ltr34api, ProcessThread, Config,
  Spin, Registry;

{ ����������, ����������� ��� ������������ ���������� � ������� }
type TLTR_MODULE_LOCATION = record
  csn : string; //�������� ����� ������
  slot : Word; //����� �����
end;

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
    Panel1: TPanel;
    Panel2: TPanel;
    Label3: TLabel;
    skipVal: TEdit;
    Label4: TLabel;
    PercentEdit: TSpinEdit;
    Label5: TLabel;
    TimerText: TLabel;
    Timer1: TTimer;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    cbbAC1: TComboBox;
    cbbAdcFreq: TComboBox;
    cbbDataFmt: TComboBox;
    cbbRange1: TComboBox;
    lblAdcFreq: TLabel;
    lblChAc1: TLabel;
    lblChAc2: TLabel;
    lblDataFmt: TLabel;
    lblRange1: TLabel;
    TabSheet2: TTabSheet;
    Label6: TLabel;
    Label7: TLabel;
    TabSheet3: TTabSheet;
    TabSheet4: TTabSheet;
    TabSheet6: TTabSheet;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    Label8: TLabel;
    Edit2: TEdit;
    Label9: TLabel;
    Edit3: TEdit;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    Label13: TLabel;
    Label14: TLabel;
    Label15: TLabel;
    Edit4: TEdit;
    Label16: TLabel;
    Label17: TLabel;
    Label18: TLabel;
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);

    private
      ltr_list: array[0..1] of TLTR_MODULE_LOCATION; //������ ��������� ������� 0-24, 1 - 34
      hltr_24 : TLTR24; // ��������� ������, � ������� ���� ������
      hltr_34 : TLTR34;
      threadRunning : Boolean; // �������, ������� �� ����� ����� ������
      thread : TProcessThread; //������ ������ ��� ���������� ����� ������
      secondsToWork: integer;

      procedure refreshDeviceList();
      procedure closeDevice();
      procedure OnThreadTerminate(par : TObject);
      procedure Open24Ltr();
      procedure StartProcess();
      procedure open34Ltr;
      procedure CheckError(err: Integer);
    published
      procedure Button1Click(Sender: TObject);
      procedure bnStartClick(Sender: TObject);
      procedure FormCreate(Sender: TObject);
  end;

var
  MainForm:     TMainForm;

implementation
{$R *.dfm}

procedure TMainForm.Button1Click(Sender: TObject);
var newDir: string;
begin
 SelectDirectory(newDir,[],0);
 txPath.Text:= newDir;
end;

procedure TMainForm.bnStartClick(Sender: TObject);
begin
  if (bnStart.Caption = '�����') then begin
     bnStart.Caption := '����';

    StartProcess();

  end else begin
    if threadRunning then
      Timer1.Enabled := false;
      TimerText.Caption:= '';
      thread.stop:=True;

  end;
end;

procedure TMainForm.refreshDeviceList();
var
  srv : TLTR; //��������� ��� ������������ ���������� � LTR-��������
  crate: TLTR; //��������� ��� ���������� � �������
  res, crates_cnt, crate_ind, module_ind: integer;
  serial_list : array [0..CRATE_MAX-1] of string; //������ ������� �������
  mids : array [0..MODULE_MAX-1] of Word; //������ ��������������� ������� ��� �������� ������
begin
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
                if mids[module_ind]=MID_LTR34 then
                begin
                    ltr_list[1].csn := crate.csn;
                    ltr_list[1].slot := module_ind+CC_MODULE1;
                end;

                if mids[module_ind]=MID_LTR24 then
                begin
                    ltr_list[0].csn := serial_list[crate_ind];
                    ltr_list[0].slot := module_ind+CC_MODULE1;
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
  DeleteCriticalSection(HistorySection);
  DeleteCriticalSection(DACSection);

  LTR24_Close(hltr_24);
  LTR34_Close(@hltr_34);
end;

//�������, ���������� �� ���������� ������ ����� ������
//��������� ����� ������, ������������� threadRunning
procedure TMainForm.OnThreadTerminate(par : TObject);
begin
    if thread.err <> LTR_OK then
        MessageDlg('���� ������ �������� � �������: ' + LTR24_GetErrorString(thread.err),
                  mtError, [mbOK], 0);

    threadRunning := false;
end;

procedure TMainForm.FormCreate(Sender: TObject);
  Var Reestr: TRegistry;
begin
  LTR24_Init(hltr_24);
  LTR34_Init(@hltr_34);
  refreshDeviceList;

  DecimalSeparator := '.';
  InitializeCriticalSection(HistorySection);
  InitializeCriticalSection(DACSection);

  Open24Ltr();
  Open34Ltr();

 Reestr:=TRegistry.Create;
 Reestr.RootKey:=HKEY_CURRENT_USER;
 If Reestr.OpenKey('\SoftWare\LTREU2\', False) Then
   Begin
     txWorkTime.Text := Reestr.ReadString('txWorkTime');
     cbTimeMetric.ItemIndex := Reestr.ReadInteger('cbTimeMetric');
     txPath.Text := Reestr.ReadString('txPath');
     skipVal.Text := Reestr.ReadString('skipVal');

     txPath.Text := Reestr.ReadString('txPath');
     Edit1.Text := Reestr.ReadString('Edit1');
     Edit2.Text := Reestr.ReadString('Edit2');
     Edit3.Text := Reestr.ReadString('Edit3');
     Edit4.Text := Reestr.ReadString('Edit4');

     CheckBox1.Checked := Reestr.ReadBool('CheckBox1');
     CheckBox2.Checked := Reestr.ReadBool('CheckBox2');
     CheckBox3.Checked := Reestr.ReadBool('CheckBox3');

     PercentEdit.Value := Reestr.ReadInteger('PercentEdit');

     cbbAC1.ItemIndex := Reestr.ReadInteger('cbbAC1');
     cbbAdcFreq.ItemIndex := Reestr.ReadInteger('cbbAdcFreq');
     cbbDataFmt.ItemIndex := Reestr.ReadInteger('cbbDataFmt');
     cbbRange1.ItemIndex := Reestr.ReadInteger('cbbRange1');

     Reestr.CloseKey;
   End;
 Reestr.Free;
end;

procedure TMainForm.CheckError(err: Integer);
begin
  if err < LTR_OK then
    MessageDlg('LTR34: ' + LTR34_GetErrorString(err), mtError, [mbOK], 0);
end;

procedure TMainForm.open34Ltr;
var i:integer;
    err:integer;
    CrateSelect:byte;
    MID:array[0..MODULE_MAX-1]of WORD;
    LIST34:array[0..MODULE_MAX-1]of byte;
    Total34:byte;
    LTR34SELECT:byte;
    LTR: TLTR;
    CSNLIST:array[0..CRATE_MAX-1,0..SERIAL_NUMBER_SIZE-1]of char;
begin
  //���������� ������ ������� ������������ � ����� ���������� (LocalHost 127.0.0.1)
  for i:=0 to CRATE_MAX-1 do CSNLIST[i]:='';
  LTR_Init(@LTR);
  err:=LTR_Open(@LTR);                      CheckError(err);
  err:=LTR_GetCrates(@LTR,@CSNLIST[0,0]);   CheckError(err);

  CrateSelect:=0;//���������� ������ �������� LTR �����
  For i:=0 to CRATE_MAX-1 do

  err:=LTR_Close(@LTR);                     CheckError(err);
  //���� ������ � ��������� ������
  LTR_Init(@LTR);
  for i:=0 to SERIAL_NUMBER_SIZE-1 do
  LTR.csn[i]:=CSNLIST[CrateSelect][i];

  err:=LTR_Open(@LTR);                      CheckError(err);
  err:=LTR_GetCrateModules(@LTR,@MID[0]);   CheckError(err);
  Total34:=0;
  //���������� ������ �������
  for i:=0 to MODULE_MAX-1 do
  begin
    if MID[i]=MID_LTR34 then
      begin
        LIST34[Total34]:=i;
        Total34:=Total34+1;
      end;
  end;
  LTR34SELECT:=0;//������ ��������� LTR34
  //  ������������ � ���������� ������
  CheckError(LTR34_Init(@hltr_34));
  err:=LTR34_Open(@hltr_34,LTR.saddr,LTR.sport,@CSNLIST[CrateSelect][0],LIST34[LTR34SELECT]+1);
  CheckError(err);
  CheckError(LTR34_TestEEPROM(@hltr_34))
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
  Var Reestr: TRegistry;
begin
 Reestr:=TRegistry.Create;
 Reestr.RootKey:=HKEY_CURRENT_USER;
 If Reestr.OpenKey('\SoftWare\LTREU2\', True) Then
   Begin
     Reestr.WriteString('txWorkTime', txWorkTime.Text);
     Reestr.WriteInteger('cbTimeMetric', cbTimeMetric.ItemIndex);
     Reestr.WriteString('txPath', txPath.Text);
     Reestr.WriteString('skipVal', skipVal.Text);

     Reestr.WriteString('txPath', txPath.Text);
     Reestr.WriteString('Edit1', Edit1.Text);
     Reestr.WriteString('Edit2', Edit2.Text);
     Reestr.WriteString('Edit3', Edit3.Text);
     Reestr.WriteString('Edit4', Edit4.Text);

     Reestr.WriteBool('CheckBox1', CheckBox1.Checked);
     Reestr.WriteBool('CheckBox2', CheckBox2.Checked);
     Reestr.WriteBool('CheckBox3', CheckBox3.Checked);

     Reestr.WriteInteger('PercentEdit', PercentEdit.Value);

     Reestr.WriteInteger('cbbAC1', cbbAC1.ItemIndex);
     Reestr.WriteInteger('cbbAdcFreq', cbbAdcFreq.ItemIndex);
     Reestr.WriteInteger('cbbDataFmt', cbbDataFmt.ItemIndex);
     Reestr.WriteInteger('cbbRange1', cbbRange1.ItemIndex);

     Reestr.CloseKey;
   End;
 Reestr.Free;

  closeDevice;
  if thread <> nil then
    FreeAndNil(thread);
end;

procedure TMainForm.Open24Ltr();
var
  location :  TLTR_MODULE_LOCATION;
  res : Integer;
begin
  // ���� ���������� � ������� ������� - �� ��������� �����
  if LTR24_IsOpened(hltr_24)<>LTR_OK then
  begin
    // ���������� � ������ � ����� ����� �� ������������ ������ �� �������
    // ������� ��������� ������
    location := ltr_list[ 0 ];
    LTR24_Init(hltr_24);
    res:=LTR24_Open(hltr_24, SADDR_DEFAULT, SPORT_DEFAULT, location.csn, location.slot);
    if res<>LTR_OK then
      MessageDlg('�� ������� ���������� ����� � �������: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

    if res=LTR_OK then
    begin
      // ������ ���������� �� Flash-������ (������� ������������� ������������)
      res:=LTR24_GetConfig(hltr_24);
      if res <> LTR_OK then
        MessageDlg('�� ������� ��������� ������������ �� ������: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);
    end;

    if res<>LTR_OK then
      LTR24_Close(hltr_24);
  end
  else
    closeDevice;

end;

procedure TMainForm.StartProcess();
var
  err, res, t,  timeForSending : Integer;
  i, dataSize: Longint;
  MilisecsWork:  Int64;
  DATA:array[0..60000]of Double;
  WORD_DATA:array[0..60000]of Double;
begin
   VoltResetByDevice[0] := StrToFloat(Edit2.Text);
   VoltResetByDevice[1] := StrToFloat(Edit3.Text);

   BigSignalThreshold := StrToInt(Edit4.Text);
   { ��������� �������� �� ��������� ���������� � ���������������
    ���� ��������� ������. ��� �������� ����� �� �������� ���. ��������, ���
    ������� ������ ��������... }
    //------LTR24-------
   hltr_24.ADCFreqCode := cbbAdcFreq.ItemIndex;
   hltr_24.DataFmt     := cbbDataFmt.ItemIndex;
   hltr_24.ISrcValue   := 0;
   hltr_24.TestMode    := false; //��������� ����

   for i := 0 to ChannelsAmount - 1 do
   begin
    hltr_24.ChannelMode[i].Enable   := true;
    hltr_24.ChannelMode[i].AC       := false;
    hltr_24.ChannelMode[i].Range    := cbbRange1.ItemIndex;
    hltr_24.ChannelMode[i].ICPMode  := false;
   end;
   for i := ChannelsAmount to 3 do
    hltr_24.ChannelMode[i].Enable   := false;


   res:= LTR24_SetADC(hltr_24);
   if res <> LTR_OK then
      MessageDlg('�� ������� ���������� ���������: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

    //-------LTR34-----------
    dataSize:= 60000;
    timeForSending := 2000;

    err:=LTR34_Reset(@hltr_34);  CheckError(err);

    hltr_34.ChannelQnt:= ChannelsAmount;        // ����� �������
    hltr_34.RingMode:=false;          // ����� ������  true - ����� ������, false - ��������� �����

    hltr_34.FrequencyDivisor:=0;  //31  ���

    hltr_34.UseClb:=true;            // ��������� ������������.
    hltr_34.AcknowledgeType:=true;   // ��� ������������� true - �������� ������������� ������� �����, false- �������� ��������� ������� ������ 100 ��

    for i := 0 to ChannelsAmount - 1 do
      hltr_34.LChTbl[i]:=LTR34_CreateLChannel(i+1,0); // (����� ������, 0-��� �������� 1- 10�)

    err:=LTR34_Config(@hltr_34);  CheckError(err);

   for i:=0 to dataSize do
       DATA[i]:= VoltToCode(DAC_max_VOLT_signal*sin(i*(pi/dataSize)));

    DATA[dataSize]:= VoltToCode(0);

    err:=LTR34_ProcessData(@hltr_34,@DATA,@WORD_DATA, dataSize, 0);//true- ��������� ��� �������� � �������
    CheckError(err);

    err:=LTR34_Send(@hltr_34,@WORD_DATA, dataSize, timeForSending);
      CheckError(err);
    // ---- strart---------
  if res = LTR_OK then
  begin
    if thread <> nil then
    begin
      FreeAndNil(thread);
    end;

    thread := TProcessThread.Create(True);
    { ��� ��� ��������� ������ ���� ���� � �� ��, ��� ������������ �������,
     ��� � ������ ��������� ����, �� ��������� �������� �� ��� pointer }
    thread.phltr24 := @hltr_24;
    thread.phltr34 := @hltr_34;
    thread.Priority := tpHigher;

    {FIle System}
    thread.path := txPath.Text;
    thread.frequency := FloatToStr(Trunc(StrToInt(cbbAdcFreq.Text)/StrToInt(skipVal.Text)));

    { ��������� �������� ����������, ������� ������ ���������� ��������������
      ������� � ����� ������ }
    thread.visChAvg[0]:= chGraph;
    thread.visChAvg[1]:= chGraph2;
    thread.ShowSignal := CheckBox3;

    thread.doUseCalibration := CheckBox1.Checked;
    thread.skipAmount := StrToInt(SkipVal.Text);
    thread.WindowPercent:=PercentEdit.Value;

    MilisecsWork := StrToInt(txWorkTime.Text);  // ����� ����� ������ � �������, ������� 1 ������!!!
    if cbTimeMetric.Text = '�����' then
      MilisecsWork := MilisecsWork*60;
    if cbTimeMetric.Text = '����' then
      MilisecsWork := MilisecsWork*60*24;

    secondsToWork:=MilisecsWork*60;
    thread.MilisecsToWork := secondsToWork*1000;
    Timer1.Enabled := true;

    thread.bnStart := bnStart;
    { ������������� ������� �� ������� ���������� ������ (� ���������,
    ����� ���������, ���� ����� ���������� ��� ��-�� ������ ��� �����
    ������) }
    thread.OnTerminate := OnThreadTerminate;
    thread.Resume; //��� Delphi 2010 � ���� ������������� ������������ Start
    threadRunning := True;
  end;

  end;

  procedure TMainForm.Timer1Timer(Sender: TObject);
  begin
   secondsToWork:=secondsToWork-1;

   if secondsToWork<0 then begin
      TimerText.Caption:= '';
      Timer1.Enabled := false;
      if CheckBox2.Checked = true then
        bnStartClick(Sender);
   end else
      TimerText.Caption:= IntToStr(secondsToWork div 60)+':'+IntToStr(secondsToWork mod 60);

  end;

end.
