unit EU2_Form;
interface uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FileCtrl, StdCtrls, Buttons, ExtCtrls,
  Math, TeeProcs, TeEngine, Chart, Series, ComCtrls,
  ltrapi, ltrapitypes, ltrapidefine, ltr24api, ltr34api, ProcessThread, Config;

{ Информация, необходимая для установления соединения с модулем }
type TLTR_MODULE_LOCATION = record
  csn : string; //серийный номер крейта
  slot : Word; //номер слота
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
    Panel1: TPanel;
    Panel2: TPanel;
    Label3: TLabel;
    skipVal: TEdit;
    procedure FormDestroy(Sender: TObject);

    private
      ltr_list: array[0..1] of TLTR_MODULE_LOCATION; //список найденных модулей 0-24, 1 - 34
      hltr_24 : TLTR24; // Описатель модуля, с которым идет работа
      hltr_34 : TLTR34;
      threadRunning : Boolean; // Признак, запущен ли поток сбора данных
      thread : TProcessThread; //Объект потока для выполнения сбора данных

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
  if (bnStart.Caption = 'Старт') then begin
     bnStart.Caption := 'Стоп';

    StartProcess();

  end else begin
    if threadRunning then

      thread.stop:=True;

  end;
end;

procedure TMainForm.refreshDeviceList();
var
  srv : TLTR; //Описатель для управляющего соединения с LTR-сервером
  crate: TLTR; //Описатель для соединения с крейтом
  res, crates_cnt, crate_ind, module_ind: integer;
  serial_list : array [0..CRATE_MAX-1] of string; //список номеров керйтов
  mids : array [0..MODULE_MAX-1] of Word; //список идентификаторов модулей для текущего крейта
begin
  // устанавливаем связь с управляющим каналом сервера, чтобы получить список крейтов
  LTR_Init(srv);
  srv.cc := CC_CONTROL;    //используем управляющий канал
  { серийный номер CSN_SERVER_CONTROL позволяет установить связь с сервером, даже
    если нет ни одного крейта }
  LTR_FillSerial(srv, CSN_SERVER_CONTROL);
  res:=LTR_Open(srv);
  if res <> LTR_OK then
    MessageDlg('Не удалось установить связь с сервером: ' + LTR_GetErrorString(res), mtError, [mbOK], 0)
  else
  begin
    //получаем список серийных номеров всех подключенных крейтов
    res:=LTR_GetCrates(srv, serial_list, crates_cnt);
    //серверное соединение больше не нужно - можно закрыть
    LTR_Close(srv);

    if (res <> LTR_OK) then
      MessageDlg('Не удалось получить список крейтов: ' + LTR_GetErrorString(res), mtError, [mbOK], 0)
    else
    begin
      for crate_ind:=0 to crates_cnt-1 do
      begin
        //устанавливаем связь с каждым крейтом, чтобы получить список модулей
        LTR_Init(crate);
        crate.cc := CC_CONTROL;
        LTR_FillSerial(crate, serial_list[crate_ind]);
        res:=LTR_Open(crate);
        if res=LTR_OK then
        begin
          //получаем список модулей
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
          //закрываем соединение с крейтом
          LTR_Close(crate);
        end;
      end;
    end;
  end;
end;

procedure TMainForm.closeDevice();
begin
  // остановка сбора и ожидание завершения потока
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

//функция, вызываемая по завершению потока сбора данных
//разрешает старт нового, устанавливает threadRunning
procedure TMainForm.OnThreadTerminate(par : TObject);
begin
    if thread.err <> LTR_OK then
        MessageDlg('Сбор данных завершен с ошибкой: ' + LTR24_GetErrorString(thread.err),
                  mtError, [mbOK], 0);

    threadRunning := false;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  LTR24_Init(hltr_24);
  LTR34_Init(@hltr_34);
  refreshDeviceList;

  DecimalSeparator := '.';
  InitializeCriticalSection(HistorySection);
  InitializeCriticalSection(DACSection);

  Open24Ltr();
  Open34Ltr();
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
  //Определяем список крейтов подключенных к этому компьютеру (LocalHost 127.0.0.1)
  for i:=0 to CRATE_MAX-1 do CSNLIST[i]:='';
  LTR_Init(@LTR);
  err:=LTR_Open(@LTR);                      CheckError(err);
  err:=LTR_GetCrates(@LTR,@CSNLIST[0,0]);   CheckError(err);

  CrateSelect:=0;//Откроеться первый наёденный LTR крейт
  For i:=0 to CRATE_MAX-1 do

  err:=LTR_Close(@LTR);                     CheckError(err);
  //Ищем модули в выбранном крейте
  LTR_Init(@LTR);
  for i:=0 to SERIAL_NUMBER_SIZE-1 do
  LTR.csn[i]:=CSNLIST[CrateSelect][i];

  err:=LTR_Open(@LTR);                      CheckError(err);
  err:=LTR_GetCrateModules(@LTR,@MID[0]);   CheckError(err);
  Total34:=0;
  //Отображаем список крейтов
  for i:=0 to MODULE_MAX-1 do
  begin
    if MID[i]=MID_LTR34 then
      begin
        LIST34[Total34]:=i;
        Total34:=Total34+1;
      end;
  end;
  LTR34SELECT:=0;//первый найденный LTR34
  //  Подключаемся к выбранному модулю
  CheckError(LTR34_Init(@hltr_34));
  err:=LTR34_Open(@hltr_34,LTR.saddr,LTR.sport,@CSNLIST[CrateSelect][0],LIST34[LTR34SELECT]+1);
  CheckError(err);
  CheckError(LTR34_TestEEPROM(@hltr_34))
  end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  closeDevice;
  if thread <> nil then
    FreeAndNil(thread);
