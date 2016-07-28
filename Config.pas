unit Config;

interface
const
  DevicesAmount     = 1;
  DevicePeriod : array[0..1] of Integer =
  (
      390,       //????????????
      390
  );
  ChannelsPerDevice = 1;
  ChannelsAmount    = DevicesAmount*ChannelsPerDevice;

// Время, за которое будет отображаться блок (в мс)
  ADC_reading_time   = 500;
// Дополнительный  постоянный таймаут на прием данных (в мс)
  ADC_possible_delay = 1000;

  CalibrateMiliSecondsCut = 4000;
  InnerBufferPagesAmount = 4*(CalibrateMiliSecondsCut/ADC_reading_time);

  DAC_max_VOLT_signal   = 8;
  //DAC_100signal_to_VOLT = 1000; //1.8;   вроде 1 к 1
  DAC_max_signal        = DAC_max_VOLT_signal;
  DAC_min_signal        = 0;

  DAC_dataByChannel     = 10;
  DAC_possible_delay    = 2000;

  DAC_packSize          = DevicesAmount*DAC_dataByChannel;
type
  TFilePack = array[0..ChannelsAmount] of TextFile;
implementation
end.
