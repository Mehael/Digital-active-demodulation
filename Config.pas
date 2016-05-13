unit Config;

interface
const
  DevicesAmount     = 2;
  ChannelsPerDevice = 1;
  ChannelsAmount    = DevicesAmount*ChannelsPerDevice;

// �����, �� ������� ����� ������������ ���� (� ��)
  ADC_reading_time   = 500;
// ��������������  ���������� ������� �� ����� ������ (� ��)
  ADC_possible_delay = 1000;

  CalibrateSecondsCut = 4;

  DAC_dataByChannel     = 100;
  DAC_possible_delay    = 2000;
  DAC_packSize          = DevicesAmount*DAC_dataByChannel;

implementation
end.
