#region License
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
#endregion

using Helpers;

using System;
using System.IO;
using System.Text;

namespace WinPrint
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 0)
            {
                Usage();
            }
 
            #if DEBUG
            Console.ReadKey();
            #endif
            Environment.Exit(0);
        }

        static void Usage()
        {
            Console.WriteLine(App.Banner);
            Console.WriteLine();
            Console.WriteLine("В качестве параметра требует имя файла для печати.");
            Console.WriteLine("Вторым параметром может быть указан принтер (номер или имя в cp866).");
            Console.WriteLine();
            Console.WriteLine("Программа видит следующие принтеры (* - по умолчанию):");
            Console.WriteLine();
            Console.WriteLine(Printer.ListNames());
            Console.WriteLine("Нажмите Enter для выхода");
            Console.ReadLine();

            #if DEBUG
            Printer.ReadFile("test.xml", 1251);
            Printer.PrintPreview();
            #endif

            Environment.Exit(1);
        }
    }
}
