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


    DATA:array[0..DAC_packSize-1] of Double;
    WORD_DATA:array[0..DAC_packSize-1] of Double;

    procedure updateDAC();
end;
implementation

  procedure TDACThread.updateDAC();
  var
    i, ch, ulimit: Integer;
    ch_code: Double;
    summator, step: single;
  begin

    if DATA[0]=DAC_level[0] then exit;
    //Log(FloatToStr(DAC_level[0]));

    EnterCriticalSection(DACSection);
    for ch:=0 to phltr34.ChannelQnt-1 do begin
      DATA[ch]:= DAC_level[ch];
    end;
    LeaveCriticalSection(DACSection);

    CheckError(LTR34_ProcessData(phltr34,@DATA,@WORD_DATA, phltr34.ChannelQnt, 0)); //1- указываем что значения в Вольтах
    CheckError(LTR34_Send(phltr34,@WORD_DATA, phltr34.ChannelQnt, DAC_possible_delay));


    writeln(debugFile, FloatToStr((DAC_level[0])));

  end;

  procedure TDACThread.stopThread();
   var ch: Integer;
  begin
      for ch:=0 to phltr34.ChannelQnt-1 do begin
          DAC_level[ch]:= 0;
      end;
      updateDAC();
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

     EnterCriticalSection(DACSection);
     for i := 0 to ChannelsAmount - 1 do begin
       DAC_level[i]:= DAC_min_signal;
     end;
     LeaveCriticalSection(DACSection);
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

    LTR34_Reset(phltr34);
    CheckError(LTR34_DACStop(phltr34));
  end;
end.