end;

procedure TMainForm.Open24Ltr();
var
  location :  TLTR_MODULE_LOCATION;
  res : Integer;
begin
  // если соединение с модулем закрыто - то открываем новое
  if LTR24_IsOpened(hltr_24)<>LTR_OK then
  begin
    // информацию о крейте и слоте берем из сохраненного списка по индексу
    // текущей выбранной записи
    location := ltr_list[ 0 ];
    LTR24_Init(hltr_24);
    res:=LTR24_Open(hltr_24, SADDR_DEFAULT, SPORT_DEFAULT, location.csn, location.slot);
    if res<>LTR_OK then
      MessageDlg('Не удалось установить связь с модулем: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

    if res=LTR_OK then
    begin
      // чтение информации из Flash-памяти (включая калибровочные коэффициенты)
      res:=LTR24_GetConfig(hltr_24);
      if res <> LTR_OK then
        MessageDlg('Не удалось прочитать конфигурацию из модуля: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);
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
   { Сохраняем значения из элементов управления в соответствующие
    поля описателя модуля. Для простоты здесь не делается доп. проверок, что
    введены верные значения... }
    //------LTR24-------
   hltr_24.ADCFreqCode := cbbAdcFreq.ItemIndex;
   hltr_24.DataFmt     := cbbDataFmt.ItemIndex;
   hltr_24.ISrcValue   := 0;
   hltr_24.TestMode    := false; //Измерение себя

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
      MessageDlg('Не удалось установить настройки: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

    //-------LTR34-----------
    dataSize:= 60000;
    timeForSending := 2000;

    err:=LTR34_Reset(@hltr_34);  CheckError(err);

    hltr_34.ChannelQnt:= ChannelsAmount;        // число каналов
    hltr_34.RingMode:=false;          // режим кольца  true - режим кольца, false - потоковый режим

    hltr_34.FrequencyDivisor:=0;  //31  кГц

    hltr_34.UseClb:=true;            // Фабричные Коэффициэнты.
    hltr_34.AcknowledgeType:=true;   // тип подтверждения true - высылать подтверждение каждого слова, false- высылать состояние буффера каждые 100 мс

    for i := 0 to ChannelsAmount - 1 do
      hltr_34.LChTbl[i]:=LTR34_CreateLChannel(i+1,0); // (номер канала, 0-без усиления 1- 10х)

    err:=LTR34_Config(@hltr_34);  CheckError(err);

   for i:=0 to dataSize do
       DATA[i]:= VoltToCode(10*sin(i*(pi/dataSize)));

   DATA[dataSize]:= VoltToCode(0);

    err:=LTR34_ProcessData(@hltr_34,@DATA,@WORD_DATA, dataSize, 0);//true- указываем что значения в Вольтах
    CheckError(err);

    //err:=LTR34_Send(@hltr_34,@WORD_DATA, dataSize, timeForSending);
    //  CheckError(err);
    // ---- strart---------
  if res = LTR_OK then
  begin
    if thread <> nil then
    begin
      FreeAndNil(thread);
    end;

    thread := TProcessThread.Create(True);
    { Так как структура должна быть одна и та же, что используемая потоком,
     что в классе основного окна, то вынуждены передать ее как pointer }
    thread.phltr24 := @hltr_24;
    thread.phltr34 := @hltr_34;
    thread.Priority := tpHigher;

    {FIle System}
    thread.path := txPath.Text;
    thread.frequency := FloatToStr(Trunc(StrToInt(cbbAdcFreq.Text)/StrToInt(skipVal.Text)));

    { Сохраняем элементы интерфейса, которые должны изменяться обрабатывающим
      потоком в класс потока }
    thread.visChAvg[0]:= chGraph;
    thread.visChAvg[1]:= chGraph2;

    thread.doUseCalibration := CheckBox1.Checked;
    thread.skipAmount := StrToInt(SkipVal.Text);

    MilisecsWork := StrToInt(txWorkTime.Text);  // время сбора данных в минутах, минимум 1 минута!!!
    if cbTimeMetric.Text = 'часов' then
      MilisecsWork := MilisecsWork*60;
    if cbTimeMetric.Text = 'дней' then
      MilisecsWork := MilisecsWork*60*24;

    thread.MilisecsToWork := MilisecsWork*60*1000;
    thread.bnStart := bnStart;
    { устанавливаем функцию на событие завершения потока (в частности,
    чтобы отследить, если поток завершился сам из-за ошибки при сборе
    данных) }
    thread.OnTerminate := OnThreadTerminate;
    thread.Resume; //для Delphi 2010 и выше рекомендуется использовать Start
    threadRunning := True;
  end;

  end;

end.
