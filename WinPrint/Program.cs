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

namespace WinPrint
{
    class Program
    {
        static void Main(string[] args)
        {
            int count = args.Length;
            if (count == 0 || "/? /h -? -h --help".Contains(args[0].ToLower()))
            {
                Usage();
            }

            string source = args[0];
            string printer = count > 1 ? args[1] : "*";
            string codepage = count > 2 ? args[2] : "cp866";

            Process(source, printer, codepage);

            Environment.Exit(0);
        }

        static void Process(string source, string printer, string codepage)
        {
            if (File.Exists(source))
            {
                ProcessOne(new FileInfo(source));
            }
            else if (Directory.Exists(source))
            {
                var dir = new DirectoryInfo(source);
                foreach (var file in dir.GetFiles())
                {
                    ProcessOne(file);
                }
            }
            else if (source.Contains("*") || source.Contains("?"))
            {
                string name = ".";
                string mask = source;

                int pos = source.LastIndexOf(@"\");
                if (pos == 0) // \*
                {
                    mask = source.Substring(pos + 1);
                }
                else if (pos == 2) // c:\*
                {
                    name = source.Substring(0, pos);
                    mask = source.Substring(pos + 1);
                }
                else if (pos > 2) // c:\path\*
                {
                    name = source.Substring(0, pos - 1);
                    mask = source.Substring(pos + 1);
                }

                var dir = new DirectoryInfo(name);
                foreach (var file in dir.GetFiles(mask))
                {
                    ProcessOne(file);
                }
            }
            else
            {
                Console.WriteLine($"Невозможно найти \"{source}\"");
                Environment.Exit(2);
            }

            void ProcessOne(FileInfo file)
            {
                if (!Printer.LoadLines(file, codepage))
                {
                    Console.WriteLine($"Невозможно загрузить файл \"{file.Name}\"");
                    Environment.Exit(2);
                }

                if (printer.Equals("-"))
                {
                    Printer.PrintPreview();
                }
                else if (printer.Equals("*"))
                {
                    if (!Printer.PrintLines())
                    {
                        Console.WriteLine($"Невозможно распечатать на принтер");
                        Environment.Exit(3);
                    }
                }
                else
                {
                    if (!Printer.PrintLines(printer))
                    {
                        Console.WriteLine($"Невозможно распечатать на принтер \"{printer}\"");
                        Environment.Exit(3);
                    }
                }
            }
        }

        static void Usage()
        {
            Console.WriteLine(App.Banner);
            Console.WriteLine();
            Console.WriteLine("Параметры (-? для помощи):");
            Console.WriteLine("  1  - папка/файл/маска");
            Console.WriteLine(" [2] - принтер ([*], номер или имя; '-' для превью)");
            Console.WriteLine(" [3] - кодировка ([cp866], windows-1251, utf-8, ...)");
            Console.WriteLine();
            Console.WriteLine("Программа видит следующие принтеры (* - по умолчанию):");
            Console.WriteLine();
            Console.WriteLine(Printer.ListNames());
            Console.WriteLine("Нажмите Enter для выхода");
            Console.ReadLine();

            Environment.Exit(1);
        }
    }
}
