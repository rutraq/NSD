unit Unit2;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.Menus;

type
  TForm2 = class(TForm)
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Button2: TButton;
    OpenDialog2: TOpenDialog;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure N2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;
const
A = 5;{Êîíñòàíòû äëÿ}
c = 27;{ãåíåðàòîðà}
M = 65536;{ïñåâäîñëó÷àéíûõ ÷èñåë - ÏÑ×}
var
  Form2: TForm2;

var
TempFile                : file of byte;
InpF, OutF              : file of word; {ôàéëû íà âõîäå è âûõîäå}
password, password1     : string; {ïåðåìåííûå äëÿ ðàáîòû ñ ïàðîëÿìè}
OutputFileName, Exten   : string; {ïåðåìåííûå èìåí ôàéëîâ}
I, J, K, tmp            : byte; {ïåðåìåííûå êîäèðîâàíèÿ}
Temp, SCode, TByte, Code: word;
Position                : LongInt; {ïåðåìåííûå äàííûõ î ïðîöåññå}
NowPos                  : real;
TPassword               : array [1..255] of word;
MasByte, Mas, MasEnd, PS: array [1..64] of word; {ìàññèâû ïåðåñòàíîâîê}
T                       : array [0..64] of word;
DirInfo, DirInfo1       : TSearchRec; {äàííûå î ôàéëå}
Exten1                  : string[3];

implementation

{$R *.dfm}

uses Unit1;

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

procedure TForm2.Button1Click(Sender: TObject);{øèôðîâêà ôàéëà}
var check, check1:boolean;
begin
  if OpenDialog1.Execute then
    begin
      pass;{Ïîëó÷åíèå ïàðîëÿ}
    end;

  if OpenDialog1.FileName <> '' then
    begin
      {Ïðåîáðàçîâàòü ôàéë}
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
      {Èçìåíåíèå ðàñøèðåíèÿ}
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
        {Íà÷àëî øèôðîâàíèÿ}
        k := 1;
          repeat
            {Ñ÷èòàòü èç èñõîäíîãî ôàéëà áëîê ðàçìåðîì 64*word}
            begin
              for i := 1 to 64 do
                if EOF(InpF) then MasByte[i] := 0 else read(InpF, MasByte[i]);
              mas := MasByte;
              T[0] := ord(Password[k]);
                if k < length(password) then inc(k) else k := 1;
                for i := 1 to 64 do
                  begin
                    {Øèôðîâàòü ñ ïîìîùüþ ÏÑ×}
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
      ShowMessage('File encrypted');
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
            for i := 1 to 8 do { íà÷àëüíàÿ ïåðåñòàíîâêà }
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
  end;
end;

procedure TForm2.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Application.Terminate;
end;

procedure TForm2.N2Click(Sender: TObject);
begin
  Form2.Hide;
  Form1.Show;
end;

end.
