# WinPrint

Windows Print - программа графической печати текстов cp866 и XML.

## Build

 * Embarcadero Delphi 10.3 - https://www.embarcadero.com/products/delphi/starter 
(проект версии 1.х)
 * Build Tools for Visual Studio 2019 - https://visualstudio.microsoft.com/downloads/
(проект с версии 2.0 ведется на C# для .NET 4.8)

## Usage

No parameters: `winprint.exe`  
It makes the output as follows:
```
WinPrint v1.5.7486.56997 (2020-06-30) - Программа графической печати текстов cp866 и XML.
(c) 2010-2020 Dmitrii Evdokimov

В качестве параметра требует имя файла для печати.
Вторым параметром может быть указан принтер (номер или имя в cp866).

Программа видит следующие принтеры (* - по умолчанию):

  0  "Send To OneNote 2013"
  1  "OneNote for Windows 10"
  2  "Microsoft Print to PDF"
  3* "Kyocera ECOSYS P3055dn KX"
  4  "Kyocera ECOSYS P2235dn XPS"
  5  "Kyocera ECOSYS P2235dn"
  6  "Fax"

Нажмите Enter для выхода
```

One parameter: `winprint.exe text.txt`  
It prints the specified file to the default printer (#3 in the output above, 
marked by `*`).

Two parameters: `winprint.exe text.txt 2` or  
`winprint.exe text.txt "Microsoft Print to PDF"`  
It prints the specified file to the specified printer (i.e. #2 in the output 
above).

## Delphi Version Info

About this option in RAD Studio:

**Auto generate build number** generates the **Release** and **Build** number 
for you, and increments the numbers each time you 
select *Project* > *Build Project*.

When **Auto generate build number** is set:
 
 * **Release** = number of days since Jan 1 2000 (i.e. 7486 for 2020-06-30) 
 * **Build** = number of seconds since midnight (00:00:00), divided by 2 

Auto generate build number might require you to set the environment 
variable (`SAVEVRC=TRUE`). Go to *Tools* > *Options* > *Environment 
Options* > *Environment Variables* and add a new User variable called `SAVEVRC` 
with Value = `TRUE`. This variable enables the generation of a `.vrc` file with 
an auto generated build number and other information. 
This information is compiled and added to the `.res` file.

If you right-click the executable `.exe` file in the Windows File Explorer, 
select *Properties* from the context menu, and find the *File version* in the 
Properties box. 

An example looks like a `v1.5.7486.56997`.

## License

Licensed under the [Apache License, Version 2.0].

[Apache License, Version 2.0]: http://www.apache.org/licenses/LICENSE-2.0 "LICENSE"
