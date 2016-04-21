unit ltrapitypes;
interface
uses SysUtils;

const
      COMMENT_LENGTH =256;
      ADC_CALIBRATION_NUMBER =256;
      DAC_CALIBRATION_NUMBER =256;
type
    {$A4}

    SERNUMtext=array[0..15]of AnsiChar;

    TLTR_CRATE_INFO=record
      CrateType:byte;
      CrateInterface:byte;
    end;


     TLTR_DESCRIPTION_MODULE=record
      CompanyName:array[0..16-1]of AnsiChar;                     //
      DeviceName:array[0..16-1]of AnsiChar;                      // �������� �������
      SerialNumber:array[0..16-1]of AnsiChar;                    // �������� ����� �������
      Revision:byte;                                       // ������� �������
      Comment:array[0..256-1]of AnsiChar;           //
    end;

    // �������� ���������� � ����������� �����������
    TLTR_DESCRIPTION_CPU=record
      Active:byte;                                         // ���� ������������� ��������� ����� ���������
      Name:array[0..15]of AnsiChar;                            // ��������
      ClockRate:double;                                    //
      FirmwareVersion:LongWord;                            //
      Comment:array[0..COMMENT_LENGTH-1]of AnsiChar;           //
    end;
    // �������� ����
    TLTR_DESCRIPTION_FPGA=record
      Active:byte;                                         // ���� ������������� ��������� ����� ���������
      Name:array[0..15]of AnsiChar;                            // ��������
      ClockRate:double;                                    //
      FirmwareVersion:LongWord;                            //
      Comment:array[0..COMMENT_LENGTH-1]of AnsiChar;           //
    end;
    // �������� ���
    TLTR_DESCRIPTION_ADC=record
      Active:byte;                                         // ���� ������������� ��������� ����� ���������
      Name:array[0..15]of AnsiChar;                            // ��������
      Calibration:array[0..ADC_CALIBRATION_NUMBER-1]of double;// ���������������� ������������
      Comment:array[0..COMMENT_LENGTH-1]of AnsiChar;           //
    end;

    TLTR_DESCRIPTION_DAC=record
      Active:byte;                                         // ���� ������������� ��������� ����� ���������
      Name:array[0..15]of AnsiChar;                            // ��������
      Calibration:array[0..ADC_CALIBRATION_NUMBER-1]of double;// ���������������� ������������
      Comment:array[0..COMMENT_LENGTH-1]of AnsiChar;           //
    end;
    // �������� h-���������
    TLTR_DESCRIPTION_MEZZANINE=record
      Active:byte;                                         // ���� ������������� ��������� ����� ���������
      Name:array[0..15]of AnsiChar;
      SerialNumber:array[0..15]of AnsiChar;                    // �������� ����� �������
      Revision:Byte;                                       // ������� �������
      Calibration:array[0..3]of double;                    // ���������������� ������������
      Comment:array[0..COMMENT_LENGTH-1]of AnsiChar;           // �����������
    end;
    // �������� ��������� ��
    TLTR_DESCRIPTION_DIGITAL_IO=record
      Active:byte;                                         // ���� ������������� ��������� ����� ���������
      Name:array[0..15]of AnsiChar;                            // �������� ???????
      InChannels:word;                                     // ����� �������
      OutChannels:word;                                    // ����� �������
      Comment:array[0..COMMENT_LENGTH-1]of AnsiChar;           // �����������
    end;
    // �������� ������������ �������
    TLTR_DESCRIPTION_INTERFACE=record
      Active:BYTE;                                         // ���� ������������� ��������� ����� ���������
      Name:array[0..15]of AnsiChar;                            // ��������
      Comment:array[0..COMMENT_LENGTH-1]of AnsiChar;           //
    end;
    // ������� ������ IP-�������
    TLTR_CRATE_IP_ENTRY=record
      ip_addr:LongWord;                                          // IP ����� (host-endian)
      flags:LongWord;                                            // ����� ������� (CRATE_IP_FLAG_...)
      serial_number:array[0..15]of AnsiChar;                  // �������� ����� (���� ����� ���������)
      is_dynamic:byte;                                        // 0 = ����� �������������, 1 = ������ �������������
      status:byte;                                            // ��������� (CRATE_IP_STATUS_...)
    end;

{$IFNDEF LTRAPI_DISABLE_COMPAT_DEFS}
    TIPCRATE_ENTRY = TLTR_CRATE_IP_ENTRY;
    TCRATE_INFO = TLTR_CRATE_INFO;
    TDESCRIPTION_MODULE = TLTR_DESCRIPTION_MODULE;
    TDESCRIPTION_CPU = TLTR_DESCRIPTION_CPU;
    TDESCRIPTION_FPGA = TLTR_DESCRIPTION_FPGA;
    TDESCRIPTION_ADC = TLTR_DESCRIPTION_ADC;
    TDESCRIPTION_DAC = TLTR_DESCRIPTION_DAC;
    TDESCRIPTION_MEZZANINE = TLTR_DESCRIPTION_MEZZANINE;
    TDESCRIPTION_DIGITAL_IO = TLTR_DESCRIPTION_DIGITAL_IO;
    TDESCRIPTION_INTERFACE = TLTR_DESCRIPTION_INTERFACE;
{$ENDIF}

    {$A+}

implementation
end.
