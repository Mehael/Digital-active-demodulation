unit ltr114api;
interface
uses SysUtils, ltrapi, ltrapitypes;
const
   LTR114_CLOCK                  = 15000; // �������� ������� ������ � ���
   LTR114_ADC_DIVIDER            = 1875;    //�������� ������� ��� ���
   LTR114_MAX_CHANNEL            = 16;    // ������������ ����� ���������� �������
   LTR114_MAX_R_CHANNEL          = 8;     //������������ ����� ���������� ������� ��� ��������� �������������
   LTR114_MAX_LCHANNEL           = 128;   // ������������ ����� ���������� �������
   LTR114_MID                    = $7272;   ////id ������ LTR114

   LTR114_ADC_RANGEQNT           = 3;     // ���������� ���������� ��������� ����������
   LTR114_R_RANGEQNT             = 3;     // ���������� ���������� ��������� �������������
   LTR114_SCALE_INTERVALS        = 3;
   LTR114_MAX_SCALE_VALUE        = 8000000; //��� �����, ��������������� ������������� �������� ��������� ���������

   //����� ��� ������� LTR114_ProcessData
   LTR114_PROCF_NONE             = $00;
   LTR114_PROCF_VALUE            = $01;   //������� ������������� �������� ���� � ���������� ��������
   LTR114_PROCF_AVGR             = $02;   //������� ������������� ���������� ���� ��������� - +I � -I
   //���� ���������� ����������
   LTR114_URANGE_10              = 0;
   LTR114_URANGE_2               = 1;
   LTR114_URANGE_04              = 2;
   //���� ���������� �������������
   LTR114_RRANGE_400             = 0;
   LTR114_RRANGE_1200            = 1;
   LTR114_RRANGE_4000            = 2;

   //������ ��������� ������
   LTR114_CORRECTION_MODE_NONE   = 0;
   LTR114_CORRECTION_MODE_INIT   = 1;
   LTR114_CORRECTION_MODE_AUTO   = 2;

   //������ �������������
   LTR114_SYNCMODE_NONE          = 0;
   LTR114_SYNCMODE_INTERNAL      = 1;
   LTR114_SYNCMODE_MASTER        = 2;
   LTR114_SYNCMODE_EXTERNAL      = 4;

   //������ �������� ������
   LTR114_CHECKMODE_X0Y0         = 1;
   LTR114_CHECKMODE_X5Y0         = 2;
   LTR114_CHECKMODE_X0Y5         = 4;
   LTR114_CHECKMODE_ALL          = 7;

   //���� ����������� ������� ���������
   LTR114_MEASMODE_U             = $00;
   LTR114_MEASMODE_R             = $20;
   LTR114_MEASMODE_NR            = $28;
   //���� ����������� ������� ����������
   LTR114_MEASMODE_NULL          = $10;     //��������� ������������ ����
   LTR114_MEASMODE_DAC12         = $11;     //��������� DAC1 - DAC2
   LTR114_MEASMODE_NDAC12        = $12;
   LTR114_MEASMODE_NDAC12_CBR    = $38;
   LTR114_MEASMODE_DAC12_CBR     = $30;

   LTR114_MEASMODE_DAC12_INTR      = $91;     //��������� DAC1 - DAC2 ���������� ���������
   LTR114_MEASMODE_NDAC12_INTR     = $92;
   LTR114_MEASMODE_DAC12_INTR_CBR  = $B8;     //��������� DAC1 - DAC2 ���������� ���������
   LTR114_MEASMODE_NDAC12_INTR_CBR = $B0;
   LTR114_MEASMODE_X0Y0            = $40;
   LTR114_MEASMODE_X5Y0            = $50;
   LTR114_MEASMODE_X0Y5            = $70;


   //���� �������������� ������������
   LTR114_FEATURES_STOPSW          = 1;   //������������ ����� ��������������
   LTR114_FEATURES_THERM           = 2;   //���������
   LTR114_FEATURES_CBR_DIS         = 4;   //������ ��������� ����������
   LTR114_MANUAL_OSR               = 8;   //������ ��������� OSR


   //��������� ������ ��-���������
   LTR114_DEF_DIVIDER              = 2;
   LTR114_DEF_INTERVAL             = 0;
   LTR114_DEF_OSR                  = 0;
   LTR114_DEF_SYNC_MODE            =LTR114_SYNCMODE_INTERNAL;

   //���� ������ ������ LTR114
   LTR114_TEST_INTERFACE           = 1;  //�������� ���������� PC-LTR114
   LTR114_TEST_DAC                 = 2;  //�������� DAC
   LTR114_TEST_DAC1_VALUE          = 3;  //�������� ��������� �������� ��� DAC1
   LTR114_TEST_DAC2_VALUE          = 4;  //�������� ��������� �������� ��� DAC2
   LTR114_TEST_SELF_CALIBR         = 5;  //���������� ��������� ������� ���� ��� ����������

   //��������� ������������� �������� ���������� PC-LTR114
   LTR114_TEST_INTERFACE_DATA_L    = $55;
   LTR114_TEST_INTERFACE_DATA_H    = $AA;


   // ���� ������, ������������ ��������� ���������� */
   LTR114_ERR_INVALID_DESCR        = -10000; // ��������� �� ��������� ������ ����� NULL
   LTR114_ERR_INVALID_SYNCMODE     = -10001; // ������������ ����� ������������� ������ ���
   LTR114_ERR_INVALID_ADCLCHQNT    = -10002; // ������������ ���������� ���������� �������
   LTR114_ERR_INVALID_ADCRATE      = -10003; // ������������ �������� ������� ������������� ��� ������
   LTR114_ERR_GETFRAME             = -10004; // ������ ��������� ����� ������ � ���
   LTR114_ERR_GETCFG               = -10005; // ������ ������ ������������
   LTR114_ERR_CFGDATA              = -10006; // ������ ��� ��������� ������������ ������
   LTR114_ERR_CFGSIGNATURE         = -10007; // �������� �������� ������� ����� ���������������� ������ ������
   LTR114_ERR_CFGCRC               = -10008; // �������� ����������� ����� ���������������� ������
   LTR114_ERR_INVALID_ARRPOINTER   = -10009; // ��������� �� ������ ����� NULL
   LTR114_ERR_ADCDATA_CHNUM        = -10010; // �������� ����� ������ � ������� ������ �� ���
   LTR114_ERR_INVALID_CRATESN      = -10011; // ��������� �� ������ � �������� ������� ������ ����� NULL
   LTR114_ERR_INVALID_SLOTNUM      = -10012; // ������������ ����� ����� � ������
   LTR114_ERR_NOACK                = -10013; // ��� ������������� �� ������
   LTR114_ERR_MODULEID             = -10014; // ������� �������� ������, ��������� �� LTR114
   LTR114_ERR_INVALIDACK           = -10015; // �������� ������������� �� ������
   LTR114_ERR_ADCDATA_SLOTNUM      = -10016; // �������� ����� ����� � ������ �� ���
   LTR114_ERR_ADCDATA_CNT          = -10017; // �������� ������� ������� � ������ �� ���
   LTR114_ERR_INVALID_LCH          = -10018; // �������� ����� ���. ������
   LTR114_ERR_CORRECTION_MODE      = -10019; // �������� ����� ��������� ������
   LTR114_ERR_GET_PLD_VER          = -10020; // ������ ��� ������ ������ �����
   LTR114_ERR_ALREADY_RUN          = -10021; // ������ ��� ������� ������� ����� ������ ����� �� ��� �������
   LTR114_ERR_MODULE_CLOSED        = -10022; //

