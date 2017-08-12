program WinPrint;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  UsageUnit in 'UsageUnit.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    if (ParamCount = 0) or
       FindCmdLineSwitch('?') or
       FindCmdLineSwitch('h') or
       FindCmdLineSwitch('help') then
      Usage();

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
