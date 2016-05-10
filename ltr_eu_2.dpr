program ltr_eu_2;

uses
  SysUtils,
  Variants,
  Forms,
  EU2_Form in 'EU2_Form.pas' {MainForm},
  DACThread in 'DACThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := '—борƒанных';
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
