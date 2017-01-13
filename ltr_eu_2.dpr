program ltr_eu_2;

uses
  SysUtils,
  Variants,
  Forms,
  EU2_Form in 'EU2_Form.pas' {MainForm},
  Config in 'Config.pas',
  WriterThread in 'WriterThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '—борƒанных';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
