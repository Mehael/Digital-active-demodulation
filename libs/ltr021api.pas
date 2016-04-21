//-----------------------------------------------------------------------------
// crate controller LTR021
//-----------------------------------------------------------------------------
unit ltr021api;
interface
uses SysUtils, ltrapi,ltrapidefine,ltrapitypes;
const
// коды ошибок
        LTR021_OK                     =LTR_OK;    //Выполнено без ошибок.
        LTR021_ERROR_GET_ARRAY        =-200;     //Ошибка выполнения команды GET_ARRAY.
        LTR021_ERROR_PUT_ARRAY        =-201;     //Ошибка выполнения команды PUT_ARRAY.
        LTR021_ERROR_GET_MODULE_NAME  =-202;     //Ошибка выполнения команды GET_MODULE_NAME.
        LTR021_ERROR_GET_MODULE_GESCR =-203;     //Ошибка выполнения команды GET_MODULE_DESCRIPTOR.
        LTR021_ERROR_CRATE_TYPE       =-204;     //неверный тип крейта.
//-----------------------------------------------------------------------------
type
TDESCRIPTION_LTR021=packed record
                Module:TDESCRIPTION_MODULE;
                Cpu:TDESCRIPTION_CPU;
                Fpga:TDESCRIPTION_FPGA;
                Interface_:TDESCRIPTION_INTERFACE;
            end;


_LTR021_Sync_Type = ( LTR021_No_Sync=0,
                      LTR021_Rising_Start,
                      LTR021_Falling_Start,
                      LTR021_Rising_Sync,
                      LTR021_Falling_Sync,
                      LTR021_INT_START,
                      LTR021_INT_SEC);
{$A4}
TLTR021 = record
    ltr:TLTR;
end;
pTLTR021 = ^TLTR021;
{$A+}
//-----------------------------------------------------------------------------
Function  LTR021_Init(module:pTLTR021):integer; {$I ltrapi_callconvention};
Function  LTR021_Open(module:pTLTR021; saddr:LongWord; sport:word; csnCHAR:Pointer):integer;{$I ltrapi_callconvention};
Function  LTR021_Close(module:pTLTR021):integer;{$I ltrapi_callconvention};
Function  LTR021_GetArray(module:pTLTR021; bufBYTE:Pointer; size:LongWord; address:LongWord):integer;{$I ltrapi_callconvention};
Function  LTR021_PutArray(module:pTLTR021; bufBYTE:Pointer; size:LongWord; address:LongWord):integer;{$I ltrapi_callconvention};
Function  LTR021_GetDescription(module:pTLTR021; descriptionTDESCRIPTION_LTR021:Pointer):integer;{$I ltrapi_callconvention};
Function  LTR021_SetCrateSyncType(module:pTLTR021; SyncType:LongWord):integer;{$I ltrapi_callconvention};

implementation

  Function  LTR021_Init(module:pTLTR021):integer; {$I ltrapi_callconvention}; external 'ltr021api';
  Function  LTR021_Open(module:pTLTR021; saddr:LongWord; sport:word; csnCHAR:Pointer):integer;  {$I ltrapi_callconvention}; external'ltr021api';
  Function  LTR021_Close(module:pTLTR021):integer;  {$I ltrapi_callconvention}; external'ltr021api';
  Function  LTR021_GetArray(module:pTLTR021; bufBYTE:Pointer; size:LongWord; address:LongWord):integer;  {$I ltrapi_callconvention}; external'ltr021api';
  Function  LTR021_PutArray(module:pTLTR021; bufBYTE:Pointer; size:LongWord; address:LongWord):integer;  {$I ltrapi_callconvention}; external'ltr021api';
  Function  LTR021_GetDescription(module:pTLTR021; descriptionTDESCRIPTION_LTR021:Pointer):integer;  {$I ltrapi_callconvention}; external'ltr021api';
  Function  LTR021_SetCrateSyncType(module:pTLTR021; SyncType:LongWord):integer;  {$I ltrapi_callconvention}; external'ltr021api';




end.
