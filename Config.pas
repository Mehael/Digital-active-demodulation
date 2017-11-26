unit Config;
interface
uses Windows;

function BooleanToString(Value: Boolean): string;
function VoltToCode(Volt: Double): Integer;
function CodeToVolt(Code: Integer): Double;
procedure Log(OutputDbgString: String);

var
  HistorySection: TRTLCriticalSection;
  DACSection: TRTLCriticalSection;
  DAC_max_signal : Integer;
  DAC_min_signal : Integer;
  VoltResetByDevice : array[0..1] of Double =
  (
      0.60,
      0.62
  );
  BigSignalThreshold : Integer;
  outputMultiplicators : array [0..1] of Integer;
  MedianDeep : Integer;

  ADC_reading_time : Integer;
  InnerBufferPagesAmount : Integer;
  DevicesAmount : Integer;
  ChannelsAmount  : Integer;
  DAC_packSize : Integer; 

const
  ChannelsPerDevice = 1;
  ADC_possible_delay = 100;

  CalibrateMiliSecondsCut = 2000;

  DAC_max_VOLT_signal   = 3;
  DAC_min_VOLT_signal   = 0;

  DAC_dataByChannel     = 1;
  DAC_possible_delay    = 2000;

  FreshDeep    = 1;
  LineBreak    = #13#10;
type
  THistory = array of array of Double;
  TConfig = class(TObject)
    ProcessTime : string;
    SkippedNumbers : string;
    Calibration : string;
    UnlimWriting : string;
    ShowSignal : string;
    ACPrange : string;
    ACPmode : string;
    ACPfreq : string;
    ACPbits : string;
    OptWide : string;
    ResetVt1 : string;
    ResetVt2 : string;
    WorkpointSpeedLimit : string;
    Mult1 : string;
    Mult2 : string;
    BlocksForLowfreqCalculation : string;
    TimeToWriteBlock : string;
  end;

implementation

function VoltToCode(Volt: Double): Integer;
begin
  Result :=  Trunc(Volt*65535/20);
end;

function CodeToVolt(Code: Integer): Double;
begin
  Result := Code*20/65535;
end;

function BooleanToString(Value: Boolean): string;
begin
  if (Value) then Result := 'Да'
  else Result := 'Нет';
end;

procedure Log(OutputDbgString: String);
begin
 OutputDebugString(PChar(' - '+OutputDbgString+'     - '));
end;

end.
