unit Unit4;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm4 = class(TForm)
    Button1: TButton;
    ComboBox1: TComboBox;
    Memo1: TMemo;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form4: TForm4;
  k:integer;

implementation

{$R *.dfm}

uses Unit1;
function FileSetHidden(const FileName: string; hid: Boolean): Boolean;
var Flags: Integer;
begin
  Result := False;
  Flags := GetFileAttributes(PChar(FileName));
  if hid then
  Flags := Flags or faHidden
  else
  Flags := Flags and not faHidden;

  Result := SetFileAttributes(PChar(FileName), Flags);
end;

procedure TForm4.Button1Click(Sender: TObject);
var
  Drive: Char; //����� �����
const
  pref = ':\';
begin
  Combobox1.Items.Clear;
    for Drive := 'B' to 'Z' do
      begin
        if GetDriveType(PChar(Drive + pref)) = DRIVE_REMOVABLE then Combobox1.Items.Add(Drive + pref);
      end;
  ComboBox1.Visible := True;
  k := 0;
end;

procedure TForm4.Button2Click(Sender: TObject);
var
  Drive: Char; //����� �����
const
  pref = ':\';
begin
  Combobox1.Items.Clear;
    for Drive := 'B' to 'Z' do
      begin
        if GetDriveType(PChar(Drive + pref)) = DRIVE_REMOVABLE then Combobox1.Items.Add(Drive + pref);
      end;
  ComboBox1.Visible := True;
  k := 1;
end;

procedure TForm4.ComboBox1Change(Sender: TObject);
var r:integer;
key1, key2:string;
begin
  if k = 0 then
    begin
      Memo1.Clear;
      r := random(1000000);
      Memo1.Lines.Add(IntToStr(r));
        if FileExists(ComboBox1.Text + 'key.txt') then
          begin
            DeleteFile(ComboBox1.Text + 'key.txt');
            Memo1.Lines.SaveToFile(ComboBox1.Text + 'key.txt');
          end
            else Memo1.Lines.SaveToFile(ComboBox1.Text + 'key.txt');
      CreateDir('C:\Log Files');
      Memo1.Lines.SaveToFile('C:\Log Files\KeyFile.txt');
      FileSetHidden('C:\Log Files\KeyFile.txt', true);
      FileSetHidden(ComboBox1.Text + 'key.txt', true);
      ShowMessage('�������� USB-�������� ������');
      Form4.Hide;
      Form1.Show;
    end
      else
        begin
          Memo1.Clear;
          Memo1.Lines.LoadFromFile('C:\Log Files\KeyFile.txt');
          key1 := Memo1.Lines.Text;
          Memo1.Clear;
            if FileExists(ComboBox1.Text + 'key.txt') then
              begin
                Memo1.Lines.LoadFromFile(ComboBox1.Text + 'key.txt');
                key2 := Memo1.Lines.Text;
              end
                else
                  begin
                    MessageDlg('�� �������� �������� USB', mtWarning, [mbOk], 0);
                    Form4.Close;
                  end;
          if key1 = key2 then
            begin
              Form4.Hide;
              Form1.Show;
            end
              else
                begin
                  MessageDlg('�� �������� �������� USB', mtWarning, [mbOk], 0);
                  Form4.Close;
                end;
        end;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin
  if FileExists('C:\Log Files\KeyFile.txt') then
    begin
      Button1.Visible := False;
    end
      else Button2.Visible := False;
end;

end.
