unit ltr34api;
interface
uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;
const
        // константы
        LTR34_ERROR_SEND_DATA             =-3001;
        LTR34_ERROR_RECV_DATA             =-3002;
        LTR34_ERROR_RESET_MODULE          =-3003;
        LTR34_ERROR_NOT_LTR34             =-3004;
        LTR34_ERROR_CRATE_BUF_OWF         =-3005;
        LTR34_ERROR_PARITY                =-3006;
        LTR34_ERROR_OVERFLOW              =-3007;
        LTR34_ERROR_INDEX                 =-3008;
        LTR34_ERROR                       =-3009;
        LTR34_ERROR_EXCHANGE              =-3010;
        LTR34_ERROR_FORMAT                =-3011;
        LTR34_ERROR_PARAMETERS            =-3012;
        LTR34_ERROR_ANSWER                =-3013;
        LTR34_ERROR_WRONG_FLASH_CRC       =-3014;
        LTR34_ERROR_CANT_WRITE_FLASH      =-3015;
        LTR34_ERROR_CANT_READ_FLASH       =-3016;
        LTR34_ERROR_CANT_WRITE_SERIAL_NUM =-3017;
        LTR34_ERROR_CANT_READ_SERIAL_NUM  =-3018;
        LTR34_ERROR_CANT_WRITE_FPGA_VER   =-3019;
        LTR34_ERROR_CANT_READ_FPGA_VER    =-3020;
        LTR34_ERROR_CANT_WRITE_CALIBR_VER =-3021;
        LTR34_ERROR_CANT_READ_CALIBR_VER  =-3022;
        LTR34_ERROR_CANT_STOP             =-3023;
        LTR34_ERROR_SEND_CMD              =-3024;
        LTR34_ERROR_CANT_WRITE_MODULE_NAME=-3025;
        LTR34_ERROR_CANT_WRITE_MAX_CH_QNT =-3026;
        LTR34_ERROR_CHANNEL_NOT_OPENED    =-3027;
        LTR34_ERROR_WRONG_LCH_CONF        =-3028;

        LTR34_MAX_BUFFER_SIZE             =2097151;
        LTR34_EEPROM_SIZE                 =2048;
        LTR34_USER_EEPROM_SIZE            =1024;
        LTR34_DAC_NUMBER_MAX              =8;