//================================================================================================*/
type
    {$A4}
    LTR114_GainSet = record
        Offset:double;                      // �������� ���� */
        Gain  :double;                      // ���������� ����������� */
    end;

    LTR114_CbrCoef = record
        U: array[0..LTR114_ADC_RANGEQNT-1] of single;       //�������� ��� ��� ���������� ��������� ����������
        I: array[0..LTR114_R_RANGEQNT-1]   of single;       //�������� ����� ��� ���������� ��������� �������������
        UIntr: array[0..LTR114_ADC_RANGEQNT-1] of single;   //�������� ������������� ����������
    end;


    TINFO_LTR114 = record
      Name   : array [0..7]  of AnsiChar;   // �������� ������ (������)
      Serial : array [0..15] of AnsiChar;  // �������� ����� ������ (������)
      VerMCU : word;                  // ������ �� ������ (������� ���� - ��������, ������� - ��������
      Date : array [0..13] of AnsiChar; // ���� �������� �� (������)                                       */
      VerPLD : byte;                            //������ �������� ����
      CbrCoef : LTR114_CbrCoef;                 // ��������� ������������� ������������ */
    end;

    //
    TSCALE_LTR114 = record
        Null    : integer;        //�������� ����
        Ref     : integer;         //�������� +�����
        NRef    : integer;       //�������� -�����
        Interm  : integer;
        NInterm : integer;
    end;


     //���������� � ������
    TCBRINFO = record
        Coef : array [0..LTR114_SCALE_INTERVALS-1] of LTR114_GainSet;        //����������� �� ����� �������������� �������� Gain � Offset
        TempScale : ^TSCALE_LTR114;            //������ ��������� ��������� �����/����
        Index : TSCALE_LTR114;          //���������� ��������� � TempScale
        LastVals : TSCALE_LTR114;       //��������� ���������

        HVal : integer;
        LVal : integer;
    end;


    //��������� ����������� ������
    LTR114_LCHANNEL = record
       MeasMode : byte;       //����� ���������
       Channel  : byte;       //���������� �����
       Range    : byte;       //�������� ���������*/
    end;

   //��������� ������ LTR114
   TLTR114= record                     // ���������� � ������ LTR114
       size:integer;                           // ������ ��������� � ������
       Channel:TLTR;                           // ��������� ������ ����� � �������
       AutoCalibrInfo: array[0..LTR114_ADC_RANGEQNT-1] of TCBRINFO; // ������ ��� ���������� ������������� ����. ��� ������� ���������
       LChQnt : integer;                              // ���������� �������� ���������� �������
       LChTbl : array[0..LTR114_MAX_LCHANNEL-1] of LTR114_LCHANNEL;        // ����������� ������� � ����������� ���������� �������

       Interval : word;                          //����� ������������ ���������

       SpecialFeatures : byte;                   //�������������� ����������� ������ (����������� ����������, ���������� ����������)
       AdcOsr : byte;                             //�������� ���������. ��� - ����������� � ������������ � �������� �������������
       SyncMode : byte;                           //����� �������������

       FreqDivider : integer;                       // �������� ������� ��� (2..8000)
                                           // ������� ������������� ����� F = LTR114_CLOCK/(LTR114_ADC_DIVIDER*FreqDivider)

       FrameLength : integer;                       //������ ������, ������������ ������� �� ���� ����
                                           //��������������� ����� ������ LTR114_SetADC
       Active : boolean;                           //��������� �� ������ � ������ ����� ������
       Reserve : integer;
       ModuleInfo : TINFO_LTR114;                 // ���������� � ������ LTR114
    end;
