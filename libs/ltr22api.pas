unit ltr22api;

interface

uses SysUtils, ltrapitypes, ltrapidefine, ltrapi;

const
    LTR22_ADC_NUMBERS           =   4;
    LTR22_ADC_CHANNELS          =   LTR22_ADC_NUMBERS;
    LTR22_RANGE_NUMBER          =   6;
    LTR22_RANGE_OVERFLOW        =   7;
    // количество выставляемых частот
    LTR22_MAX_DISC_FREQ_NUMBER  =   25;


   // коды диапазонов АЦП
    LTR22_ADC_RANGE_1           = 0;
    LTR22_ADC_RANGE_0_3         = 1;
    LTR22_ADC_RANGE_0_1         = 2;
    LTR22_ADC_RANGE_0_03        = 3;
    LTR22_ADC_RANGE_10          = 4;
    LTR22_ADC_RANGE_3           = 5;

    { --------- возможные варианты ошибок -----------------}
    LTR22_ERROR_SEND_DATA                              = -6000;
    LTR22_ERROR_RECV_DATA                              = -6001;
    LTR22_ERROR_NOT_LTR22                              = -6002;
    LTR22_ERROR_OVERFLOW                               = -6003;
    LTR22_ERROR_ADC_RUNNING                            = -6004;
    LTR22_ERROR_MODULE_INTERFACE                       = -6005;
    LTR22_ERROR_INVALID_FREQ_DIV                       = -6006;
    LTR22_ERROR_INVALID_TEST_HARD_INTERFACE            = -6007;
    LTR22_ERROR_INVALID_DATA_RANGE_FOR_THIS_CHANNEL    = -6008;
    LTR22_ERROR_INVALID_DATA_COUNTER                   = -6009;
    LTR22_ERROR_PRERARE_TO_WRITE                       = -6010;
    LTR22_ERROR_WRITE_AVR_MEMORY                       = -6011;
    LTR22_ERROR_READ_AVR_MEMORY                        = -6012;
    LTR22_ERROR_PARAMETERS                             = -6013;
    LTR22_ERROR_CLEAR_BUFFER_TOUT                      = -6014;
    LTR22_ERROR_SYNC_FHAZE_NOT_STARTED                 = -6015;
    LTR22_ERROR_INVALID_CH_NUMBER                      = -6016;

type


{$A4}

TINFO_LTR22 = record
  Description: TDESCRIPTION_MODULE;     // описание модуля
  CPU: TDESCRIPTION_CPU;                // описание AVR
end;


ADC_CHANNEL_CALIBRATION = record
    FactoryCalibOffset:array [0..LTR22_RANGE_NUMBER-1] of single;
    FactoryCalibScale:array [0..LTR22_RANGE_NUMBER-1] of single;

    UserCalibOffset:array [0..LTR22_RANGE_NUMBER-1] of single;
    UserCalibScale:array [0..LTR22_RANGE_NUMBER-1] of single;
end;

TLTR22 = record
    Size            : Integer;
    Channel         : TLTR; // структура описывающая модуль в крейте
    {---------  настройки модуля ----------}
    Fdiv_rg         : Byte;     // делитель частоты клоков 1..15
    Adc384          : Boolean;  // дополнительный делитель частоты сэмплов true =3 false =4
    AC_DC_State     : Boolean;  // состояние true =AC+DC false=AC
    MeasureADCZero  : Boolean;  // измерение собственного нуля (true - включено false - выключено)
    DataReadingProcessed:Boolean;  // состояние считывания АЦП true-АЦП считывается false - нет
    ADCChannelRange : array [0..LTR22_ADC_NUMBERS-1] of Byte;// предел имзерений АЦП по каналам 0 - 1В 1 - 0.3В 2 - 0.1В 3 - 0.03В 4 - 10В 5 - 3В
    ChannelEnabled  : array [0..LTR22_ADC_NUMBERS-1] of Boolean;   // Состояние каналов, включен - true выключен - false

    FreqDiscretizationIndex : Integer;  // частота дискретизации, выставленная сейчас 0..24 - в зависимости от частоты
                                    // из массива LTR22_DISK_FREQ_ARRAY

    SyncType        : Byte; // Тип синхронизации 0 - внутренний старт по сигналу Go
                            //1 - фазировка
                            //2 -  внешний старт
                            //3 -  резервировано
    SyncMaster      : Boolean; // true - модуль генерит сигнал, false - модуль принимает синхросигнал

    ModuleDescription : TINFO_LTR22;
    ADCCalibration  : array [0..LTR22_ADC_NUMBERS-1] of array [0..LTR22_MAX_DISC_FREQ_NUMBER-1] of ADC_CHANNEL_CALIBRATION;
end;
pTLTR22 = ^TLTR22;

 {$A+}



