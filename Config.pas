unit Config;
interface
uses Windows;

function VoltToCode(Volt: Double): Integer;
function CodeToVolt(Code: Integer): Double;
procedure Log(OutputDbgString: String);

var
  HistorySection: TRTLCriticalSection;
  DACSection: TRTLCriticalSection;
  DAC_max_signal : Integer;
  DAC_min_signal : Integer;
const
  DevicesAmount     = 2;
  DevicePeriod : array[0..1] of Double =
  (
      0.601,
      0.55
  );
  ChannelsPerDevice = 1;
  ChannelsAmount    = DevicesAmount*ChannelsPerDevice;

// Время, за которое будет отображаться блок (в мс)
  ADC_reading_time   = 10;
// Дополнительный  постоянный таймаут на прием данных (в мс)
  ADC_possible_delay = 1000;

  CalibrateMiliSecondsCut = 2000;
  InnerBufferPagesAmount = 4*(CalibrateMiliSecondsCut/ADC_reading_time);   //1;//

  DAC_max_VOLT_signal   = 3;
  DAC_min_VOLT_signal   = 0;

  DAC_dataByChannel     = 1;
  DAC_possible_delay    = 2000;

  DAC_packSize          = DevicesAmount*DAC_dataByChannel;

  MedianDeep    = 39;
  FreshDeep    = 1;
type
  TFilePack = array[0..ChannelsAmount] of TextFile;
  THistory = array[0..ChannelsAmount-1] of array of Double;
implementation

function VoltToCode(Volt: Double): Integer;
var
  DAC_max_signal : Integer;
begin
  Result :=  Trunc(Volt*65535/20);
end;

function CodeToVolt(Code: Integer): Double;
begin
  Result := Code*20/65535;
end;

procedure Log(OutputDbgString: String);
begin
 OutputDebugString(PChar(' - '+OutputDbgString+'     - '));
end;

end.
