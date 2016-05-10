unit DACThread;

interface
uses Classes, ltr34api, Dialogs, ltrapi;

type TDACThread = class(TThread)
  public
    phltr34: pTLTR34;
    stop:boolean;

    destructor Free();
    constructor Create(SuspendCreate : Boolean);
    procedure sendDAC(signal: Integer);
    procedure Execute; override;
end;
implementation

  procedure TDACThread.sendDAC(signal: Integer);
  var
    i, dataSize, timeForSending, err : Integer;
    DATA:array[0..100-1]of DOUBLE;
    WORD_DATA:array[0..100-1]of integer;
  begin
    dataSize := 100;
    timeForSending := 2000;

    for i:=0 to dataSize-1 do
       //DATA[i]:= 5;
       DATA[i]:=10*sin(i*(pi/600));
    
    err:=LTR34_ProcessData(@phltr34,@DATA,@WORD_DATA, dataSize, 1);//true- указываем что значения в Вольтах
    err:=LTR34_Send(phltr34,@WORD_DATA, dataSize, timeForSending);

    if err>dataSize then
      err:=0;
  end;

  constructor TDACThread.Create(SuspendCreate : Boolean);
  begin
     Inherited Create(SuspendCreate);
     stop:=False;
  end;

  destructor TDACThread.Free();
  begin
      Inherited Free();
  end;

  procedure TDACThread.Execute;
  var
    stoperr,i,test : Integer;
  begin
      while not stop do begin
        sendDAC(4);

      end;
      LTR34_DACStop(phltr34);
  end;
end.
