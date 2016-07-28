unit DACThread;

interface
uses Classes,  Math, SysUtils, ltr34api, Dialogs, ltrapi, Config;

type TDACThread = class(TThread)
  public
    stop:boolean;
    DAC_level:array of DOUBLE;
    
    destructor Free();
    procedure CheckError(err: Integer);
    constructor Create(ltr34: pTLTR34; SuspendCreate : Boolean);
    procedure send(channel:integer; value:DOUBLE);
    procedure stopThread();
    procedure Execute; override;
    procedure TestExecute;
    procedure unsafeAdd(channel:integer; value:DOUBLE);

  private
    phltr34: pTLTR34;
    debugFile: TextFile;

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

    for ch:=0 to phltr34.ChannelQnt-1 do begin
      ulimit:=ch*DAC_dataByChannel+DAC_dataByChannel-1;
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

      //for i:=ch*DAC_dataByChannel to ulimit do  begin
      //    writeln(debugFile, Format('%.5g', [DATA[i]]));
      //end;
    end;

    CheckError(LTR34_ProcessData(phltr34,@DATA,@WORD_DATA, DAC_packSize, 1)); //1- указываем что значения в Вольтах
    CheckError(LTR34_Send(phltr34,@WORD_DATA, DAC_packSize, DAC_possible_delay));
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

  procedure TDACThread.send(channel:integer; value:DOUBLE);
  begin
      DAC_level[channel]:=value;
  end;

  procedure TDACThread.unsafeAdd(channel:integer; value:DOUBLE);
  begin
      DAC_level[channel]:= DAC_level[channel]+value;
  end;

  constructor TDACThread.Create(ltr34: pTLTR34; SuspendCreate : Boolean);
  var i: integer;
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
     phltr34:= ltr34;
     SetLength(DAC_level, phltr34.ChannelQnt);

    // for i := 0 to ChannelsPerDevice-1 do begin
    //  System.Assign(debugFile, 'D:\debug.txt');
     // ReWrite(debugFile);
    //end;
  end;

  destructor TDACThread.Free();
  begin
      Inherited Free();
  end;

  procedure TDACThread.TestExecute;
  var s,step:double;
  begin
    s:=0;
    step:= Floor(8/InnerBufferPagesAmount);
    while not stop do begin

      if s+step>8 then
        step:=step*(-1);
      if s+step<0 then
        step:=step*(-1);
       s:=s+step;

      DAC_level[0]:=s;

      updateDAC();
    end;
    LTR34_DACStop(phltr34);
  end;

  procedure TDACThread.Execute;
  begin
    while not stop do
      updateDAC();

    LTR34_DACStop(phltr34);
  end;
end.
