unit PrintUnit;

interface

uses
  System.Classes;

procedure LoadLines(const S: string; const Enc: Integer = 866);
procedure PrintLines;

implementation

uses
  System.SysUtils,
  System.RegularExpressions,
  Vcl.Printers;

const
  FontSize: Integer = 10;

  TopMargin: Integer = 3;
  BottomMargin: Integer = 4;

  LeftMargin: Integer = 8;
  RightMargin: Integer = 3;

var
  FileName: string;
  Lines: TStrings;
  LineHeight, CharWidth, LinesHeight, MaxChars: Integer;
  TopY, LineY, LeftX: Integer;

procedure SetCanvas;
begin
  with Printer do
  begin
    // Orientation := poLandscape;
    Orientation := poPortrait;
    Title := Format('WinPrint - %s', [FileName]);
    BeginDoc;

    // canvas settings
    Canvas.Font.Name := 'Courier New';
    Canvas.Font.Charset := 204; //RUSSIAN_CHARSET;
    Canvas.Font.Size := FontSize;

    // calculations
    LineHeight := Canvas.TextHeight('W');
    CharWidth := Canvas.TextWidth('W');

    LinesHeight := PageHeight - BottomMargin * LineHeight;
    MaxChars := Trunc(PageWidth / CharWidth) - LeftMargin - RightMargin;

    TopY := TopMargin * LineHeight;
    LeftX := LeftMargin * CharWidth;

    // move to the first line
    LineY := TopY;
  end;
end;

procedure PrintLine(const S: string);
var
  I: Integer;
begin
  // check if a new page required
  with Printer do
  begin
    // LineY := Canvas.PenPos.Y;
    if LineY > LinesHeight then
    begin
      NewPage;
      LineY := TopY;
    end;

    if S.Length > MaxChars then
    begin
      // I := S.LastIndexOfAny([' ', ',', ';', ':', '-'], 0, MaxChars);
      I := S.Substring(0, MaxChars).LastDelimiter(' ');
      if I = -1 then
        I := MaxChars;
      Canvas.TextOut(LeftX, LineY, S.Substring(0, I).TrimRight);
      // move to next line
      Inc(LineY, LineHeight);
      // print the remainder recursively
      PrintLine(S.Substring(I).TrimLeft);
    end
    else
    begin
      Canvas.TextOut(LeftX, LineY, S);
      // move to next line
      Inc(LineY, LineHeight);
    end;
  end;
end;

procedure PrintLines;
var
  I: Integer;
  S, KA: string;
  Sign: Boolean;

function TryGetKA(const S: string; out KA: string): Boolean;
var
  Res: TMatch;
begin
  Res := TRegEx.Match(S, '(\d{12})');
  Result := res.Success;
  if Result then
    KA := Res.Value;
end;

begin
  SetCanvas;
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
  Printer.EndDoc;
end;

procedure LoadLines(const S: string; const Enc: Integer = 866);
begin
  FileName := S;
  Lines := TStringList.Create;
  Lines.LoadFromFile(FileName, TEncoding.GetEncoding(Enc));
end;

initialization
  //Lines := TStringList.Create;

finalization
  Lines.Free;
end.

