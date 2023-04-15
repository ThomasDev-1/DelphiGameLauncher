{
Made by ThomasDev:

  https://github.com/ThomasDev-1/

}

unit GameLauncher_u;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Winapi.ShellAPI, ShlObj, CommCtrl,
  System.ImageList, Vcl.ImgList, Vcl.ExtCtrls, Generics.Collections, System.IOUtils, System.Types, Vcl.FileCtrl,
  Vcl.Imaging.pngimage, System.StrUtils;

type
  HICON = type THandle;

  TForm1 = class(TForm)
    btnAddGame: TButton;
    btnRemoveGame: TButton;
    pnlRemoving: TPanel;
    txt1: TStaticText;
    btnCancel: TButton;
    btnClose: TButton;
    imglGameIcons: TImageList;
    imgBG: TImage;
    procedure btnAddGameClick(Sender: TObject);
    procedure CreateButtonWithIcon(const APath: string; name : string);
    procedure LaunchGame(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure AddGame();
    procedure btnRemoveGameClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnCloseClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  gameDir : PWideChar;
  LeftPos : integer;
  TopPos : Integer;
  currentTag : integer;
  bRemoving : Boolean;
  imageLists : TList<TImageList>;
  names : TList<string>;

implementation

{$R *.dfm}

procedure SetButtonIconFromExe(exeDir: string; btn: TButton; name: string);
var
  exeIcon: TIcon;
  imageList: TImageList;
  bmp: TBitmap;
  textWidth : integer;
begin


  exeIcon := TIcon.Create;
  try
    exeIcon.Handle := ExtractIcon(hInstance, PChar(exeDir), 0);

    bmp := TBitmap.Create;
    try
      bmp.PixelFormat := pf32bit;
      bmp.Width := btn.Width;
      bmp.Height := btn.Height;
      bmp.Canvas.Brush.Color := clWebMediumPurple;
      bmp.Canvas.FillRect(Rect(0, 0, bmp.Width, bmp.Height));
      textWidth := bmp.Canvas.TextWidth(name);
      bmp.Canvas.Font.Color := clBlack;
      bmp.Canvas.TextOut((bmp.Canvas.ClipRect.Right - bmp.Canvas.ClipRect.Left - TextWidth) div 2, 10, name);

      bmp.Canvas.StretchDraw(Rect(30 , 30 , btn.Width, btn.Height), exeIcon);

      imageList := TImageList.CreateSize(btn.Width, btn.Height);
      try
        imageList.Add(bmp, nil);

        btn.ImageIndex := 0;
        btn.Images := imageList;
        imageLists.Add(imageList);
      finally
        //imageList.Free;
      end;
    finally
      bmp.Free;
    end;
  finally
    exeIcon.Free;
  end;
end;

procedure TForm1.CreateButtonWithIcon(const APath: string; name : string);
var
  Btn: TButton;
begin
  Btn := TButton.Create(Self);
  Btn.Parent := Self;
  Btn.SetBounds(LeftPos, TopPos, 100, 100);
  Btn.Tag := currentTag;
  gameDir := PWideChar(APath);

  SetButtonIconFromExe(APath, Btn, name);
  

  Btn.OnClick := LaunchGame;

  LeftPos := LeftPos + 100;
  if LeftPos >  1000 then
  begin
    LeftPos := 10;
    TopPos := TopPos + 103;
  end;



  currentTag := currentTag + 1;
end;



procedure TForm1.AddGame();
var
  TF : TextFile;
  nameFile : TextFile;
  sGameDir : string;
  name : string;
begin
  currentTag := 0;
  LeftPos := 10;
  TopPos := 20;
  
  AssignFile(TF, 'GameDatabase.txt');
  Reset(TF);

  AssignFile(nameFile, 'GameTitles.txt');
  Reset(nameFile);

  while not Eof(TF) do
    begin
      Readln(TF, sGameDir);
      Readln(nameFile, name);

      CreateButtonWithIcon(sGameDir, name);
    end;

  CloseFile(TF);
  CloseFile(nameFile);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin

  imageLists := TList<TImageList>.Create;
  AddGame;

  ReportMemoryLeaksOnShutdown := True;
end;

procedure TForm1.LaunchGame(Sender: TObject);
var
  sGameDir : string;
  TF : TextFile;
  iLine : integer;
  i : Integer;

  slFile: TStringList;
begin

  if bRemoving = False then
  begin
      iLine := 0;

      AssignFile(TF, 'GameDatabase.txt');
      Reset(TF);
        while not Eof(TF) do
        begin
          ReadLn(TF, sGameDir);
          if iLine = (Sender as TButton).Tag then
          begin
            Break;
          end;
          iLine := iLine + 1;
        end;
      CloseFile(TF);
      ShellExecute(Handle, 'open', PChar(sGameDir), nil, nil, SW_SHOWNORMAL);

      for i := 0 to imageLists.Count - 1 do
      begin
         imageLists[i].Free;
      end;
        imageLists.Free;

      Application.MainForm.Close;
  end
  else
  begin
      slFile := TStringList.Create;
    try
       slFile.LoadFromFile('GameDatabase.txt');
       slFile.Delete((Sender as TButton).Tag);
       slFile.SaveToFile('GameDatabase.txt');

       slFile.LoadFromFile('GameTitles.txt');
       slFile.Delete((Sender as TButton).Tag);
       slFile.SaveToFile('GameTitles.txt');

    finally
      slFile.Free;
    end;
      bRemoving := False;
      pnlRemoving.Visible := False;
      (Sender as TButton).Destroy;
  end;
end;

procedure TForm1.btnAddGameClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
  TF : TextFile;
  nameFile : TextFile;
  GameName : string;
  newName : string;

begin
  OpenDialog := TOpenDialog.Create(nil);
  try
    OpenDialog.Title := 'Select executable file';
    OpenDialog.Filter := 'Executable files (*.exe)|*.exe';
    if OpenDialog.Execute then
    begin
      gameDir := PWideChar(OpenDialog.FileName);

      AssignFile(TF, 'GameDatabase.txt');
      Append(TF);

      AssignFile(nameFile, 'GameTitles.txt');
      Append(nameFile);
      Writeln(TF, string(gameDir));

      GameName := ExtractFileName(gameDir);
      GameName := ChangeFileExt(GameName, '');

      newName := InputBox('Add game', 'Change title of the game', GameName);

      Writeln(nameFile, newName);

      CloseFile(TF);
      CloseFile(nameFile);

    end;
  finally
    OpenDialog.Free;
  end;

  AddGame;
end;

procedure TForm1.btnCancelClick(Sender: TObject);
begin
   bRemoving := False;
   pnlRemoving.Visible := False;
end;

procedure TForm1.btnCloseClick(Sender: TObject);
var
i : integer;
begin

  for i := 0 to imageLists.Count - 1 do
      begin
         imageLists[i].Free;
      end;
        imageLists.Free;

      Application.MainForm.Close;
end;

procedure TForm1.btnRemoveGameClick(Sender: TObject);
begin
  bRemoving := true;
  pnlRemoving.Visible := True;
end;


end.