type
    //typedef unsigned char byte;
    //typedef unsigned short ushort;
    //typedef unsigned int uint;
  {$A4}
  _ltr34_gen_type=(ltr_34_gen_type_sin,ltr_34_gen_type_pila,ltr_34_gen_type_mean,ltr_34_gen_type_max);
  _ltr34_gen_param_struct=record
              angle:Double;
              Period:Double;
              Freq:Double;
              Min:Double;
              Max:Double;
              GenType:_ltr34_gen_type;
   end;

  DAC_CHANNEL_CALIBRATION=record
    FactoryCalibrOffset:array[0..2*LTR34_DAC_NUMBER_MAX-1] of single;
    FactoryCalibrScale:array[0..2*LTR34_DAC_NUMBER_MAX-1]of single;
  end;

  TINFO_LTR34=record
    Name:array[0..15]of AnsiChar;
    Serial:array[0..23]of AnsiChar;
    FPGA_Version:array[0..7]of AnsiChar;
    CalibrVersion:array[0..7]of AnsiChar;
    MaxChannelQnt:byte;
  end;
  pTINFO_LTR34=^TINFO_LTR34;// Структура описания модуля

    //**** конфигурация модуля
  TLTR34=record
    size:integer;    // Размер структуры
    Channel:TLTR;                      // структура описывающая модуль в крейте – описание в ltrapi.pdf
    LChTbl:array[0..LTR34_DAC_NUMBER_MAX-1]of integer;                  // Таблица логических каналов
    //**** настройки модуля
    FrequencyDivisor:byte;            // делитель частоты дискретизации 0..60 (31.25..500 кГц)
    ChannelQnt:byte;             // число каналов 0, 1, 2, 3 соотвествнно (1, 2, 4, 8)
    UseClb:boolean;
    AcknowledgeType:boolean;             // тип подтверждения true - высылать подтверждение каждого слова, false- высылать состояние буффера каждые 100 мс
    ExternalStart:boolean;               // внешний старт true - внешний старт, false - внутренний
    RingMode:boolean;                    // режим кольца  true - режим кольца, false - потоковый режим
    BufferFull:byte;                    // статус - буффер переполнен - ошибка
    BufferEmpty:byte;                    // статус - буффер пуст - ошибка
    DACRunning:byte;                    // статус - запущена ли генерация
    FrequencyDAC:single;                // статус - частота - на которую настроен ЦАП в текущей конфигурации
    DacCalibration:DAC_CHANNEL_CALIBRATION;
    ModuleInfo:TINFO_LTR34;
  end;
  pTLTR34=^TLTR34;
  {$A+}

    // Инициализация полей структуры TLTR34
    Function  LTR34_Init (module:pTLTR34):integer; {$I ltrapi_callconvention};
    // Установление связи с модулем LTR34.
    // Модулю посылается пакет STOP+RESET и ожидается подтверждение сброса.
    Function  LTR34_Open (module:pTLTR34; saddr:integer; sport:WORD; csnCHAR:Pointer; cc:WORD):integer; {$I ltrapi_callconvention};
    // Разрыв связи с модулем.
    Function  LTR34_Close (module:pTLTR34):integer; {$I ltrapi_callconvention};
    // Определение сотояния канала связи с модулем.
    Function  LTR34_IsOpened (module:pTLTR34):integer; {$I ltrapi_callconvention};
    {
    Функция для приема данных от модуля.
    1) при работе цап в режиме ECHO - все данные, генерируемые
    модулем, сервер обрабатвает и отдает клиенту в том виде
    в котором принял. Таким образом, в режиме ECHO клиент
    должен всегда откачивать данные от модуля.
    2) При работе цап в режиме PERIOD - все данные, генерируемые
    модулем, сервер обрабатвает и "проглатывает".
    }
    Function   LTR34_Recv (module:pTLTR34; dataDWORD:Pointer; tstampDWORD:Pointer; size:integer; timeout:integer):integer; {$I ltrapi_callconvention};
      // Формирование логического канала
    Function   LTR34_CreateLChannel(PhysChannel:BYTE; ScaleFlagBOOL:byte):integer; {$I ltrapi_callconvention};
    {    функция для отправки данных модулю
    1) В ltr-сервере реализовано управление потоком данных
    поступающих на модуль LTR34 от клиента. Поэтому при
    работе с ЦАП в потоковом режиме (RingMode=0)
    данные можно высылать в любых количествах, не заботясь
    о переполнении буфера в LTR34. Однако, следует
    позаботиться о правильном подборе таймаута, т.к.
    при достаточном заполнении буфера в модуле
    прием данных сервером от клиента будет производиться со скоростью
    пропорцианальной частоте дискретизации ЦАП, т.е. при низких частотах
    дискретизации и достаточно большом количестве отсылаемых данных
    может потребоваться достаточно большое значение таймаута.

    2) Управление потоком модуля LTR34 строится на подсчете количества
    отправленных сэмплов и принятых подтверждений, что в некоторых
    случаях может приводить к блокировке потока в модуль (Например,
    на LTR34 уже было отправлено достаточное количество данных, но
    ЦАП еще не стартовал и подтверждения от модуля еще не поступают.
    В этом случае сервер прикратит прием данных от клиента).
    Для сброса механизма управления потоком следует выслать модулю
    команду RESET (при этом будут сброшены внутренние счетчики в ltr-сервере)
    или произвести переподключение к модулю (вызвать LTR34_Close() и LTR34_Open())
    }

    Function   LTR34_Send (module:pTLTR34; dataDWORD:pointer;  size:integer; timeout:integer):integer; {$I ltrapi_callconvention};
    Function   LTR34_ProcessData(module:pTLTR34;  srcDOUBLE:Pointer; destDWORD:Pointer; size:integer; volt:byte):integer; {$I ltrapi_callconvention};
    // запись данных в FIFO буффер
    Function   LTR34_SendData(module:pTLTR34;  dataDOUBLE:Pointer;  size:integer; timeout:integer; calibrMainPset:byte; calibrExtraVolts:byte):integer; {$I ltrapi_callconvention};
    // Запись регистра CONFIG
    Function   LTR34_Config  (module:pTLTR34):integer; {$I ltrapi_callconvention};
    // Запуск ЦАП.
    Function   LTR34_DACStart   (module:pTLTR34):integer; {$I ltrapi_callconvention};
    // Останов ЦАП.
    Function   LTR34_DACStop    (module:pTLTR34):integer; {$I ltrapi_callconvention};
    Function   LTR34_Reset(module:pTLTR34):integer; {$I ltrapi_callconvention};
    Function   LTR34_SetDescription(module:pTLTR34):integer; {$I ltrapi_callconvention};
    Function   LTR34_GetDescription(module:pTLTR34):integer; {$I ltrapi_callconvention};
    Function   LTR34_GetCalibrCoeffs(module:pTLTR34):integer; {$I ltrapi_callconvention};
    Function   LTR34_WriteCalibrCoeffs(module:pTLTR34):integer; {$I ltrapi_callconvention};
    Function   LTR34_ReadFlash(module:pTLTR34; dataBYTE:Pointer; size:WORD; Address:word):integer; {$I ltrapi_callconvention};
    // функции вспомагательного характера
    Function   LTR34_GetErrorString(err:integer):string; {$I ltrapi_callconvention};
    // Проверка целостности ППЗУ
    Function   LTR34_TestEEPROM(module:pTLTR34):integer; {$I ltrapi_callconvention};
    // недокументированная функция - пользовать на свой страх и риск, но работает :)
    Function   LTR34_PrepareGenData(module:pTLTR34; GenerateDataDOUBLE:Pointer; GenLength:integer;GenParam:Pointer):integer; {$I ltrapi_callconvention};

