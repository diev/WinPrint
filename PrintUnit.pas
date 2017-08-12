unit PrintUnit;

interface

uses
  System.Classes;

procedure LoadLines(const FileName: string; const Enc: Integer = 866);
procedure PrintLines;

var
  Lines: TStrings;

implementation

uses
  System.SysUtils;

procedure LoadLines(const FileName: string; const Enc: Integer = 866);
begin
  Lines := TStringList.Create();
  Lines.LoadFromFile(FileName, TEncoding.GetEncoding(Enc));
end;

procedure PrintLines;
var
  I: Integer;
begin
  for I := 0 to Lines.Count - 1 do
  begin
    Writeln(Lines[I]);
  end;
end;

end.

