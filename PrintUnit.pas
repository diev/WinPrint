unit PrintUnit;

interface

uses
  System.Classes;

procedure LoadLines(const FileName: string; const Enc: Integer = 866);
procedure PrintLines;
function TryGetKA(const S: string; out KA: string): Boolean;

implementation

uses
  System.SysUtils,
  System.RegularExpressions;

const
  FontSize: Integer = 10;
  TopMargin: Integer = 4;
  LeftMargin: Integer = 8;

var
  Lines: TStrings;
  TotalWidth: Integer = 80;

procedure LoadLines(const FileName: string; const Enc: Integer = 866);
begin
  Lines := TStringList.Create;
  Lines.LoadFromFile(FileName, TEncoding.GetEncoding(Enc));
end;

procedure PrintLine(const S: string);
var
  I, LineWidth: Integer;
begin
  for I := 1 to LeftMargin do
    Write(' ');
  LineWidth := TotalWidth - LeftMargin;
  if S.Length > LineWidth then
  begin
    //I := S.LastIndexOfAny([' ', ',', ';', ':', '-'], 0, LineWidth);
    I := S.Substring(0, LineWidth).LastDelimiter(' ');
    if I > -1 then
    begin
      Writeln(S.Substring(0, I).TrimRight);
      PrintLine(S.Substring(I).TrimLeft);
    end
    else
    begin
      Writeln(S.Substring(0, LineWidth));
      PrintLine(S.Substring(LineWidth).TrimLeft);
    end;
  end
  else
    Writeln(S);
end;

procedure PrintLines;
var
  I: Integer;
  S, KA: string;
  Sign: Boolean;
begin
  Sign := false;
  for I := 0 to Lines.Count - 1 do
  begin
    S := TrimRight(Lines[I]);
    if S.StartsWith('o000000') then
      Sign := true;
    if Sign then
    begin
      if TryGetKA(S, KA) then
        PrintLine(Format('[KA %s]', [KA]));
    end
    else
      PrintLine(S);
  end;
end;

function TryGetKA(const S: string; out KA: string): Boolean;
var
  Res: TMatch;
begin
  Res := TRegEx.Match(S, '(\d{12})');
  Result := res.Success;
  if Result then
    KA := Res.Value;
end;

initialization
  //Lines := TStringList.Create;

finalization
  Lines.Free;
end.

