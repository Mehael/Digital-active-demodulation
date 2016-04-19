program ltr_eu_2;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Variants,
  LTR24_ProcessThread in 'LTR24_ProcessThread.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E:Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
