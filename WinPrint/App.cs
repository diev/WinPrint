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

using System;
using System.Reflection;
using System.Configuration;

namespace Helpers
{
    public class App
    {
        public static string Name;
        public static string Version;
        public static string Banner;

        static App()
        {
            Assembly asm = Assembly.GetCallingAssembly();

            Name = asm.GetName().Name;
            Version = asm.GetName().Version.ToString(3);
            Banner = $"{Name} v{Version}";

            Type type = typeof(AssemblyDescriptionAttribute);
            if (AssemblyDescriptionAttribute.IsDefined(asm, type))
            {
                AssemblyDescriptionAttribute a =
                    (AssemblyDescriptionAttribute)AssemblyDescriptionAttribute.GetCustomAttribute(asm, type);
                Banner += " - " + a.Description;
            }

            type = typeof(AssemblyCopyrightAttribute);
            if (AssemblyCopyrightAttribute.IsDefined(asm, type))
            {
                AssemblyCopyrightAttribute a =
                    (AssemblyCopyrightAttribute)AssemblyCopyrightAttribute.GetCustomAttribute(asm, type);
                Banner += Environment.NewLine + a.Copyright.Replace("©", "(c)");
            }
        }
    }
}
