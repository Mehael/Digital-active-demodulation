unit PutGetArrayTest;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ltrapi,  ltrapitypes, ltrapidefine;

type
  TForm1 = class(TForm)
    btnGetArray: TButton;
    procedure btnGetArrayClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.btnGetArrayClick(Sender: TObject);
var
  crate : TLTR;
  err : Integer;
  data : array [0..3] of Byte;
begin
  LTR_Init(crate);
  crate.cc := CC_CONTROL;

  err := LTR_Open(crate);
  if err = LTR_OK then
  begin
    // Чтение 4 байт версии прошивки
    err := LTR_CrateGetArray(crate,  $83002FF0, data, 4);
    if err <> LTR_OK then
      MessageDlg('Ошибка выполнения GetArray: ' + LTR_GetErrorString(err), mtError, [mbOK], 0)
    else
    begin
      // Запись 5 в регистр с адресом 8600000Eh приводит к однократной генерации метки старт.
      // По факту прихода метки (можно смотреть в LtrServer/LtrManager) определяем, что запись прошла успешно
      // Размер при записи в регистры ПЛИС должен быть кратен 2 (!)
      data[0] := $5;
      err := LTR_CratePutArray(crate,  $8600000E, data, 2);
      if err <> LTR_OK then
        MessageDlg('Ошибка выполнения PutArray: ' + LTR_GetErrorString(err), mtError, [mbOK], 0)
      else
        MessageDlg('Выполнено без ошибок', mtInformation, [mbOK], 0);
    end;

    LTR_Close(crate);
  end
  else
  begin
    MessageDlg('Не удалось установить соединение с крейтом: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);
  end;


end;

end.
