unit ltr11api;
interface
uses SysUtils, ltrapi, ltrapitypes;
const
    LTR11_CLOCK                  =15000; // �������� ������� ������ � ���
    LTR11_MAX_CHANNEL            =32;    // ������������ ����� ���������� �������
    LTR11_MAX_LCHANNEL           =128;   // ������������ ����� ���������� �������
    LTR11_ADC_RANGEQNT           =4;     // ���������� ������� ���������� ���
    // ���� ������, ������������ ��������� ����������
    LTR11_ERR_INVALID_DESCR        =-1000; // ��������� �� ��������� ������ ����� NULL
    LTR11_ERR_INVALID_ADCMODE      =-1001; // ������������ ����� ������� ���
    LTR11_ERR_INVALID_ADCLCHQNT    =-1002; // ������������ ���������� ���������� �������
    LTR11_ERR_INVALID_ADCRATE      =-1003; // ������������ �������� ������� ������������� ��� ������
    LTR11_ERR_INVALID_ADCSTROBE    =-1004; // ������������ �������� �������� ������� ��� ���
    LTR11_ERR_GETFRAME             =-1005; // ������ ��������� ����� ������ � ���
    LTR11_ERR_GETCFG               =-1006; // ������ ������ ������������
    LTR11_ERR_CFGDATA              =-1007; // ������ ��� ��������� ������������ ������
    LTR11_ERR_CFGSIGNATURE         =-1008; // �������� �������� ������� ����� ���������������� ������ ������
    LTR11_ERR_CFGCRC               =-1009; // �������� ����������� ����� ���������������� ������
    LTR11_ERR_INVALID_ARRPOINTER   =-1010; // ��������� �� ������ ����� NULL
    LTR11_ERR_ADCDATA_CHNUM        =-1011; // �������� ����� ������ � ������� ������ �� ���
    LTR11_ERR_INVALID_CRATESN      =-1012; // ��������� �� ������ � �������� ������� ������ ����� NULL
    LTR11_ERR_INVALID_SLOTNUM      =-1013; // ������������ ����� ����� � ������
    LTR11_ERR_NOACK                =-1014; // ��� ������������� �� ������
    LTR11_ERR_MODULEID             =-1015; // ������� �������� ������, ��������� �� LTR11
    LTR11_ERR_INVALIDACK           =-1016; // �������� ������������� �� ������
    LTR11_ERR_ADCDATA_SLOTNUM      =-1017; // �������� ����� ����� � ������ �� ���
    LTR11_ERR_ADCDATA_CNT          =-1018; // �������� ������� ������� � ������ �� ���
    LTR11_ERR_INVALID_STARTADCMODE =-1019; // �������� ����� ������ ����� ������
    // ������ ������� ���
    LTR11_ADCMODE_ACQ            =$00;  // ���� ������
    LTR11_ADCMODE_TEST_U1P       =$04;  // ������ ��������� ���������� +U1
    LTR11_ADCMODE_TEST_U1N       =$05;  // ������ ��������� ���������� -U1
    LTR11_ADCMODE_TEST_U2N       =$06;  // ������ ��������� ���������� -U2
    LTR11_ADCMODE_TEST_U2P       =$07;  // ������ ��������� ���������� +U2
    // ����� ������ ����� ������ �������
    LTR11_STARTADCMODE_INT       =0;     // ���������� ����� =�� ������� �����;
    LTR11_STARTADCMODE_EXTRISE   =1;     // �� ������ �������� �������;
    LTR11_STARTADCMODE_EXTFALL   =2;     // �� ����� �������� �������.
    // �������� ������������ ���
    LTR11_INPMODE_EXTRISE        =0;     // ������ �������������� �� ������ �������� �������
    LTR11_INPMODE_EXTFALL        =1;     // ������ �������������� �� ����� �������� �������
    LTR11_INPMODE_INT            =2;     // ���������� ������ ���

    // ������� �������� �������
    LTR11_CHRANGE_10000MV        = 0;     // +-10 � (10000 ��)
    LTR11_CHRANGE_2500MV         = 1;     // +-2.5 � (2500 ��)
    LTR11_CHRANGE_625MV          = 2;     // +-0.625 � (625 ��)
    LTR11_CHRANGE_156MV          = 3;     // +-0.156 � (156 ��)
    // ������ ������ �������
    LTR11_CHMODE_DIFF            =0; // ���. �����., 16 �������
    LTR11_CHMODE_COMM            =1; // ����� �����, 32 �������
    LTR11_CHMODE_ZERO            =2; // ��������� ����



    // ���������, ����������� ��� �������������
    LTR11_CHGANE_10000MV         =LTR11_CHRANGE_10000MV;
    LTR11_CHGANE_2500MV          =LTR11_CHRANGE_2500MV;
    LTR11_CHGANE_625MV           =LTR11_CHRANGE_625MV;
    LTR11_CHGANE_156MV           =LTR11_CHRANGE_625MV;
    LTR11_CHMODE_16CH            =LTR11_CHMODE_DIFF;
    LTR11_CHMODE_32CH            =LTR11_CHMODE_COMM;



