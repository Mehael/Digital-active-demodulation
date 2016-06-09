unit Config;

interface
const
  DevicesAmount     = 2;
  DevicePeriod : array[0..DevicesAmount-1] of Integer =
  (
      390,
      390
  );
  ChannelsPerDevice = 1;
  ChannelsAmount    = DevicesAmount*ChannelsPerDevice;

// Время, за которое будет отображаться блок (в мс)
  ADC_reading_time   = 500;
// Дополнительный  постоянный таймаут на прием данных (в мс)
  ADC_possible_delay = 1000;

  CalibrateMiliSecondsCut = 4000;
  InnerBufferPagesAmount = (CalibrateMiliSecondsCut/ADC_reading_time);

  DAC_max_VOLT_signal   = 2.5;
  DAC_100signal_to_VOLT = 1.8;
  DAC_max_signal        = ((DAC_max_VOLT_signal*1000)/DAC_100signal_to_VOLT);
  DAC_min_signal        = 0;

  DAC_dataByChannel     = 100;
  DAC_possible_delay    = 2000;

  DAC_packSize          = DevicesAmount*DAC_dataByChannel;
type
  TFilePack = array[0..ChannelsAmount] of TextFile;
implementation
end.
