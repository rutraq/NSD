unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.Menus,
  Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    OpenDialog2: TOpenDialog;
    Memo1: TMemo;
    Image1: TImage;
    Button3: TButton;
    Memo2: TMemo;
    Button4: TButton;
    Panel1: TPanel;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    Image2: TImage;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Image1MouseEnter(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Image2MouseEnter(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
   A = 5;   {Константы для}
   C = 7;    {генератора}
   M =5536; {псевдослучайных чисел, далее - ПСЧ}

var
  Form2: TForm2;

var
   TempFile                : file of byte;
   InpF, OutF              : file of word; {файлы на входе и выходе}
   Password, Password1     : string; {переменные для работы с паролями}
   OutputFileName, Exten   : string; {переменные имен файлов}
   I, J, K, tmp            : byte; {переменные кодирования}
   Temp, SCode, TByte, Code: word;
   Position                : LongInt; {переменные данных о процессе}
   NowPos                  : real;
   TPassword               : array [1..255] of word;
   MasByte, Mas, MasEnd, PS: array [1..64] of word; {массивы перестановок}
   T                       : array [0..64] of word;
   DirInfo, DirInfo1       : TSearchRec; {данные о файле}
   Exten1                  : string[3];
   kolvo                   : integer;

implementation

{$R *.dfm}

uses Unit1;

procedure pass;
var check, check1:boolean;
begin
  kolvo := 0;
  check := False;
  check1 := False;
  password := '';
  password1 := '';
    while check1 = False do
      begin
        password := InputBox('П А Р О Л Ь', 'ВВЕДИТЕ ПАРОЛЬ:', password);
          if kolvo < 3 then
            begin
              if (password = '') then
                begin
                  kolvo := kolvo + 1;
                end;
              if password <> '' then
                begin
                  check1 := True;
                end;
            end;
          if kolvo = 3 then
            begin
              Form2.Hide;
              Form1.Show;
              ShowMessage('Ошибка ввода пароля');
              check := True;
              break;
            end;
      end;
    while check = False do
      begin
        if kolvo < 3 then
          begin
            password1 := '';
            password1 := InputBox('П А Р О Л Ь', 'ВВЕДИТЕ ПАРОЛЬ ЕЩЁ РАЗ:', password1);
            if (password1 = '') or (password1 <> password) then
              begin
                kolvo := kolvo + 1;
              end;
            if (password = password1) and (length(password) <> 0) then
              begin
                check := True;
              end;
                {else
                  begin
                    password1 := '';
                    password1 := InputBox('П А Р О Л Ь', 'ПАРОЛИ НЕ СОВПАДАЮТ, ВВЕДИТЕ ЕЩЁ РАЗ:', password1);
                  end;  }
          end;
        if kolvo = 3 then
          begin
            Form2.Hide;
            Form1.Show;
            ShowMessage('Ошибка ввода пароля');
            break;
          end;
      end;
end;

function GetHardDiskSerial(const DriveLetter: PChar): string;
var
  NotUsed:     DWORD;
  VolumeFlags: DWORD;
  VolumeInfo:  array[0..MAX_PATH] of Char;
  VolumeSerialNumber: DWORD;
begin
  GetVolumeInformation(PChar(DriveLetter),
    nil, SizeOf(VolumeInfo), @VolumeSerialNumber, NotUsed,
    VolumeFlags, nil, 0);
  Result := Format('%8.8X', [VolumeSerialNumber])
end;

procedure TForm2.Button1Click(Sender: TObject);{шифрование файла}
var check, check1:boolean;
begin
  if OpenDialog1.Execute then
    begin
      pass;{Получение пароля}
    end;

  if (OpenDialog1.FileName <> '') and (kolvo <> 3) then
    begin
      {Преобразовать файл}
      FindFirst(OpenDialog1.FileName, faAnyFile, DirInfo);
        if DirInfo.Size mod 2 = 1 then
          begin
            AssignFile(TempFile, OpenDialog1.FileName);
            reset(TempFile);
              while not EOF(TempFile) do read(TempFile, tmp);
            tmp := 255;
            write(TempFile, tmp);
            CloseFile(TempFile);
           end;
      {Преобразование расширения файла}
      assignFile(InpF, OpenDialog1.FileName);
      reset(InpF);
        for i := length(OpenDialog1.FileName) downto 1 do
          if OpenDialog1.FileName[i] = '.' then
            begin
              OutputFileName := copy(OpenDialog1.FileName, 1, i) + 'A&Y';
              break;
            end;
      assignFile(OutF, OutputFileName);
      rewrite(OutF);
        for i:= 0 to length(OpenDialog1.FileName) do
          if OpenDialog1.FileName[length(OpenDialog1.FileName) - i] = '.' then
            case i of
              0: Exten := chr(0) + chr(0) + chr(0);
              1: Exten := copy(OpenDialog1.FileName, length(OpenDialog1.FileName)-2, i) + chr(0) + chr(0);
              2: Exten := copy(OpenDialog1.FileName, length(OpenDialog1.FileName)-2, i) + chr(0)
                else Exten := copy(OpenDialog1.FileName, length(OpenDialog1.FileName)-2, 3)
            end;
      for i := 1 to 3 do
        begin
          Temp := ord(Exten[i]);
          Write(OutF, Temp);
        end;
        {Начать шифрование}
        k := 1;
          repeat
            {Считать из исходного файла блок размером 64*word}
            begin
              for i := 1 to 64 do
                if EOF(InpF) then MasByte[i] := 0 else read(InpF, MasByte[i]);
              mas := MasByte;
              T[0] := ord(Password[k]);
                if k < length(password) then inc(k) else k := 1;
                for i := 1 to 64 do
                  begin
                    {Шифровать с помощью ПСЧ}
                    code := mas[i];
                    T[i] := (A * T[i-1] + C) mod M;
                    Code:=T[i] xor Code;
                    Mas[i] := Code;
                  end;
                for i := 1 to 8 do
                  for j := 1 to 8 do
                    case i of
                      1: MasEnd[8*(j-1)+i] := Mas[41-j];
                      2: MasEnd[8*(j-1)+i] := Mas[09-j];
                      3: MasEnd[8*(j-1)+i] := Mas[49-j];
                      4: MasEnd[8*(j-1)+i] := Mas[17-j];
                      5: MasEnd[8*(j-1)+i] := Mas[57-j];
                      6: MasEnd[8*(j-1)+i] := Mas[25-j];
                      7: MasEnd[8*(j-1)+i] := Mas[65-j];
                      8: MasEnd[8*(j-1)+i] := Mas[33-j]
                    end;
                for i := 1 to 64 do write(OutF, MasEnd[i]);
            end;
          until EOF(InpF);
      closeFile(InpF);
      Erase(InpF);
      CloseFile(OutF);
      MessageDlg('Файл зашифрован', mtInformation, [mbOk], 0);
    end;
end;

procedure TForm2.Button2Click(Sender: TObject);
begin
  if OpenDialog2.Execute then
    begin
      pass;
    end;

    if OpenDialog2.FileName <> '' then
  begin
    FindFirst(OpenDialog2.FileName, faAnyFile, DirInfo);
      AssignFile(InpF, OpenDialog2.FileName);
      reset(InpF);
      Exten1 := '';
        for i := 1 to 3 do
          begin
            Read(InpF, Temp);
            Exten1 := Exten1 + chr(Temp);
          end;
        for i := length(OpenDialog2.FileName) downto 1 do
          if OpenDialog2.FileName[i] = '.' then
            begin
              OutputFileName := copy(OpenDialog2.FileName, 1, i) + Exten1;
              break;
            end;
      AssignFile(OutF, OutputFileName);
      rewrite(OutF);
        for i := 1 to length(Password) do TPassword[i] := ord(Password[i]);
      k := 1;
        repeat
          begin
            for i := 1 to 64  do read(InpF, MasByte[i]);
            for i := 1 to 8 do {Конечная перестановка}
              for j := 1 to 8 do
                case i of
                  1: Mas[8*(i-1)+j]:=MasByte[66-8*j];
                  2: Mas[8*(i-1)+j]:=MasByte[68-8*j];
                  3: Mas[8*(i-1)+j]:=MasByte[70-8*j];
                  4: Mas[8*(i-1)+j]:=MasByte[72-8*j];
                  5: Mas[8*(i-1)+j]:=MasByte[65-8*j];
                  6: Mas[8*(i-1)+j]:=MasByte[67-8*j];
                  7: Mas[8*(i-1)+j]:=MasByte[69-8*j];
                  8: Mas[8*(i-1)+j]:=MasByte[71-8*j]
                end;
            T[0] := ord(password[k]);
              if k < length(password) then inc(k) else k := 1;
              for i := 1 to 64 do
                begin
                  T[i] := (A * T[i-1] + C) mod M;
                  Code:=Mas[i];
                  Code:=T[i] xor Code;
                  Mas[i] := Code;
                end;
            MasEnd := Mas;
            for i := 1 to 64 do Write(OutF, MasEnd[i]);
          end;
        until EOF(InpF);
      CloseFile(InpF);
      Erase(InpF);
      CloseFile(OutF);
      MessageDlg('Файл расшифрован', mtInformation, [mbOk], 0);
  end;
end;

procedure TForm2.Button3Click(Sender: TObject);
var
  Drive: Char; //Буква диска
const
  pref = ':\';
begin
  Combobox1.Items.Clear;
  Image1.Visible := False;
    for Drive := 'B' to 'Z' do
      begin
        if GetDriveType(PChar(Drive + pref)) = DRIVE_REMOVABLE then Combobox1.Items.Add(Drive + pref);
      end;
  Panel1.Visible := True;
  ComboBox1.Visible := True;
  ComboBox1.Text := 'Выберите USB для шифровки';
end;

procedure TForm2.Button4Click(Sender: TObject);
var
  Drive: Char; //Буква диска
const
  pref = ':\';
begin
  Combobox2.Items.Clear;
  Image1.Visible := False;
    for Drive := 'B' to 'Z' do
      begin
        if GetDriveType(PChar(Drive + pref)) = DRIVE_REMOVABLE then Combobox2.Items.Add(Drive + pref);
      end;
  Panel1.Visible := True;
  ComboBox2.Visible := True;
  ComboBox1.Text := 'Выберите USB для расшифровки';
end;

procedure TForm2.ComboBox1Change(Sender: TObject);
begin
  if OpenDialog1.Execute then
    begin
      password := GetHardDiskSerial(PChar(ComboBox1.Text));
    end;

  if (OpenDialog1.FileName <> '') and (kolvo <> 3) then
    begin
      {Преобразовать файл}
      FindFirst(OpenDialog1.FileName, faAnyFile, DirInfo);
        if DirInfo.Size mod 2 = 1 then
          begin
            AssignFile(TempFile, OpenDialog1.FileName);
            reset(TempFile);
              while not EOF(TempFile) do read(TempFile, tmp);
            tmp := 255;
            write(TempFile, tmp);
            CloseFile(TempFile);
           end;
      {Преобразование расширения файла}
      assignFile(InpF, OpenDialog1.FileName);
      reset(InpF);
        for i := length(OpenDialog1.FileName) downto 1 do
          if OpenDialog1.FileName[i] = '.' then
            begin
              OutputFileName := copy(OpenDialog1.FileName, 1, i) + 'A&Y';
              break;
            end;
      assignFile(OutF, OutputFileName);
      rewrite(OutF);
        for i:= 0 to length(OpenDialog1.FileName) do
          if OpenDialog1.FileName[length(OpenDialog1.FileName) - i] = '.' then
            case i of
              0: Exten := chr(0) + chr(0) + chr(0);
              1: Exten := copy(OpenDialog1.FileName, length(OpenDialog1.FileName)-2, i) + chr(0) + chr(0);
              2: Exten := copy(OpenDialog1.FileName, length(OpenDialog1.FileName)-2, i) + chr(0)
                else Exten := copy(OpenDialog1.FileName, length(OpenDialog1.FileName)-2, 3)
            end;
      for i := 1 to 3 do
        begin
          Temp := ord(Exten[i]);
          Write(OutF, Temp);
        end;
        {Начать шифрование}
        k := 1;
          repeat
            {Считать из исходного файла блок размером 64*word}
            begin
              for i := 1 to 64 do
                if EOF(InpF) then MasByte[i] := 0 else read(InpF, MasByte[i]);
              mas := MasByte;
              T[0] := ord(Password[k]);
                if k < length(password) then inc(k) else k := 1;
                for i := 1 to 64 do
                  begin
                    {Шифровать с помощью ПСЧ}
                    code := mas[i];
                    T[i] := (A * T[i-1] + C) mod M;
                    Code:=T[i] xor Code;
                    Mas[i] := Code;
                  end;
                for i := 1 to 8 do
                  for j := 1 to 8 do
                    case i of
                      1: MasEnd[8*(j-1)+i] := Mas[41-j];
                      2: MasEnd[8*(j-1)+i] := Mas[09-j];
                      3: MasEnd[8*(j-1)+i] := Mas[49-j];
                      4: MasEnd[8*(j-1)+i] := Mas[17-j];
                      5: MasEnd[8*(j-1)+i] := Mas[57-j];
                      6: MasEnd[8*(j-1)+i] := Mas[25-j];
                      7: MasEnd[8*(j-1)+i] := Mas[65-j];
                      8: MasEnd[8*(j-1)+i] := Mas[33-j]
                    end;
                for i := 1 to 64 do write(OutF, MasEnd[i]);
            end;
          until EOF(InpF);
      closeFile(InpF);
      Erase(InpF);
      CloseFile(OutF);
      MessageDlg('Файл зашифрован', mtInformation, [mbOk], 0);
    end;
  Panel1.Visible := False;
  ComboBox1.Visible := False;
  ComboBox1.Items.Clear;
end;

procedure TForm2.ComboBox2Change(Sender: TObject);
begin
if OpenDialog2.Execute then
  begin
    password := GetHardDiskSerial(PChar(ComboBox2.Text));
  end;

if OpenDialog2.FileName <> '' then
  begin
    FindFirst(OpenDialog2.FileName, faAnyFile, DirInfo);
      AssignFile(InpF, OpenDialog2.FileName);
      reset(InpF);
      Exten1 := '';
        for i := 1 to 3 do
          begin
            Read(InpF, Temp);
            Exten1 := Exten1 + chr(Temp);
          end;
        for i := length(OpenDialog2.FileName) downto 1 do
          if OpenDialog2.FileName[i] = '.' then
            begin
              OutputFileName := copy(OpenDialog2.FileName, 1, i) + Exten1;
              break;
            end;
      AssignFile(OutF, OutputFileName);
      rewrite(OutF);
        for i := 1 to length(Password) do TPassword[i] := ord(Password[i]);
      k := 1;
        repeat
          begin
            for i := 1 to 64  do read(InpF, MasByte[i]);
            for i := 1 to 8 do {Конечная перестановка}
              for j := 1 to 8 do
                case i of
                  1: Mas[8*(i-1)+j]:=MasByte[66-8*j];
                  2: Mas[8*(i-1)+j]:=MasByte[68-8*j];
                  3: Mas[8*(i-1)+j]:=MasByte[70-8*j];
                  4: Mas[8*(i-1)+j]:=MasByte[72-8*j];
                  5: Mas[8*(i-1)+j]:=MasByte[65-8*j];
                  6: Mas[8*(i-1)+j]:=MasByte[67-8*j];
                  7: Mas[8*(i-1)+j]:=MasByte[69-8*j];
                  8: Mas[8*(i-1)+j]:=MasByte[71-8*j]
                end;
            T[0] := ord(password[k]);
              if k < length(password) then inc(k) else k := 1;
              for i := 1 to 64 do
                begin
                  T[i] := (A * T[i-1] + C) mod M;
                  Code:=Mas[i];
                  Code:=T[i] xor Code;
                  Mas[i] := Code;
                end;
            MasEnd := Mas;
            for i := 1 to 64 do Write(OutF, MasEnd[i]);
          end;
        until EOF(InpF);
      CloseFile(InpF);
      Erase(InpF);
      CloseFile(OutF);
      MessageDlg('Файл зашифрован', mtInformation, [mbOk], 0);
  end;
  Panel1.Visible := False;
  ComboBox2.Visible := False;
  ComboBox2.Items.Clear;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.Lines.Add('При зашифровке файла, ваш файл изменит расширение на .A&Y, а при расшифроке он изменит своё расширение на исходное, так что менять расширение вручную нельзя.');
  Memo1.Lines.Add(' Если вы расшифровали файл с неверным паролем, то его нужно зашифровать обратно с тем же паролем и расшифровать с верным');
end;

procedure TForm2.Image1Click(Sender: TObject);
begin
  Form2.Hide;
  Form1.Show;
end;

procedure TForm2.Image1MouseEnter(Sender: TObject);
begin
  Form2.Image1.Cursor := CrHandPoint;
end;

procedure TForm2.Image2Click(Sender: TObject);
begin
  Panel1.Visible := False;
  Image1.Visible := True;
end;

procedure TForm2.Image2MouseEnter(Sender: TObject);
begin
  Form2.Image2.Cursor := CrHandPoint;
end;

end.
