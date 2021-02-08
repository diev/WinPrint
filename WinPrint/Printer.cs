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

using System.Drawing.Printing;
using System.Text;

namespace Helpers
{
    public static class Printer
    {
        public static string ListNames()
        {
            var names = new StringBuilder();
            var doc = new PrintDocument();
            string defaultName = doc.PrinterSettings.PrinterName;
            int count = PrinterSettings.InstalledPrinters.Count;

            for (int i = 0; i < count; i++)
            {
                string name = PrinterSettings.InstalledPrinters[i];
                string d = name.Equals(defaultName) ? "*" : " ";

                names.AppendLine($"{i,3}{d} \"{name}\"");
            }

            return names.ToString();
        }
    }
}
