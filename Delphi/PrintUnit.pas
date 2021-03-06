//------------------------------------------------------------------------------
// Copyright (c) Dmitrii Evdokimov
// Source https://github.com/diev/
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//------------------------------------------------------------------------------

unit PrintUnit;

interface

uses
  System.Classes;

procedure LoadLines(const S: string; const Enc: Integer = 866);
procedure PrintLines;

implementation

uses
  System.SysUtils,
  //System.RegularExpressions,
  Vcl.Printers,
  Xml.XMLDoc,
  Xml.XMLIntf;

const
  FontSize: Integer = 10;

  TopMargin: Integer = 3;
  BottomMargin: Integer = 4;

  LeftMargin: Integer = 8;
  RightMargin: Integer = 3;

var
  FileName: string;
  Lines: TStrings;
  LineHeight, CharWidth, LinesHeight, MaxLines, MaxChars: Integer;
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

    // lines per page
    MaxLines := Trunc((LinesHeight - TopY) / LineHeight);

    // move to the first line
    LineY := TopY;
  end;
end;

procedure PrintLine(const S: string);
var
  I, N: Integer;

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
      N := 0;
      while S.Substring(N, 1) = ' ' do
        Inc(N);

      PrintLine(StringOfChar(' ', N) + S.Substring(I).TrimLeft);
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
  I, N: Integer;
  S: string;
  //KA: string;
  //Sign: Boolean;
  timeDate: TDateTime;

  //Obsolete with PKCS#7
  //function TryGetKA(const S: string; out KA: string): Boolean;
  //var
  //  Res: TMatch;
  //begin
  //  Res := TRegEx.Match(S, '(\d{12})');
  //  Result := res.Success;
  //  if Result then
  //    KA := Res.Value;
  //end;

begin
  SetCanvas;
  //Sign := false;

  FileAge(FileName, timeDate);
  PrintLine(Format('[%s - %s]',
    [ExtractFileName(FileName), DateTimeToStr(timeDate)]));

  N := 2;
  if Lines.Count < (MaxLines - 20) then
    N := 12;

  for I := 0 to N - 1 do
    PrintLine('');

  for I := 0 to Lines.Count - 1 do
  begin
    S := TrimRight(Lines[I]);

    //Obsolete with PKCS#7
    //if S.StartsWith('o000000') then
    //  Sign := true;
    //if Sign then
    //begin
    //  if TryGetKA(S, KA) then
    //    PrintLine(Format('[KA %s]', [KA]));
    //end
    //else

    PrintLine(S);
  end;

  Printer.EndDoc;
end;

procedure LoadLines(const S: string; const Enc: Integer = 866);
var
  Doc: IXMLDocument;
  Txt: string;

begin
  FileName := S;
  Lines := TStringList.Create;
  Lines.LoadFromFile(FileName, TEncoding.GetEncoding(Enc));

  if Lines[0].StartsWith('<') then //XML
  begin
    Lines.Clear;

    Doc := TXMLDocument.Create(nil);
    try
      Doc.LoadFromFile(S);
      Doc.NodeIndentStr := '  ';
      Doc.Options := Doc.Options + [doNodeAutoIndent];
      Txt := Doc.XML.Text;
    finally
      Doc := nil;
    end;

    Txt := FormatXMLData(Txt);

    //Txt := StringReplace(Txt, '>', '>' + #13#10, [rfReplaceAll]);
    Txt := StringReplace(Txt, '&quot;', '"', [rfReplaceAll]);
    Txt := StringReplace(Txt, '&apos;', '''', [rfReplaceAll]);
    Txt := StringReplace(Txt, '&amp;', '&', [rfReplaceAll]);
    Txt := StringReplace(Txt, '&lt;', '<', [rfReplaceAll]);
    Txt := StringReplace(Txt, '&gt;', '>', [rfReplaceAll]);

    Lines.Text := Txt;
  end;
end;

initialization
  //Lines := TStringList.Create;

finalization
  Lines.Free;
end.
