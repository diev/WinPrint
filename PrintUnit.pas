unit PrintUnit;

interface

uses
  System.Classes;

procedure LoadLines(const FileName: string; const Enc: Integer = 866);
procedure PrintLines;
function TryGetKA(const S: string; out KA: string): Boolean;

var
  Lines: TStrings;

implementation

uses
  System.SysUtils,
  System.RegularExpressions;

procedure LoadLines(const FileName: string; const Enc: Integer = 866);
begin
  Lines.LoadFromFile(FileName, TEncoding.GetEncoding(Enc));
end;

procedure PrintLines;
var
  I: Integer;
  S: string;
  Fin: Boolean;
  KA: string;
begin
  Fin := false;
  for I := 0 to Lines.Count - 1 do
  begin
    S := TrimRight(Lines[I]);
    if S.StartsWith('o000000') then
      Fin := true;
    if Fin then
    begin
      if TryGetKA(S, KA) then
        Writeln(Format('[KA %s]', [KA]));
    end
    else
      Writeln(S);
  end;
end;

function TryGetKA(const S: string; out KA: string): Boolean;
var
  res: TMatch;
begin
  res := TRegEx.Match(S, '(\d{12})');
  Result := res.Success;
  if Result then
    KA := res.Value;
end;

initialization
  Lines := TStringList.Create;

finalization
  Lines.Free;
end.

