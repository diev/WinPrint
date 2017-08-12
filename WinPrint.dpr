program WinPrint;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
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

    FileName := ParamStr(1);
    LoadLines(FileName);
    PrintLines;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
