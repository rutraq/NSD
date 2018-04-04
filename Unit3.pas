﻿unit Unit3;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm3 = class(TForm)
    Memo1: TMemo;
    Memo2: TMemo;
    Button1: TButton;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
A = 5;
C = 27;
M = 65536;
var
  Form3: TForm3;

var
   TempFile                : file of byte;
   InpF, OutF              : file of word; {файлы на входе и выходе}
   Password, Password1     : string; {переменные для работы с паролями}
   OutputFileName, Exten, InputFileName   : string; {переменные имен файлов}
   I, J, K, tmp            : byte; {переменные кодирования}
   Temp, SCode, TByte, Code: word;
   Position                : LongInt; {переменные данных о процессе}
   NowPos                  : real;
   TPassword               : array [1..255] of word;
   MasByte, Mas, MasEnd, PS: array [1..64] of word; {массивы перестановок}
   T                       : array [0..64] of word;
   DirInfo, DirInfo1       : TSearchRec; {данные о файле}
   Exten1                  : string[3];

implementation

{$R *.dfm}

procedure pass;
var check, check1:boolean;
begin
  check := False;
  check1 := False;
  password := '';
  password1 := '';
    while check1 = False do
      begin
        password := InputBox('P A S S W O R D', 'ENTER PASSWORD:', password);
          if password <> '' then
            begin
              check1 := True;
            end;
      end;
  password1 := InputBox('P A S S W O R D', 'ENTER PASSWORD ONE MORE TIME:', password1);
    while check = False do
      begin
        if (password = password1) and (length(password) <> 0) then
          begin
            check := True;
          end
            else
              begin
                password1 := '';
                password1 := InputBox('P A S S W O R D', 'PASSWORD IS INCORRECT, ENTER AGAIN:', password1);
              end;
      end;
end;

procedure TForm3.Button1Click(Sender: TObject);
begin
  Memo1.Lines.SaveToFile('1.txt');
  InputFileName := '1.txt';
  pass;
  FindFirst(InputFileName, faAnyFile, DirInfo);
    if DirInfo.Size mod 2 = 1 then
      begin
        AssignFile(TempFile, InputFileName);
        reset(TempFile);
          while not EOF(TempFile) do read(TempFile, tmp);
        tmp := 255;
        write(TempFile, tmp);
        closeFile(TempFile);
      end;
  assignFile(InpF, InputFileName);
  reset(InpF);
  for i := length(InputFileName) downto 1 do
          if InputFileName[i] = '.' then
            begin
              OutputFileName := copy(InputFileName, 1, i) + 'A&Y';
              break;
            end;
  assignFile(OutF, OutputFileName);
  rewrite(OutF);
  for i:= 0 to length(InputFileName) do
          if InputFileName[length(InputFileName) - i] = '.' then
            case i of
              0: Exten := chr(0) + chr(0) + chr(0);
              1: Exten := copy(InputFileName, length(InputFileName)-2, i) + chr(0) + chr(0);
              2: Exten := copy(InputFileName, length(InputFileName)-2, i) + chr(0)
                else Exten := copy(InputFileName, length(InputFileName)-2, 3)
            end;
      for i := 1 to 3 do
        begin
          Temp := ord(Exten[i]);
          Write(OutF, Temp);
        end;
  k := 1;
    repeat
      begin
        for i := 1 to 64 do
          if EOF(InpF) then MasByte[i] := 0 else read(InpF, MasByte[i]);
        mas := MasByte;
        T[0] := ord(Password[k]);
          if k < length(password) then inc(k) else k := 1;
          for i := 1 to 64 do
            begin
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
  InputFileName := '1.A&Y';
  for i := length(InputFileName) downto 1 do
    if InputFileName = '.' then
      begin
        InputFileName := copy(InputFileName, 1, i) + 'txt';
        break;
      end;
  AssignFile(Inpf, InputFileName);
  rewrite(InpF);
  CloseFile(InpF);
end;

procedure TForm3.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo2.Clear;
end;

end.
