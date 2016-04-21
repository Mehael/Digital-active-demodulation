unit EU2_Form;
interface uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, FileCtrl, StdCtrls, Buttons, ExtCtrls,
  Math, TeeProcs, TeEngine, Chart, Series, ComCtrls,
  ltrapi, ltrapitypes, ltrapidefine, ltr24api, LTR24_ProcessThread;

{ Информация, необходимая для установления соединения с модулем }
type TLTR_MODULE_LOCATION = record
  csn : string; //серийный номер крейта
  slot : Word; //номер слота
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
      ltr24_list: array of TLTR_MODULE_LOCATION; //список найденных модулей
      hltr24 : TLTR24; // Описатель модуля, с которым идет работа
      threadRunning : Boolean; // Признак, запущен ли поток сбора данных
      thread : TLTR24_ProcessThread; //Объект потока для выполнения сбора данных
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
  if (bnStart.Caption = 'Старт') then begin
     bnStart.Caption := 'Стоп';
    CreateFiles();
    StartProcess();

  end else begin
    bnStart.Caption := 'Старт';
    if threadRunning then
      thread.stop:=True;


  end;
end;
//----------------------------------------------------------------
procedure TMainForm.refreshDeviceList();
var
  srv : TLTR; //Описатель для управляющего соединения с LTR-сервером
  crate: TLTR; //Описатель для соединения с крейтом
  res, crates_cnt, crate_ind, module_ind, modules_cnt : integer;
  serial_list : array [0..CRATE_MAX-1] of string; //список номеров керйтов
  mids : array [0..MODULE_MAX-1] of Word; //список идентификаторов модулей для текущего крейта
begin
  //обнуляем список ранее найденных модулей
  modules_cnt:=0;
  SetLength(ltr24_list, 0);

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
                //ищем модули LTR210
                if mids[module_ind]=MID_LTR24 then
                begin
                    // сохраняем информацию о найденном модуле, необходимую для
                    // последующего установления соединения с ним, в список
                    modules_cnt:=modules_cnt+1;
                    SetLength(ltr24_list, modules_cnt);
                    ltr24_list[modules_cnt-1].csn := serial_list[crate_ind];
                    ltr24_list[modules_cnt-1].slot := module_ind+CC_MODULE1;
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

  LTR24_Close(hltr24);
end;

//функция, вызываемая по завершению потока сбора данных
//разрешает старт нового, устанавливает threadRunning
procedure TMainForm.OnThreadTerminate(par : TObject);
begin
    if thread.err <> LTR_OK then
    begin
        MessageDlg('Сбор данных завершен с ошибкой: ' + LTR24_GetErrorString(thread.err),
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
  // если соединение с модулем закрыто - то открываем новое
  if LTR24_IsOpened(hltr24)<>LTR_OK then
  begin
    // информацию о крейте и слоте берем из сохраненного списка по индексу
    // текущей выбранной записи
    location := ltr24_list[ 0 ];
    LTR24_Init(hltr24);
    res:=LTR24_Open(hltr24, SADDR_DEFAULT, SPORT_DEFAULT, location.csn, location.slot);
    if res<>LTR_OK then
      MessageDlg('Не удалось установить связь с модулем: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

    if res=LTR_OK then
    begin
      // чтение информации из Flash-памяти (включая калибровочные коэффициенты) 
      res:=LTR24_GetConfig(hltr24);
      if res <> LTR_OK then
        MessageDlg('Не удалось прочитать конфигурацию из модуля: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);
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
   { Сохраняем значения из элементов управления в соответствующие
    поля описателя модуля. Для простоты здесь не делается доп. проверок, что
    введены верные значения... }
   hltr24.ADCFreqCode := cbbAdcFreq.ItemIndex;
   hltr24.DataFmt     := cbbDataFmt.ItemIndex;
   hltr24.ISrcValue   := 0;
   hltr24.TestMode    := false; //Измерение себя

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
      MessageDlg('Не удалось установить настройки: ' + LTR24_GetErrorString(res), mtError, [mbOK], 0);

  if res = LTR_OK then
  begin
    if thread <> nil then
    begin
      FreeAndNil(thread);
    end;

    thread := TLTR24_ProcessThread.Create(True);
    { Так как структура должна быть одна и та же, что используемая потоком,
     что в классе основного окна, то вынуждены передать ее как pointer }
    thread.phltr24 := @hltr24;
    { Сохраняем элементы интерфейса, которые должны изменяться обрабатывающим
      потоком в класс потока }
    thread.visChAvg[0]:= chGraph;
    thread.visChAvg[1]:= chGraph2;

    thread.Files := @Files;

    MilisecsWork := StrToInt(txWorkTime.Text);  // время сбора данных в минутах, минимум 1 минута!!!
    if cbTimeMetric.Text = 'часов' then
      MilisecsWork := MilisecsWork*60;
    if cbTimeMetric.Text = 'дней' then
      MilisecsWork := MilisecsWork*60*24;

    thread.MilisecsToWork := MilisecsWork*60*1000;
    { устанавливаем функцию на событие завершения потока (в частности,
    чтобы отследить, если поток завершился сам из-за ошибки при сборе
    данных) }
    thread.OnTerminate := OnThreadTerminate;
    thread.Resume; //для Delphi 2010 и выше рекомендуется использовать Start
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
