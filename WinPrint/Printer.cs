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
using System.Drawing;
using System.Drawing.Printing;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Xml;

namespace Helpers
{
    public static class Printer
    {
        public static string FontName = "Times New Roman"; // "Arial"; // "Courier New";
        public static byte CharSet = 204; // Russian
        public static float FontSize = 10.0F;
        public static float LineGap = 5.0F;
        public static bool NewLineOnAttributes = true;

        public static int MarginLeft = 100;
        public static int MarginRight = 40;
        public static int MarginTop = 40;
        public static int MarginBottom = 40;

        private static string DocumentName;
        private static string DocumentHeader;

        private static string[] Lines;
        private static int LineNum = 0;
        private static bool LineContinued = false;
        private static int PageNum = 0;

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

        public static string GetPdfName()
        {
            foreach (string name in PrinterSettings.InstalledPrinters)
            {
                if (name.Contains("PDF"))
                {
                    return name;
                }
            }

            return null;
        }

        public static void ReadFile(string fileName, int codepage = 0)
        {
            var file = new FileInfo(fileName);
            if (!file.Exists)
            {
                return;
            }

            DocumentName = $"{App.Name} - {file.Name}";
            DocumentHeader = $"[{file.Name} - {file.LastWriteTime}]";

            if (file.Extension.ToLower().Equals(".xml"))
            {
                ReadFileAsXml(fileName);
            }
            else
            {
                Lines = File.ReadAllLines(fileName, codepage == 0 ?
                    Encoding.UTF8 :
                    Encoding.GetEncoding(codepage));

                if (Lines[0].StartsWith("<"))
                {
                    ReadFileAsXml(fileName);
                }
            }

            void ReadFileAsXml(string filename)
            {
                var doc = new XmlDocument();
                doc.Load(filename); //ex: File not found!

                var lines = new StringBuilder();
                var settings = new XmlWriterSettings
                {
                    Indent = true,
                    IndentChars = " ",
                    NewLineChars = "\n",
                    OmitXmlDeclaration = true,
                    NewLineOnAttributes = NewLineOnAttributes
                };

                using (var writer = XmlWriter.Create(lines, settings))
                {
                    doc.Save(writer);
                }

                lines.Replace("&quot;", "\"")
                    .Replace("&apos;", "'").Replace("&amp;", "&")
                    .Replace("&lt;", "<").Replace("&gt;", ">");

                Lines = lines.ToString().Split('\n');
            }
        }

        public static void PrintPreview()
        {
            var doc = new PrintDocument
            {
                DocumentName = DocumentName
            };
            doc.PrintPage += new PrintPageEventHandler(PrintDoc_PrintPage);
            doc.DefaultPageSettings.Margins = new Margins(MarginLeft, MarginRight, MarginTop, MarginBottom);

            PrintPreviewDialog preview = new PrintPreviewDialog
            {
                Document = doc,
                WindowState = FormWindowState.Maximized
            };
            preview.ShowDialog();
        }

        public static void Printing(string printer)
        {
            var doc = new PrintDocument
            {
                DocumentName = DocumentName
            };
            doc.PrintPage += new PrintPageEventHandler(PrintDoc_PrintPage);
            doc.PrinterSettings.PrinterName = printer;
            doc.DefaultPageSettings.Margins = new Margins(MarginLeft, MarginRight, MarginTop, MarginBottom);

            if (doc.PrinterSettings.IsValid)
            {
                doc.Print();
            }
            else
            {
                Console.WriteLine("Printer is invalid.");
            }
        }

        private static void PrintDoc_PrintPage(object sender, PrintPageEventArgs e)
        {
            var fontFamily = new FontFamily(FontName);
            var font = new Font(fontFamily, FontSize, FontStyle.Regular, GraphicsUnit.Point, CharSet);
            float fontHeight = font.GetHeight(e.Graphics);

            DrawPageNumber();
            float yPos = DrawPageHeader();

            if (Lines == null)
            {
                return;
            }

            while (LineNum < Lines.Length)
            {
                if (yPos >= e.MarginBounds.Bottom)
                {
                    e.HasMorePages = true;
                    break;
                }

                string text1 = Lines[LineNum];
                string text = text1.TrimStart(' ');

                if (text.Length == 0)
                {
                    DrawLineNumber();

                    yPos += fontHeight; // + LineGap;
                    LineNum++;
                    continue;
                }

                float indent = 0.0F;
                if (!LineContinued)
                {
                    indent = (text1.Length - text.Length) * 20.0F;
                }

                var place = new RectangleF(e.MarginBounds.X + indent, yPos, 
                    e.MarginBounds.Width - indent, e.MarginBounds.Bottom - yPos);
                var textSize = e.Graphics.MeasureString(text, font, place.Size, StringFormat.GenericTypographic,
                    out int charsFitted, out int linesFilled);

                if (linesFilled == 0) // No space for new lines
                {
                    e.HasMorePages = true;
                    break;
                }

                if (charsFitted < text.Length)
                {
                    DrawLineNumber();
                    DrawText(text, place);

                    Lines[LineNum] = text.Substring(charsFitted);
                    LineContinued = true;
                    e.HasMorePages = true;
                    break;
                }

                DrawLineNumber();
                DrawText(text, place);
                yPos += textSize.Height + LineGap;

                LineNum++;
                LineContinued = false;
            }

            void DrawText(string text, RectangleF place)
            {
                e.Graphics.DrawString(text, font, Brushes.Black, place, StringFormat.GenericTypographic);
            }

            float DrawPageHeader()
            {
                string txt = DocumentHeader;

                var plc = new RectangleF(e.MarginBounds.Left, e.MarginBounds.Top,
                    e.MarginBounds.Width * 0.8F, e.MarginBounds.Bottom);
                var txtSize = e.Graphics.MeasureString(txt, font, plc.Size, StringFormat.GenericTypographic);
                e.Graphics.DrawString(txt, font, Brushes.DarkGray, plc, StringFormat.GenericTypographic);

                return e.MarginBounds.Top + txtSize.Height + fontHeight + LineGap; // next yPos
            }

            void DrawPageNumber()
            {
                string txt = $"{++PageNum}";
                var txtSize = e.Graphics.MeasureString(txt, font);

                e.Graphics.DrawString(txt, font, Brushes.DarkGray,
                    e.MarginBounds.Right - txtSize.Width,
                    e.MarginBounds.Top,
                    StringFormat.GenericTypographic);
            }

            void DrawLineNumber()
            {
                if (!LineContinued)
                {
                    string txt = $"{LineNum + 1}: ";
                    var txtSize = e.Graphics.MeasureString(txt, font);

                    e.Graphics.DrawString(txt, font, Brushes.LightGray, 
                        e.MarginBounds.Left - txtSize.Width,
                        yPos,
                        StringFormat.GenericTypographic);
                }
            }
        }
    }
}
