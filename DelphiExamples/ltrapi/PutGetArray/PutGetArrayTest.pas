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
    // ������ 4 ���� ������ ��������
    err := LTR_CrateGetArray(crate,  $83002FF0, data, 4);
    if err <> LTR_OK then
      MessageDlg('������ ���������� GetArray: ' + LTR_GetErrorString(err), mtError, [mbOK], 0)
    else
    begin
      // ������ 5 � ������� � ������� 8600000Eh �������� � ����������� ��������� ����� �����.
      // �� ����� ������� ����� (����� �������� � LtrServer/LtrManager) ����������, ��� ������ ������ �������
      // ������ ��� ������ � �������� ���� ������ ���� ������ 2 (!)
      data[0] := $5;
      err := LTR_CratePutArray(crate,  $8600000E, data, 2);
      if err <> LTR_OK then
        MessageDlg('������ ���������� PutArray: ' + LTR_GetErrorString(err), mtError, [mbOK], 0)
      else
        MessageDlg('��������� ��� ������', mtInformation, [mbOK], 0);
    end;

    LTR_Close(crate);
  end
  else
  begin
    MessageDlg('�� ������� ���������� ���������� � �������: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);
  end;


end;

end.