implementation
    Function  LTR34_Init (module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function  LTR34_Open (module:pTLTR34; saddr:integer; sport:WORD; csnCHAR:Pointer; cc:WORD):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function  LTR34_Close (module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function  LTR34_IsOpened (module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_Recv (module:pTLTR34; dataDWORD:Pointer; tstampDWORD:Pointer; size:integer; timeout:integer):integer; {$I ltrapi_callconvention}; external 'ltr34api';

    Function   LTR34_CreateLChannel(PhysChannel:BYTE; ScaleFlagBOOL:byte):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_Send (module:pTLTR34; dataDWORD:pointer;  size:integer; timeout:integer):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_ProcessData(module:pTLTR34;  srcDOUBLE:Pointer; destDWORD:Pointer; size:integer; volt:byte):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_SendData(module:pTLTR34;  dataDOUBLE:Pointer;  size:integer; timeout:integer; calibrMainPset:byte; calibrExtraVolts:byte):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_Config  (module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_DACStart   (module:pTLTR34):integer; {$I ltrapi_callconvention};external 'ltr34api';
    Function   LTR34_DACStop    (module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_Reset(module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_SetDescription(module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_GetDescription(module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_GetCalibrCoeffs(module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_WriteCalibrCoeffs(module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_ReadFlash(module:pTLTR34; dataBYTE:Pointer; size:WORD; Address:word):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_TestEEPROM(module:pTLTR34):integer; {$I ltrapi_callconvention}; external 'ltr34api';
    Function   LTR34_PrepareGenData(module:pTLTR34; GenerateDataDOUBLE:Pointer; GenLength:integer;GenParam:Pointer):integer; {$I ltrapi_callconvention}; external 'ltr34api';

    Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; {$I ltrapi_callconvention}; external 'ltr34api' name 'LTR34_GetErrorString';

    Function LTR34_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};
    begin
        LTR34_GetErrorString:=string(_get_err_str(err));
    end;

end.




