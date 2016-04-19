unit ipctl;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ltrapi,  ltrapitypes, ltrapidefine, StdCtrls;

type
  TForm1 = class(TForm)
    btnGetIpList: TButton;
    lstIpAddr: TListBox;
    edtNewIpAddr: TEdit;
    btnAddIpAddr: TButton;
    chkNewIpAuto: TCheckBox;
    btnIpRem: TButton;
    btnIpConnect: TButton;
    btnIpDisconnect: TButton;
    procedure btnGetIpListClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure refreshIpList();
    procedure btnAddIpAddrClick(Sender: TObject);
    procedure btnIpRemClick(Sender: TObject);
    procedure btnIpConnectClick(Sender: TObject);
    procedure btnIpDisconnectClick(Sender: TObject);
  private
    { Private declarations }


    srv: TLTR;
    ipentry : array of TLTR_CRATE_IP_ENTRY;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function ToIP4(const A, B, C, D: Byte): Cardinal;
begin
  Result := (A shl 24) + (B shl 16) + (C shl 8) + D;
end;

function StringToIP4Addr(const AIP4Str: string; out addr : Cardinal): Boolean;
var
  S: TStrings;
  res : Boolean;
begin
  res := True;
  S := TStringList.Create;
  try
    S.Delimiter := '.';
    S.DelimitedText := AIP4Str;

    // do preeliminary check. The IP4 Address string must consists of 4 parts. Less or more than that would be invalid values
    if S.Count<>4 then
      res := False;
    if res then
      addr := ToIP4(StrToInt(S[0]), StrToInt(S[1]), StrToInt(S[2]),  StrToInt(S[3]));
  finally
    S.Free;
  end;
  StringToIP4Addr:=res;
end;


procedure TForm1.refreshIpList();
var
  err: Integer;
  i : DWORD;
  found, returned : DWORD;
  tmp_str : string;
  status_str : string;
  idx : Integer;
