unit MainUnit;

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
    ltr24_list: array of TLTR_MODULE_LOCATION; //список найденных модулей
    hltr24 : TLTR24; // Описатель модуля, с которым идет работа
    threadRunning : Boolean; // Признак, запущен ли поток сбора данных
    thread : TLTR24_ProcessThread; //Объект потока для выполнения сбора данных

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
  srv : TLTR; //Описатель для управляющего соединения с LTR-сервером
  crate: TLTR; //Описатель для соединения с крейтом
  res, crates_cnt, crate_ind, module_ind, modules_cnt : integer;
  serial_list : array [0..CRATE_MAX-1] of string; //список номеров керйтов
  mids : array [0..MODULE_MAX-1] of Word; //список идентификаторов модулей для текущего крейта
begin
  //обнуляем список ранее найденных модулей
  modules_cnt:=0;
  cbbModulesList.Items.Clear;
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
                    // и добавляем в ComboBox для возможности выбора нужного
                    cbbModulesList.Items.Add('Крейт ' + ltr24_list[modules_cnt-1].csn +
                                            ', Слот ' + IntToStr(ltr24_list[modules_cnt-1].slot));
                end;
              end;
          end;
          //закрываем соединение с крейтом
          LTR_Close(crate);
        end;
      end;
    end;

    cbbModulesList.ItemIndex := 0;
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
  devsel := (Length(ltr24_list) > 0) and (cbbModulesList.ItemIndex >= 0);

  icp_support := hltr24.ModuleInfo.SupportICP;

  //обновление списка устройств и выбор можно делать только пока не открыто конкретное устройство
  btnRefreshDevList.Enabled := not module_opened;
  cbbModulesList.Enabled := not module_opened;

  //установить связь можно только если выбрано устройство
  btnOpen.Enabled := devsel;
  if module_opened then
    btnOpen.Caption := 'Закрыть соединение'
  else
    btnOpen.Caption := 'Установить соединение';


  btnStart.Enabled := module_opened and not threadRunning;
  btnStop.Enabled := module_opened and threadRunning;

  //изменение настроек возможно только при открытом устройстве и не запущенном сборе
  cfg_en:= module_opened and not threadRunning;


  cbbAdcFreq.Enabled := cfg_en;
  cbbDataFmt.Enabled := cfg_en;
  cbbISrcValue.Enabled := cfg_en and icp_support;
  chkTestModes.Enabled := cfg_en;

  //если нет поддержки ICP, то если был выставлен ICP-режим, сбрасываем на диф. вход
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

  // AC не имеет значения при ICP-режиме => запрет выбора
  cbbAC1.Enabled := cfg_en and (cbbICPMode1.ItemIndex=0);
  cbbAC2.Enabled := cfg_en and (cbbICPMode2.ItemIndex=0);
  cbbAC3.Enabled := cfg_en and (cbbICPMode3.ItemIndex=0);
  cbbAC4.Enabled := cfg_en and (cbbICPMode4.ItemIndex=0);

  cbbICPMode1.Enabled := cfg_en and icp_support;
  cbbICPMode2.Enabled := cfg_en and icp_support;
  cbbICPMode3.Enabled := cfg_en and icp_support;
  cbbICPMode4.Enabled := cfg_en and icp_support;

  { В зависимости от того, выбран ли тестовый режим или
    обычный, устанавливаем соответствующие названия элементов ComboBox'а.
    При этом сохраняем индекс выбранного элемента неизменным }
  modeStrings := TStringList.Create;
  if chkTestModes.Checked then
  begin
    modeStrings.Add(String('Собств. ноль'));
    modeStrings.Add(String('ICP тест'));
  end
  else
  begin
    modeStrings.Add(String('Диф. вход'));
    modeStrings.Add(String('ICP вход'));
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
  // если соединение с модулем закрыто - то открываем новое
  if LTR24_IsOpened(hltr24)<>LTR_OK then
  begin
    // информацию о крейте и слоте берем из сохраненного списка по индексу
    // текущей выбранной записи
    location := ltr24_list[ cbbModulesList.ItemIndex ];
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

    if res=LTR_OK then
    begin
      edtDevSerial.Text := String(hltr24.ModuleInfo.Serial);
      edtVerPld.Text := IntToStr(hltr24.ModuleInfo.VerPLD);
      if hltr24.ModuleInfo.SupportICP then
        edtICPSupport.Text := 'Есть'
      else
        edtICPSupport.Text := 'Нет';
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
   { Сохраняем значения из элементов управления в соответствующие
    поля описателя модуля. Для простоты здесь не делается доп. проверок, что
    введены верные значения... }
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
