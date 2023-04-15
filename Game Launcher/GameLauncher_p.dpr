program GameLauncher_p;

uses
  Vcl.Forms,
  GameLauncher_u in 'GameLauncher_u.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
