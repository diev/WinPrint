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

program WinPrint;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  Vcl.Printers,
  UsageUnit in 'UsageUnit.pas',
  PrintUnit in 'PrintUnit.pas',
  VersionInfoUnit in 'VersionInfoUnit.pas';

resourcestring
  NoInstalledPrinters = 'Нет установленных принтеров!';
  NoSuchFile = 'Нет такого файла %s';

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
      Usage(1, NoInstalledPrinters);

    if (ParamCount = 2) then
      SelectPrinter(ParamStr(2));

    FileName := ParamStr(1);
    if not FileExists(FileName) then
      Usage(2, NoSuchFile, [FileName]);

    LoadLines(FileName);
    PrintLines;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
