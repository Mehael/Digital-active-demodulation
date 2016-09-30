unit DACThread;

interface
uses Classes, Windows, Math, SysUtils, ltr34api, Dialogs, ltrapi, Config;

type TDACThread = class(TThread)
  public
    stop:boolean;
    DAC_level:array of DOUBLE;
    debugFile: TextFile;
    
    destructor Free();
    procedure CheckError(err: Integer);
    constructor Create(ltr34: pTLTR34; SuspendCreate : Boolean);
    procedure stopThread();
    procedure Execute; override;
  private
    phltr34: pTLTR34;


    DATA:array[0..DAC_packSize-1] of DOUBLE;
    WORD_DATA:array[0..DAC_packSize-1] of integer;

    procedure updateDAC();
end;
implementation

  procedure TDACThread.updateDAC();
  var
    i, ch, ulimit: Integer;
    summator, step: single;
  begin
    EnterCriticalSection(DACSection);

    for ch:=0 to phltr34.ChannelQnt-1 do begin
      DATA[ch]:= DAC_level[ch];
          
      {ulimit:=ch*DAC_dataByChannel+DAC_dataByChannel-1;
      //--new spline
      if DAC_level[ch]<>DATA[ulimit] then begin
        step:=(DAC_level[ch]-DATA[ulimit])/(DAC_dataByChannel-1);
        summator:=0;
        for i:=ch*DAC_dataByChannel to ulimit-1 do begin
          summator:=summator+step;
          DATA[i]:= summator+DATA[ulimit];
        end;
        DATA[ulimit]:= DAC_level[ch];
      //--spline to line
      end else if DAC_level[ch]<>DATA[ch*DAC_dataByChannel] then
        for i:=ch*DAC_dataByChannel to ulimit do
          DATA[i]:= DAC_level[ch];
      }
    end;

    //debug
    //writeln(debugFile, Format('%.5g', [DATA[0]]));

    CheckError(LTR34_ProcessData(phltr34,@DATA,@WORD_DATA, DAC_packSize, 1)); //1- указываем что значения в Вольтах
    //CheckError(LTR34_Send(phltr34,@WORD_DATA, DAC_packSize, DAC_possible_delay));

    LeaveCriticalSection(DACSection);
    
  end;

  procedure TDACThread.stopThread();
  begin
      stop:=true;
  end;

  procedure TDACThread.CheckError(err: Integer);
  begin
  if err < LTR_OK then
    MessageDlg('LTR34: ' + LTR34_GetErrorString(err), mtError, [mbOK], 0);
  end;

  constructor TDACThread.Create(ltr34: pTLTR34; SuspendCreate : Boolean);
  var i: integer;
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     phltr34:= ltr34;
     SetLength(DAC_level, phltr34.ChannelQnt);

     DAC_max_signal := VoltToCode(DAC_max_VOLT_signal);
     DAC_min_signal := VoltToCode(DAC_min_VOLT_signal);
  end;

  destructor TDACThread.Free();
  begin
      Inherited Free();
  end;

  procedure TDACThread.Execute;
  begin
    System.Assign(debugFile, 'D:\Dac.txt');
    ReWrite(debugFile);
    
    CheckError(LTR34_DACStart(phltr34));
    while not stop do
      updateDAC();

    CheckError(LTR34_DACStop(phltr34));
  end;
end.
