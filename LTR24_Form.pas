unit LTR24_Form;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,
  ltrapi, ltrapitypes, ltrapidefine, ltr24api, LTR24_ProcessThread;

{ Информация, необходимая для установления соединения с модулем }
type TLTR_MODULE_LOCATION = record
  csn : string; //серийный номер крейта
  slot : Word; //номер слота
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
    ltr24_list: array of TLTR_MODULE_LOCATION; //список найденных модулей
    hltr24 : TLTR24; // Описатель модуля, с которым идет работа
    threadRunning : Boolean; // Признак, запущен ли поток сбора данных
    thread : TLTR24_ProcessThread; //Объект потока для выполнения сбора данных

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

    updateControls;

  end;
end;

// назначение элементов ComboBox'у с сохранением выбранного индекса
procedure TMainForm.assignComboList(comboBox: TComboBox; list : TStrings);
var
  index : Integer;
begin
  index := comboBox.ItemIndex;
  comboBox.Items.Assign(list);
  comboBox.ItemIndex := index;
end;


// установка нужного текста в поле выбора диапазона в зависимости от того, включен ли ICP-режим
procedure TMainForm.setRangeComboList(rangeBox: TComboBox; icpBox : TComboBox);
var
  rangeStrings : TStrings;
begin
  rangeStrings := TStringList.Create;
  if icpBox.ItemIndex = 0 then
  begin
    rangeStrings.Add(String('+/- 2В'));
    rangeStrings.Add(String('+/- 10В'));
  end
  else
  begin
    rangeStrings.Add(String('~ 1В'));
    rangeStrings.Add(String('~ 5В'));
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

  //изменение настроек возможно только при открытом устройстве и не запущенном сборе
  cfg_en:= module_opened and not threadRunning;


  cbbAdcFreq.Enabled := cfg_en;
  cbbDataFmt.Enabled := cfg_en;
  cbbRange1.Enabled := cfg_en;

  { В зависимости от того, выбран ли тестовый режим или
    обычный, устанавливаем соответствующие названия элементов ComboBox'а.
    При этом сохраняем индекс выбранного элемента неизменным }
  modeStrings := TStringList.Create;

    modeStrings.Add(String('Диф. вход'));
    modeStrings.Add(String('ICP вход'));

  modeStrings.Destroy;
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

procedure TMainForm.edtDevSerial2Change(Sender: TObject);
begin

end;

//функция, вызываемая по завершению потока сбора данных
//разрешает старт нового, устанавливает threadRunning
procedure TMainForm.OnThreadTerminate(par : TObject);
begin
    if thread.err <> LTR_OK then
    begin
        MessageDlg('Сбор данных завершен с ошибкой: ' + LTR24_GetErrorString(thread.err),
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

  updateControls;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
var
  i, res : Integer;
begin
   { Сохраняем значения из элементов управления в соответствующие
    поля описателя модуля. Для простоты здесь не делается доп. проверок, что
    введены верные значения... }
   hltr24.ADCFreqCode := cbbAdcFreq.ItemIndex;
   hltr24.DataFmt     := cbbDataFmt.ItemIndex;
   hltr24.ISrcValue   := 0;
   hltr24.TestMode    := false; //Измерение себя

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
    thread.edtChAvg[0]:=edtCh1Avg;
    thread.edtChAvg[1]:=edtCh2Avg;
    thread.edtChAvg[2]:=edtCh3Avg;
    thread.edtChAvg[3]:=edtCh4Avg;


    { устанавливаем функцию на событие завершения потока (в частности,
    чтобы отследить, если поток завершился сам из-за ошибки при сборе
    данных) }
    thread.OnTerminate := OnThreadTerminate;
    thread.Resume; //для Delphi 2010 и выше рекомендуется использовать Start
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
   // устанавливаем запрос на завершение потока
    if threadRunning then
        thread.stop:=True;
    btnStop.Enabled:= False;
end;

procedure TMainForm.cfgChanged(Sender: TObject);
begin
  updateControls();
end;

end.
