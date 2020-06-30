unit UsageUnit;

interface

procedure PrintersInfo;
procedure SelectPrinter(const S: string);
procedure Usage(const Err: Integer = 0; const Msg: string = ''); overload;
procedure Usage(const Err: Integer; const Fmt: string; const Args: array of const); overload;

implementation

uses
  System.SysUtils,
  Vcl.Printers,
  VersionInfoUnit;

resourcestring
  // Usage1 = 'Windows Print - программа графической печати текстов cp866 и XML.';
  Usage2 = 'В качестве параметра требует имя файла для печати.';
  Usage3 = 'Вторым параметром может быть указан принтер (номер или имя в cp866).';

  ErrorHeading = 'ОШИБКА:';
  PrintersAvailable = 'Программа видит следующие принтеры (%s - по умолчанию):';
  PrintersAvailableDefault = '*';
  PrintersAvailableOthers = ' ';
  PrintersAvailableFormat = '%3u%s "%s"';
  NoSuchPrinterNumber = 'Нет принтера с номером %s';
  NoSuchPrinterName = 'Нет принтера с именем (в cp866) "%s"';
  PressEnterToExit = 'Нажмите Enter для выхода';

procedure PrintersInfo;
var
  I: Integer;
  S: string;

begin
  Writeln(Format(PrintersAvailable, [PrintersAvailableDefault]));
  Writeln;

  for I := 0 to Printer.Printers.Count - 1 do
  begin
    if I = Printer.PrinterIndex then
      S := PrintersAvailableDefault
    else
      S := PrintersAvailableOthers;

    Writeln(Format(PrintersAvailableFormat, [I, S, Printer.Printers[I]]));
  end;
end;

procedure SelectPrinter(const S: string);
var
  I: Integer;

begin
  if TryStrToInt(S, I) then
  begin
    if (I > -1) and (I < Printer.Printers.Count) then
      Printer.PrinterIndex := I
    else
      Usage(3, NoSuchPrinterNumber, [S]);
  end
  else
  begin
    I := Printer.Printers.IndexOf(S);

    if I = -1 then
      Usage(4, NoSuchPrinterName, [S]);

    Printer.PrinterIndex := I;
  end;
end;

procedure Usage(const Err: Integer = 0; const Msg: string = ''); overload;
var
  FVI: TFileVersionInfo;

begin
  FVI := FileVersionInfo(ParamStr(0));

  Writeln(Format('%s v%s - %s', [FVI.ProductName, FVI.FileVersion, FVI.FileDescription]));
  Writeln(FVI.LegalCopyRight);
  Writeln;

  Writeln(Usage2);
  Writeln(Usage3);
  Writeln;

  if Msg.Length > 0 then
  begin
    Writeln(ErrorHeading);
    Writeln(Msg);
  end
  else
    PrintersInfo;

  Writeln;
  Writeln(PressEnterToExit);
  Readln;

  Halt(Err);
end;

procedure Usage(const Err: Integer; const Fmt: string; const Args: array of const); overload;
begin
  Usage(Err, Format(Fmt, Args));
end;

end.

