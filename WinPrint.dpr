program WinPrint;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Vcl.Printers,
  UsageUnit in 'UsageUnit.pas',
  PrintUnit in 'PrintUnit.pas';

var
  FileName: string;

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    if (ParamCount = 0) or
       FindCmdLineSwitch('?') or
       FindCmdLineSwitch('h') or
       FindCmdLineSwitch('help') then
      Usage();

    if Printer.Printers.Count = 0 then
      Usage(1, 'Нет установленных принтеров!');

    if (ParamCount = 2) then
      SelectPrinter(ParamStr(2));

    FileName := ParamStr(1);
    if not FileExists(FileName) then
      Usage(2, 'Нет такого файла %s', [FileName]);

    LoadLines(FileName);
    PrintLines;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