Function LTR22_Init(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_Open(module:pTLTR22; saddr:LongWord; sport:LongWord;csnArrayByte:Pointer;cc:WORD) : Integer; {$I ltrapi_callconvention};
Function LTR22_Close(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_IsOpened(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_GetConfig(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_SetConfig(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_StartADC(module:pTLTR22; WaitSync:Boolean) : Integer; {$I ltrapi_callconvention};
Function LTR22_StopADC(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_ClearBuffer(module:pTLTR22; wait_response:Boolean) : Integer; {$I ltrapi_callconvention};
Function LTR22_SetSyncPriority(module:pTLTR22; SyncMaster:Boolean) : Integer; {$I ltrapi_callconvention};
Function LTR22_SyncPhaze(module:pTLTR22; timeout:LongWord) : Integer; {$I ltrapi_callconvention};
Function LTR22_SwitchADCStartStop(module:pTLTR22;Value:Boolean) : Integer; {$I ltrapi_callconvention};
Function LTR22_SwitchMeasureADCZero(module:pTLTR22;Value:Boolean) : Integer; {$I ltrapi_callconvention};
Function LTR22_SetFreq(module:pTLTR22;adc384:Boolean;Freq_dv:Byte) : Integer; {$I ltrapi_callconvention};
Function LTR22_SetADCRange(module:pTLTR22;ADCChannel:Byte;ADCChannelRange:Byte) : Integer; {$I ltrapi_callconvention};
Function LTR22_SetADCChannel(module:pTLTR22;ADCChannel:Byte;EnableADC:Boolean) : Integer; {$I ltrapi_callconvention};
Function LTR22_GetCalibrovka(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_Recv(module:pTLTR22; dataLongWordArray:Pointer; tstampLongWord:Pointer; size:LongWord; timeout:LongWord) : Integer; {$I ltrapi_callconvention};
Function LTR22_GetModuleDescription(module:pTLTR22) : Integer; {$I ltrapi_callconvention};
Function LTR22_ProcessData(module:pTLTR22; dataSourceLongWordArray:Pointer; dataDestinationDouble:Pointer;
                Size:LongWord;calibrMainPset:Boolean;calibrExtraVolts:Boolean;OverflowFlagsByteArray:Pointer) : Integer; {$I ltrapi_callconvention};

Function LTR22_ReadAVREEPROM(module:pTLTR22; dataByteArray:Pointer; address:LongWord;size:LongWord) : Integer; {$I ltrapi_callconvention};
Function LTR22_WriteAVREEPROM(module:pTLTR22; dataByteArray:Pointer;address:LongWord;size:LongWord) : Integer; {$I ltrapi_callconvention};

Function LTR22_GetErrorString(Index:Integer) : string; {$I ltrapi_callconvention};

implementation
        Function LTR22_Init(module:pTLTR22) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_Open(module:pTLTR22; saddr:LongWord; sport:LongWord;csnArrayByte:Pointer;cc:WORD) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_Close(module:pTLTR22) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_IsOpened(module:pTLTR22) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_GetConfig(module:pTLTR22) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SetConfig(module:pTLTR22) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_StartADC(module:pTLTR22; WaitSync:Boolean) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_StopADC(module:pTLTR22) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_ClearBuffer(module:pTLTR22; wait_response:Boolean) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SetSyncPriority(module:pTLTR22; SyncMaster:Boolean) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SyncPhaze(module:pTLTR22; timeout:LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SwitchADCStartStop(module:pTLTR22;Value:Boolean) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SwitchMeasureADCZero(module:pTLTR22;Value:Boolean) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SetFreq(module:pTLTR22;adc384:Boolean;Freq_dv:Byte) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SetADCRange(module:pTLTR22;ADCChannel:Byte;ADCChannelRange:Byte) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_SetADCChannel(module:pTLTR22;ADCChannel:Byte;EnableADC:Boolean) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_GetCalibrovka(module:pTLTR22) : Integer;  {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_Recv(module:pTLTR22; dataLongWordArray:Pointer; tstampLongWord:Pointer; size:LongWord; timeout:LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_GetModuleDescription(module:pTLTR22) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_ProcessData(module:pTLTR22; dataSourceLongWordArray:Pointer; dataDestinationDouble:Pointer;
                        Size:LongWord;calibrMainPset:Boolean;calibrExtraVolts:Boolean;OverflowFlagsByteArray:Pointer) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';

        Function LTR22_ReadAVREEPROM(module:pTLTR22; dataByteArray:Pointer; address:LongWord;size:LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';
        Function LTR22_WriteAVREEPROM(module:pTLTR22; dataByteArray:Pointer;address:LongWord;size:LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr22api';

        Function LTR22_GetErrorString(Index:Integer) : string; {$I ltrapi_callconvention}; external 'ltr22api';
end.