//================================================================================================
type
   {$A4}
   LTR11_GainSet = record
        Offset:double;                      // �������� ����
        Gain  :double;                      // ���������� �����������
   end;
   TINFO_LTR11 = record              // ���������� � ������
        Name  :array[0..15]of AnsiChar;         // �������� ������ (������)
        Serial:array[0..23]of AnsiChar;         // �������� ����� ������ (������)
        Ver   :word;                        // ������ �� ������ (������� ���� - ��������,������� - ��������
        Date:array[0..13]of AnsiChar;           // ���� �������� �� (������)
        CbrCoef:array[0..LTR11_ADC_RANGEQNT-1]of LTR11_GainSet ;      // ������������� ������������ ��� ������� ���������
    end;

    ADC_SET = record
        divider:integer;               // �������� �������� ������� ������, ��������:
                                       // 2..65535
                                       //
        prescaler:integer;             // ����������� �������� ������� ������:
                                       // 1, 8, 64, 256, 1024
                                       //
    end;


    TLTR11 = record                     // ���������� � ������ LTR11
      size:integer;                           // ������ ��������� � ������
      Channel:TLTR;                           // ��������� ������ ����� � �������
      StartADCMode:integer;                   // ����� ������ ����� ������:
                                              // LTR11_STARTADCMODE_INT     - ���������� ����� (��
                                              //                              ������� �����);
                                              // LTR11_STARTADCMODE_EXTRISE - �� ������ ��������
                                              //                              �������;
                                              // LTR11_STARTADCMODE_EXTFALL - �� ����� ��������
                                              //                              �������.
                                              //
      InpMode:integer;                        // ����� ����� ������ � ���
                                              //  LTR11_INPMODE_INT     - ���������� ������ ���
                                              //                          (������� �������� AdcRate)
                                              //  LTR11_INPMODE_EXTRISE - �� ������ �������� �������
                                              //  LTR11_INPMODE_EXTFALL - �� ����� �������� �������
                                              //
      LChQnt:integer;                         // ����� �������� ���������� ������� (������ �����)
      LChTbl:array[0..LTR11_MAX_LCHANNEL-1]of byte;
                                              // ����������� ������� � ��������� ����������� ��������
                                              // ��������� ������ ����� �������: MsbGGMMCCCCLsb
                                              //   GG   - ������� ��������:
                                              //          0 - +-10 �;
                                              //          1 - +-2.5 �;
                                              //          2 - +-0.625 �;
                                              //          3 - +-0.156�;
                                              //   MM   - �����:
                                              //          0 - 16-���������, ������ 1-16;
                                              //          1 - ��������� ������������ ����������
                                              //              �������� ����;
                                              //          2 - 32-���������, ������ 1-16;
                                              //          3 - 32-���������, ������ 17-32;
                                              //   CCCC - ����� ����������� ������:
                                              //          0 - ����� 1 (17);
                                              //          . . .
                                              //          15 - ����� 16 (32).
                                              //
      ADCMode:integer;                        // ����� ����� ������ ��� ��� ��������� ������
      ADCRate:ADC_SET;                        // ��������� ��� ������� ������� ������������� ���
                                              // ������� �������������� �� �������:
                                              // F = LTR11_CLOCK/(prescaler*(divider+1)
                                              // ��������!!! ������� 400 ��� �������� ������ �������:
                                              // ��� �� ��������� ����������� � �������� ������ �����
                                              // ��������� ��������:
                                              //   prescaler = 1
                                              //   divider   = 36
                                              //
      ChRate:double;                           // ������� ������ ������ � ��� (������ �����) ���
                                              //���������� ������� ���
                                              //
      ModuleInfo:TINFO_LTR11;
    end;
