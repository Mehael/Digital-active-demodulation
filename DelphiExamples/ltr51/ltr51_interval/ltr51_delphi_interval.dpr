program ltr51_delphi_interval;

uses
  Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  LTR51_ProcessThread in 'LTR51_ProcessThread.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
