# WinPrint
Windows Print - программа графической печати текстов cp866 и XML.

## Build

* Embarcadero Delphi 10.2 Starter - https://www.embarcadero.com/products/delphi
* Microsoft Build Tools 2015 - https://www.microsoft.com/ru-ru/softmicrosoft/BuildTools2015.aspx

## Version Info
About this option in RAD Studio:

**Auto generate build number** generates the **Release** and **Build** number 
for you, and increments the numbers each time you 
select *Project* > *Build <Project>*. 
When **Auto generate build number** is set: 
* **Release** = number of days since Jan 1 2000 
* **Build** = number of seconds since midnight (00:00:00), divided by 2 

Note: Auto generate build number might require you to set the environment 
variable (`SAVEVRC=TRUE`). Go to *Tools* > *Options* > *Environment 
Options* > *Environment Variables* and add a new User variable called `SAVEVRC` 
with Value=`TRUE`. This variable enables the generation of a `.vrc` file with 
an auto generated build number and other information. 
This information is compiled and added to the `.res` file. If you right-click 
the executable `.exe` file in the Windows File Explorer, select *Properties* 
from the context menu, and find the *File version* in the Properties box. 

## License

Licensed under the [Apache License, Version 2.0](LICENSE).