//================================================================================================
    pTLTR11=^TLTR11;
//================================================================================================
{$A+}
{ ������� ���������� ����� var/out}
Function LTR11_Init(var hnd: TLTR11):integer; overload;
Function LTR11_Open(var hnd: TLTR11; net_addr : LongWord; net_port : Word;
                        csn: string; slot: integer): Integer; overload;
Function LTR11_IsOpened(var hnd: TLTR11):integer;
Function LTR11_Close(var hnd: TLTR11) : Integer; overload;

Function LTR11_GetConfig(var hnd: TLTR11):integer; overload;
Function LTR11_SetADC(var hnd: TLTR11):integer; overload;
Function LTR11_Start(var hnd: TLTR11):integer; overload;
Function LTR11_Stop(var hnd: TLTR11):integer; overload;

Function LTR11_Recv(var hnd: TLTR11; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;
Function LTR11_Recv(var hnd: TLTR11; out data : array of LongWord; size: LongWord; tout : LongWord): Integer; overload;

Function LTR11_ProcessData(var hnd: TLTR11; var src : array of LongWord;
                           out dest : array of Double; var size: Integer;
                           calibr : Boolean; volt : boolean) : Integer; overload;
Function LTR11_GetFrame(var hnd: TLTR11; out buf: array of LongWord):integer; overload;

Function LTR11_FindAdcFreqParams(adcFreq:Double; out prescaler : Integer; out divider : Integer; out resultAdcFreq : double):Integer;
Function LTR11_GetErrorString(err:integer):string;
Function LTR11_CreateLChannel(phy_ch: byte; mode: byte; gain : byte) : byte;
Function LTR11_SearchFirstFrame(var hnd : TLTR11; var data : array of LongWord;
                              size : LongWord; out index : LongWord) : Integer;




{ ������ �������, ����������� ������ ��� ������������� }
{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
Function LTR11_Init(module:pTLTR11):integer; {$I ltrapi_callconvention}; overload;
Function LTR11_Open(module:pTLTR11; net_addrDWORD:LongWord; net_portWORD:word; crate_snCHAR:Pointer;
    slot_numINT:integer):integer; {$I ltrapi_callconvention};overload;
Function LTR11_Close(module:pTLTR11):integer; {$I ltrapi_callconvention}; overload;

Function LTR11_GetConfig(module:pTLTR11):integer; {$I ltrapi_callconvention}; overload;
Function LTR11_SetADC(module:pTLTR11):integer; {$I ltrapi_callconvention}; overload;
Function LTR11_Start(module:pTLTR11):integer; {$I ltrapi_callconvention}; overload;
Function LTR11_Stop(module:pTLTR11):integer; {$I ltrapi_callconvention}; overload;

Function LTR11_Recv(module:pTLTR11; dataDWORD : Pointer; tmarkDWORD : Pointer; size : LongWord; timeout : LongWord):integer; {$I ltrapi_callconvention}; overload;
Function LTR11_ProcessData(module:pTLTR11; srcDWORD:Pointer; destDOUBLE:Pointer; sizeINT:Pointer;
    calibrBOOL:boolean; voltBOOL:boolean):integer; {$I ltrapi_callconvention}; overload;

Function LTR11_GetFrame(module:pTLTR11; bufDWORD:Pointer):integer; {$I ltrapi_callconvention}; overload;
{$ENDIF}





//================================================================================================
implementation
    Function _init(var hnd: TLTR11):integer; {$I ltrapi_callconvention}; overload; external 'ltr11api' name 'LTR11_Init';
    Function _open(var hnd: TLTR11; net_addr : LongWord; net_port : Word; csn: PAnsiChar; slot: integer) : Integer; {$I ltrapi_callconvention}; external 'ltr11api' name 'LTR11_Open';
    Function _is_opened(var hnd: TLTR11) : Integer; {$I ltrapi_callconvention}; external 'ltr11api' name 'LTR11_IsOpened';
    Function _close(var hnd: TLTR11) : Integer; {$I ltrapi_callconvention};  overload; external 'ltr11api' name 'LTR11_Close';

    Function _get_config(var hnd: TLTR11):integer; {$I ltrapi_callconvention}; overload; external 'ltr11api' name 'LTR11_GetConfig';
    Function _set_adc(var hnd: TLTR11):integer; {$I ltrapi_callconvention}; overload; external 'ltr11api' name 'LTR11_SetADC';
    Function _start(var hnd: TLTR11):integer; {$I ltrapi_callconvention}; overload; external 'ltr11api' name 'LTR11_Start';
    Function _stop(var hnd: TLTR11):integer; {$I ltrapi_callconvention}; overload; external 'ltr11api' name 'LTR11_Stop';

    Function _recv(var hnd: TLTR11; out data; out tmark; size: LongWord; tout : LongWord): Integer; {$I ltrapi_callconvention};  external 'ltr11api' name 'LTR11_Recv';
    Function _process_data(var hnd: TLTR11; var src; out dest; var size: integer; calibr : Integer; volt : Integer): Integer;  {$I ltrapi_callconvention}; external 'ltr11api' name 'LTR11_ProcessData';
    Function _get_frame(var hnd: TLTR11; out buf):integer; {$I ltrapi_callconvention}; external 'ltr11api' name 'LTR11_GetFrame';
    Function _find_adc_freq_params(adcFreq:Double; out prescaler : Integer; out divider : Integer; out resultAdcFreq : double):Integer; {$I ltrapi_callconvention};  external 'ltr11api' name 'LTR11_FindAdcFreqParams';
    Function _get_err_str(err : integer) : PAnsiChar; {$I ltrapi_callconvention}; external 'ltr11api' name 'LTR11_GetErrorString';
    Function _create_lchannel(phy_ch: byte; mode: byte; gain : byte) : byte; {$I ltrapi_callconvention}; external 'ltr11api' name 'LTR11_CreateLChannel';
    Function _search_first_frame(var hnd : TLTR11; var data; size : LongWord; out index : LongWord) : Integer; {$I ltrapi_callconvention}; external 'ltr11api' name 'LTR11_SearchFirstFrame';



{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
    Function LTR11_Init(module:pTLTR11):integer; {$I ltrapi_callconvention}; overload; external 'ltr11api';
    Function LTR11_Open(module:pTLTR11; net_addrDWORD:LongWord; net_portWORD:word; crate_snCHAR:Pointer;
                      slot_numINT:integer):integer; {$I ltrapi_callconvention}; overload;external 'ltr11api';
    Function LTR11_Close(module:pTLTR11):integer; {$I ltrapi_callconvention};  overload; external 'ltr11api';
    
    Function LTR11_GetConfig(module:pTLTR11):integer;{$I ltrapi_callconvention}; external 'ltr11api';    
    Function LTR11_GetFrame(module:pTLTR11; bufDWORD:Pointer):integer; {$I ltrapi_callconvention}; external 'ltr11api';


    Function LTR11_ProcessData(module:pTLTR11; srcDWORD:Pointer; destDOUBLE:Pointer; sizeINT:Pointer;
                      calibrBOOL:boolean; voltBOOL:boolean):integer; {$I ltrapi_callconvention}; external 'ltr11api';
    Function LTR11_SetADC(module:pTLTR11):integer; {$I ltrapi_callconvention}; external 'ltr11api';
    Function LTR11_Start(module:pTLTR11):integer; {$I ltrapi_callconvention}; external 'ltr11api';
    Function LTR11_Stop(module:pTLTR11):integer; {$I ltrapi_callconvention}; external 'ltr11api';
    Function LTR11_Recv(module:pTLTR11; dataDWORD : Pointer; tmarkDWORD : Pointer; size : LongWord; timeout : LongWord):integer; {$I ltrapi_callconvention}; external 'ltr11api';
{$ENDIF}




    Function LTR11_Init(var hnd: TLTR11):integer; overload;
    begin
        LTR11_Init:=_init(hnd);
    end;

    Function LTR11_Open(var hnd: TLTR11; net_addr : LongWord; net_port : Word; csn: string; slot: integer): Integer; overload;
    begin
      LTR11_Open:=_open(hnd, net_addr, net_port, PAnsiChar(AnsiString(csn)), slot);
    end;

    Function LTR11_IsOpened(var hnd: TLTR11):integer;
    begin
      LTR11_IsOpened:=_is_opened(hnd);
    end;
    Function LTR11_Close(var hnd: TLTR11) : Integer; overload;
    begin
      LTR11_Close:=_close(hnd);
    end;
    Function LTR11_GetConfig(var hnd: TLTR11):integer; overload;
    begin
      LTR11_GetConfig:=_get_config(hnd);
    end;
    Function LTR11_SetADC(var hnd: TLTR11):integer; overload;
    begin
      LTR11_SetADC:=_set_adc(hnd);
    end;
    Function LTR11_Start(var hnd: TLTR11):integer; overload;
    begin
      LTR11_Start:=_start(hnd);
    end;
    Function LTR11_Stop(var hnd: TLTR11):integer; overload;
    begin
        LTR11_Stop:=_stop(hnd);
    end;

    Function LTR11_Recv(var hnd: TLTR11; out data : array of LongWord; out tmark : array of LongWord; size: LongWord; tout : LongWord): Integer;
    begin
      LTR11_Recv:=_recv(hnd, data, tmark, size, tout);
    end;

    Function LTR11_Recv(var hnd: TLTR11; out data : array of LongWord; size: LongWord; tout : LongWord): Integer;
    begin
      LTR11_Recv:=_recv(hnd, data, PLongWord(nil)^, size, tout);
    end;

    Function LTR11_ProcessData(var hnd: TLTR11; var src : array of LongWord;
                      out dest : array of Double; var size: Integer;
                      calibr : Boolean; volt : Boolean) : Integer;  overload;
    begin
      LTR11_ProcessData:=_process_data(hnd, src, dest, size, Integer(calibr) , Integer(volt));
    end;

    Function LTR11_GetFrame(var hnd: TLTR11; out buf: array of LongWord):integer; overload;
    begin
      LTR11_GetFrame:=_get_frame(hnd, buf);
    end;

    Function LTR11_GetErrorString(err: Integer) : string;
    begin
     LTR11_GetErrorString:=string(_get_err_str(err));
    end;

    Function LTR11_SearchFirstFrame(var hnd : TLTR11; var data : array of LongWord;
                              size : LongWord; out index : LongWord) : Integer;
    begin
      LTR11_SearchFirstFrame:= _search_first_frame(hnd, data, size, index);
    end;

    Function LTR11_FindAdcFreqParams(adcFreq:Double; out prescaler : Integer; out divider : Integer; out resultAdcFreq : double):Integer;
    begin
      LTR11_FindAdcFreqParams:=_find_adc_freq_params(adcFreq, prescaler, divider, resultAdcFreq);
    end;

    Function LTR11_CreateLChannel(phy_ch: byte; mode: byte; gain : byte) : byte;
    begin
      LTR11_CreateLChannel:=_create_lchannel(phy_ch, mode, gain);
    end;
end.