begin
  //запоминаем выбранный элемент до зачистки, чтобы потом восстановить
  idx := lstIpAddr.ItemIndex;
  lstIpAddr.Items.Clear;
  SetLength(ipentry, 0);
  //сперва передаем нулевой массив, чтобы получить количество записей в found
  err:=LTR_GetListOfIPCrates(srv, 0, 0, found, returned, ipentry);
  if (err = LTR_OK) and (found > 0) then
  begin
    //устанавливаем нужную длину массива и получаем уже полный список записей
    SetLength(ipentry, found);
    err:=LTR_GetListOfIPCrates(srv, 0, 0, found, returned, ipentry);
    // на случай, если кол-во адресов уменьшилось между двумя вызовами LTR_GetListOfIPCrates
    // изменяем размер массива
    SetLength(ipentry, returned);
    if err = LTR_OK then
    begin
      for  i:=0 to returned-1 do
      begin
        tmp_str := Inttostr(ipentry[i].ip_addr shr 24) +
                            '.' + Inttostr((ipentry[i].ip_addr shr 16) and $0FF) +
                            '.' + Inttostr((ipentry[i].ip_addr shr 8) and $0FF) +
                            '.' + Inttostr(ipentry[i].ip_addr  and $0FF);
        if (ipentry[i].flags and CRATE_IP_FLAG_AUTOCONNECT) <> 0 then
           tmp_str := tmp_str + ', Auto';


        if ipentry[i].status = CRATE_IP_STATUS_OFFLINE then
          status_str := 'Отключен'
        else if ipentry[i].status = CRATE_IP_STATUS_CONNECTING then
          status_str := 'Подключение...'
        else if ipentry[i].status = CRATE_IP_STATUS_ONLINE then
          status_str := 'Подключен'
        else if ipentry[i].status = CRATE_IP_STATUS_ERROR then
          status_str := 'Ошибка'
        else
          status_str := 'Неизвестный статус';

        tmp_str := tmp_str + ', Состояние: ' + status_str;

        if ipentry[i].status = CRATE_IP_STATUS_ONLINE then
           tmp_str := tmp_str + ', Крейт: ' + string(ipentry[i].serial_number);

        lstIpAddr.Items.Add(tmp_str);
      end;
    end;
  end;

  //восстанавливаем выбранный элемент по индексу
  if (idx >= 0)  and (lstIpAddr.Items.Count > 0) then
  begin
    //если элементов стало меньше, чем номер выбранного, то выбираем последний
    if idx <  lstIpAddr.Items.Count then
      lstIpAddr.ItemIndex := idx
    else
      lstIpAddr.ItemIndex := lstIpAddr.Items.Count - 1;
  end;

  if err <> LTR_OK then
    MessageDlg('Не удалось получить список адресов: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);
end;



procedure TForm1.btnGetIpListClick(Sender: TObject);
begin
  refreshIpList;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
err: Integer;
begin
  LTR_Init(srv);
  LTR_FillSerial(srv, CSN_SERVER_CONTROL);
  err:=LTR_Open(srv);
  if err <> LTR_OK then
  begin
    MessageDlg('Не удалось установить связь с сервером: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);
    ExitProcess(err);
  end
  else
  begin
    refreshIpList;
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  LTR_Close(srv);
end;

procedure TForm1.btnAddIpAddrClick(Sender: TObject);
var
  err: Integer;
  Addr : Cardinal;
  flags :  Cardinal;
begin
  if StringToIP4Addr(edtNewIpAddr.Text, addr) then
  begin
    flags:= 0;
    if chkNewIpAuto.Checked then
      flags := flags or CRATE_IP_FLAG_AUTOCONNECT;

    err := LTR_AddIPCrate(srv, addr, flags, True);
    if err <> LTR_OK then
      MessageDlg('Не удалось добавить IP-адресс: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);

    if err = LTR_OK then
      refreshIpList;
  end
  else
  begin
    MessageDlg('Ошибка разбора адреса', mtError, [mbOK], 0);
  end;
end;

procedure TForm1.btnIpRemClick(Sender: TObject);
var
  idx : Integer;
  err : Integer;
begin
  idx:= lstIpAddr.ItemIndex;
  if (idx >= 0) and (idx < Length(ipentry)) then
  begin
    err := LTR_DeleteIPCrate(srv, ipentry[idx].ip_addr, True);
    if err <> LTR_OK then
      MessageDlg('Не удалось удалить IP-адрес: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);

    if err = LTR_OK then
      refreshIpList;
  end
  else
   MessageDlg('Не выбрана запись для удаления', mtError, [mbOK], 0);

end;

procedure TForm1.btnIpConnectClick(Sender: TObject);
var
  idx : Integer;
  err : Integer;
begin
  idx:= lstIpAddr.ItemIndex;
  if (idx >= 0) and (idx < Length(ipentry)) then
  begin
    err := LTR_ConnectIPCrate(srv, ipentry[idx].ip_addr);
    if err <> LTR_OK then
      MessageDlg('Не удалось подключить крейт по IP-адресу: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);

    if err = LTR_OK then
      refreshIpList;
  end
  else
   MessageDlg('Не выбрана запись для удаления', mtError, [mbOK], 0);

end;


procedure TForm1.btnIpDisconnectClick(Sender: TObject);
var
  idx : Integer;
  err : Integer;
begin
  idx:= lstIpAddr.ItemIndex;
  if (idx >= 0) and (idx < Length(ipentry)) then
  begin
    err := LTR_DisconnectIPCrate(srv, ipentry[idx].ip_addr);
    if err <> LTR_OK then
      MessageDlg('Не удалось отключить крейт по IP-адресу: ' + LTR_GetErrorString(err), mtError, [mbOK], 0);

    if err = LTR_OK then
      refreshIpList;
  end
  else
   MessageDlg('Не выбрана запись для удаления', mtError, [mbOK], 0);

end;

end.
