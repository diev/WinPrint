unit UsageUnit;

interface

procedure PrintersInfo;
procedure Usage(const Err: Integer = 0; const Msg: string = ''); overload;
procedure Usage(const Err: Integer; const Fmt: string; const Args: array of const); overload;

implementation

uses
  System.SysUtils,
  Vcl.Printers;

resourcestring
  Usage1 = 'Windows Print - программа графической печати текстов cp866.';
  Usage2 = 'В качестве параметра требует имя файла для печати.';
  Usage3 = 'Вторым параметром может быть указан принтер (номер или имя в cp866).';

procedure PrintersInfo;
var
  i: Integer;
  s: string;
begin
  Writeln('Программа видит следующие принтеры (* - по умолчанию):');
  Writeln;
  for i := 0 to Printer.Printers.Count - 1 do
  begin
    if i = Printer.PrinterIndex then
      s := '*'
    else
      s := ' ';
    Writeln(Format('%3u%s "%s"', [i, s, Printer.Printers[i]]));
  end;
end;

procedure Usage(const Err: Integer = 0; const Msg: string = ''); overload;
begin
  Writeln(Usage1);
  Writeln(Usage2);
  Writeln(Usage3);
  Writeln;

  if Msg.Length > 0 then
  begin
    Writeln('ОШИБКА:');
    Writeln(Msg);
  end
  else
    PrintersInfo;

  Writeln;
  Writeln('Нажмите Enter для выхода');
  Readln;
  Halt(Err);
end;

procedure Usage(const Err: Integer; const Fmt: string; const Args: array of const); overload;
begin
  Usage(Err, Format(Fmt, Args));
end;

end.