//================================================================================================*/
    pTLTR114=^TLTR114;
//================================================================================================*/
     {$A+}

Function LTR114_Init(hnd : pTLTR114) : integer; {$I ltrapi_callconvention};
Function LTR114_Open(hnd: pTLTR114; net_addr : LongWord; net_port: word; crate_snChar : Pointer; slot_num : integer) : integer; {$I ltrapi_callconvention};
Function LTR114_Close(hnd: pTLTR114) : integer; {$I ltrapi_callconvention};
Function LTR114_GetConfig(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_Calibrate(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_SetADC(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_Start(hnd: pTLTR114): integer; {$I ltrapi_callconvention};
Function LTR114_Stop(hnd: pTLTR114): integer; {$I ltrapi_callconvention};

Function LTR114_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};

Function LTR114_GetFrame(hnd: pTLTR114; bufDWORD : Pointer):integer; {$I ltrapi_callconvention};

Function LTR114_Recv(hnd: pTLTR114; dataDWORD : Pointer; tmarkDWORD : Pointer; size : LongWord; timeout : LongWord):integer; {$I ltrapi_callconvention};
Function LTR114_ProcessData(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; sizeINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention};
Function LTR114_ProcessDataTherm(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; thermDOUBLE : Pointer; sizeINT : Pointer; tcntINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention};

Function LTR114_CheckInputs(hnd: pTLTR114; ChannelsMask : integer; CheckMode : integer; res_dataDOUBLE : Pointer; sizeINT : Pointer):integer; {$I ltrapi_callconvention};

Function LTR114_SetRef(hnd: pTLTR114; range : integer; middle:boolean) :integer; {$I ltrapi_callconvention};
Function LTR114_GetDllVer() : word; {$I ltrapi_callconvention};

Function LTR114_CreateLChannel(MeasMode : integer; Channel : integer; Range: integer) : LTR114_LCHANNEL; {$I ltrapi_callconvention};


//================================================================================================*/
implementation
      Function LTR114_Init(hnd : pTLTR114) : integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Open(hnd: pTLTR114; net_addr : LongWord; net_port: word; crate_snChar : Pointer; slot_num : integer) : integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Close(hnd: pTLTR114) : integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_GetConfig(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Calibrate(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_SetADC(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Start(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_Stop(hnd: pTLTR114): integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr114api' name 'LTR114_GetErrorString';

      Function LTR114_GetFrame(hnd: pTLTR114; bufDWORD : Pointer):integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_Recv(hnd: pTLTR114; dataDWORD : Pointer; tmarkDWORD : Pointer; size : LongWord; timeout : LongWord):integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_ProcessData(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; sizeINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_ProcessDataTherm(hnd: pTLTR114; srcDWORD: Pointer; destDOUBLE: Pointer; thermDOUBLE : Pointer; sizeINT : Pointer; tcntINT : Pointer; correction_mode : integer; flags : integer):integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_CheckInputs(hnd: pTLTR114; ChannelsMask : integer; CheckMode : integer; res_dataDOUBLE : Pointer; sizeINT : Pointer):integer; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_SetRef(hnd: pTLTR114; range : integer; middle:boolean) :integer; {$I ltrapi_callconvention}; external 'ltr114api';
      Function LTR114_GetDllVer() : word; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_CreateLChannel(MeasMode : integer; Channel : integer; Range: integer) : LTR114_LCHANNEL; {$I ltrapi_callconvention}; external 'ltr114api';

      Function LTR114_GetErrorString(err: Integer) : string; {$I ltrapi_callconvention};
      begin
        LTR114_GetErrorString:=string(_get_err_str(err));
      end;
end.
