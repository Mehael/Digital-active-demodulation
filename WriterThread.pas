unit WriterThread;
interface
uses Windows, Classes, Math, SysUtils, ltr34api, Dialogs, ltrapi, Config;

type TWriter = class(TThread)
  private
    procedure WriteConfigInfo(path : string);

    public
    path:string;
    frequency:string;
    Files : TFilePack;
    skipAmount: integer;
    History: ^THistory;
    stop:boolean;
    debugFile:TextFile;
    Config:TConfig;

    constructor Create(ipath: string; ifrequency: string; iskipAmount: integer; SuspendCreate : Boolean; ConfigRef : TConfig);
    destructor Free();
    procedure Save();
    procedure CreateFiles();
    procedure CloseFiles();
    procedure DebugWrite(Value: Double);
end;

implementation
  constructor TWriter.Create(ipath: string; ifrequency: string; iskipAmount: integer; SuspendCreate : Boolean; ConfigRef : TConfig);
  begin
     path:=ipath;
     frequency:=ifrequency;
     skipAmount:=iskipAmount;
     Config := ConfigRef;
     
     Inherited Create(SuspendCreate);
     CreateFiles();
  end;

  procedure TWriter.DebugWrite(Value: Double);
  begin
    writeln(debugFile, FloatToStr(Value));
  end;

  procedure TWriter.WriteConfigInfo(path : string);
  var
    configFile:TextFile;
  begin
    System.Assign(configFile, path);
    ReWrite(configFile);

    writeln(configFile, path);
    writeln(configFile, '����������������� ������: ' + Config.ProcessTime);
    writeln(configFile, '');
    writeln(configFile, '[�����]');
    writeln(configFile, '����������: ' + Config.Calibration);
    writeln(configFile, '����������� ������: ' + Config.UnlimWriting);
    writeln(configFile, '���������� ������: ' + Config.ShowSignal);
    writeln(configFile, '');
    writeln(configFile, '[���]');
    writeln(configFile, '��������: ' + Config.ACPrange);
    writeln(configFile, '����� ������� ����������: ' + Config.ACPmode);
    writeln(configFile, '������� ������ ���: ' + Config.ACPfreq);
    writeln(configFile, '����������� ������: ' + Config.ACPbits);
    writeln(configFile, '');
    writeln(configFile, '[�����.]');
    writeln(configFile, '������ ������������ ���������: ' + Config.OptWide + '% ���������');
    writeln(configFile, '');
    writeln(configFile, '[������]');
    writeln(configFile, '1-� ������: ' + Config.ResetVt1 + '�����');
    writeln(configFile, '2-� ������: ' + Config.ResetVt2 + '�����');
    writeln(configFile, '');
    writeln(configFile, '[�����]');
    writeln(configFile, '������� ����� ���������: ' + Config.WorkpointSpeedLimit + '% ��������� �� ����');
    writeln(configFile, '');
    writeln(configFile, '[���������]');
    writeln(configFile, '1-� ������ � ' + Config.Mult1);
    writeln(configFile, '2-� ������ � ' + Config.Mult2);
    writeln(configFile, '');
    writeln(configFile, '[�����������.]');
    writeln(configFile, '��������� ������� �� ' + Config.BlocksForLowfreqCalculation + ' ������ ������.');
    writeln(configFile, '����� ������ 1 �����: ' + Config.TimeToWriteBlock + ' ��.');
    CloseFile(configFile);
  end;

  procedure TWriter.Save;
  var
    ch,i,skipInd, size, skips: Integer;
    sum:double;
  begin
    size:= Length(History[0])-1;
    skips:=Trunc(size/skipAmount);

    EnterCriticalSection(HistorySection);
    for ch:=0 to DevicesAmount-1 do
    begin
      for i := 0 to skips-1 do begin
        sum:=0;
        for skipInd:= 0 to skipAmount-1 do begin
           sum := sum+History[ch, i*skipAmount + skipInd];
        end;
        writeln(Files[ch], IntToStr(Floor(outputMultiplicators[ch]*(sum/skipAmount))));
      end;
    end;
    LeaveCriticalSection(HistorySection);
  end;

  destructor TWriter.Free();
  begin
      CloseFiles();
      Inherited Free();
  end;

 procedure TWriter.CreateFiles;
 var
  TimeMark, P: string;
  i,deviceN,fileIndex: integer;
 begin

  TimeSeparator := '-';
  TimeMark := DateToStr(Now) + TimeSeparator + TimeToStr(Now);
  TimeMark := StringReplace(TimeMark, '/', TimeSeparator, [rfReplaceAll]);
  TimeMark := StringReplace(TimeMark, ' ', TimeSeparator, [rfReplaceAll]);
  P:= path +'\EU2.' + frequency + '.' + TimeMark;
  System.MkDir(P);

  for deviceN := 0 to DevicesAmount-1 do  begin
    for i := 0 to ChannelsPerDevice-1 do begin
      fileIndex := i+deviceN*(ChannelsPerDevice);
      System.Assign(Files[fileIndex], P + '\Device'+
         InttoStr(deviceN) +'-Cn' + InttoStr(i) + '.txt');
      ReWrite(Files[fileIndex]);
    end;
  end;

  System.Assign(debugFile, P + '\Device0-DAC.txt');
  ReWrite(debugFile);

  WriteConfigInfo(P + '\Config.txt');
 end;

 procedure TWriter.CloseFiles;
 var i:integer;
 begin
  CloseFile(debugFile);
  for i := 0 to DevicesAmount-1 do
    CloseFile(Files[i]);
 end;


end.
