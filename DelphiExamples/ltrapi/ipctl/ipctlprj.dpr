program ipctlprj;

uses
  Forms,
  ipctl in 'ipctl.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
