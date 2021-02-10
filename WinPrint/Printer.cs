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
        public static float FontSize = 10.0F;
        public static float LineGap = 5.0F;

        public static bool NewLineOnAttributes = false; // true;
        public static bool DrawNumbers = false; // true;
        public static bool DrawZones = false; // true;

        public static int MarginLeft = 100; // 100
        public static int MarginRight = 50; // 40
        public static int MarginTop = 50; // 40
        public static int MarginBottom = 50; // 40

        //
        private static string _documentName;
        private static string _documentHeader;

        private static string[] _textLines;
        private static bool _xmlMode;

        private static Font _font;
        private static float _fontHeight;

        private static int _currentPageNumber;
        private static int _currentLineNumber;
        private static bool _currentLineContinued;

        public static string ListNames()
        {
            var printDoc = new PrintDocument();
            string defaultName = printDoc.PrinterSettings.PrinterName;

            var names = new StringBuilder();
            int i = 0;
            foreach (string name in PrinterSettings.InstalledPrinters)
            { 
                string d = name.Equals(defaultName) ? "*" : " ";
                names.AppendLine($"{i++,3}{d} \"{name}\"");
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

        public static bool LoadLines(FileInfo file, string codepage)
        {
            _documentName = $"{App.Name} - {file.Name}";
            _documentHeader = $"[{file.Name} - {file.LastWriteTime}]";

            if (file.Extension.ToLower().Equals(".xml"))
            {
                ReadFileAsXml(file.FullName);
            }
            else
            {
                _textLines = File.ReadAllLines(file.FullName, Encoding.GetEncoding(codepage));

                if (_textLines[0].StartsWith("<"))
                {
                    ReadFileAsXml(file.FullName);
                }
            }

            return _textLines.Length > 0;

            void ReadFileAsXml(string filename)
            {
                var xml = new XmlDocument();
                xml.Load(filename);

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
                    xml.Save(writer);
                }

                lines.Replace("&quot;", "\"")
                    .Replace("&apos;", "'").Replace("&amp;", "&")
                    .Replace("&lt;", "<").Replace("&gt;", ">");

                _textLines = lines.ToString().Split('\n');
                _xmlMode = true;
            }
        }

        public static void PrintPreview()
        {
            var printDoc = new PrintDocument
            {
                DocumentName = _documentName
            };

            printDoc.BeginPrint += PrintDoc_BeginPrint;
            printDoc.PrintPage += PrintDoc_PrintPage;
            printDoc.EndPrint += PrintDoc_EndPrint;

            printDoc.DefaultPageSettings.Margins = new Margins(
                MarginLeft,
                MarginRight,
                MarginTop,
                MarginBottom);

            PrintPreviewDialog preview = new PrintPreviewDialog
            {
                Document = printDoc,
                WindowState = FormWindowState.Maximized
            };

            preview.ShowDialog();
        }

        public static bool PrintLines(string printer = null)
        {
            int count = PrinterSettings.InstalledPrinters.Count;
            if (count == 0)
            {
                return false;
            }

            var printDoc = new PrintDocument
            {
                DocumentName = _documentName
            };

            if (printer != null)
            {
                if (int.TryParse(printer, out int num)) // int number
                {
                    if (num >= 0 && num < count)
                    {
                        printDoc.PrinterSettings.PrinterName = PrinterSettings.InstalledPrinters[num];
                    }
                }
                else // string name
                {
                    printDoc.PrinterSettings.PrinterName = printer;
                }
            }

            int hardX = (int)printDoc.DefaultPageSettings.HardMarginX;
            int hardY = (int)printDoc.DefaultPageSettings.HardMarginY;

            printDoc.DefaultPageSettings.Margins = new Margins(
                MarginLeft - hardX,
                MarginRight + hardX, 
                MarginTop - hardY,
                MarginBottom + hardY);

            if (!printDoc.PrinterSettings.IsValid)
            {
                return false;
            }

            printDoc.BeginPrint += PrintDoc_BeginPrint;
            printDoc.PrintPage += PrintDoc_PrintPage;
            printDoc.EndPrint += PrintDoc_EndPrint;

            printDoc.Print();

            return true;
        }

        private static void PrintDoc_BeginPrint(object sender, PrintEventArgs e)
        {
            const byte gdiCharSet = 204; // Russian

            _font = new Font(new FontFamily(FontName), FontSize, FontStyle.Regular, GraphicsUnit.Point, gdiCharSet);
        }

        private static void PrintDoc_EndPrint(object sender, PrintEventArgs e)
        {
            _font.Dispose();
        }

        private static void PrintDoc_PrintPage(object sender, PrintPageEventArgs e)
        {
            _currentPageNumber++;
            _fontHeight = _font.GetHeight(e.Graphics);

            DrawPageNumber();
            float yPos = DrawPageHeader();

            if (DrawZones) DrawZone(e.MarginBounds.X, e.MarginBounds.Y, e.MarginBounds.Width, e.MarginBounds.Height); //DEBUG

            while (_currentLineNumber < _textLines.Length)
            {
                if (yPos >= e.MarginBounds.Bottom)
                {
                    e.HasMorePages = true;
                    break;
                }

                string text = _textLines[_currentLineNumber];
                if (text.Length == 0)
                {
                    if (DrawNumbers) DrawLineNumber();

                    yPos += _fontHeight; // + LineGap;
                    _currentLineNumber++;
                    continue;
                }

                float x = e.MarginBounds.X;
                float width = e.MarginBounds.Width;

                if (_xmlMode)
                {
                    string txt = text.TrimStart(' ');

                    if (!_currentLineContinued)
                    {
                        float indent = (text.Length - txt.Length) * 20.0F;
                        x += indent;
                        width -= indent;
                    }

                    text = txt;
                }

                var place = new RectangleF(x, yPos, width, e.MarginBounds.Bottom - yPos);
                var textSize = e.Graphics.MeasureString(text, _font, place.Size, StringFormat.GenericTypographic,
                    out int charsFitted, out int linesFilled);

                if (linesFilled == 0) // No space for new lines
                {
                    e.HasMorePages = true;
                    break;
                }

                if (charsFitted < text.Length)
                {
                    if (DrawNumbers) DrawLineNumber();

                    DrawText(text, place);

                    _textLines[_currentLineNumber] = text.Substring(charsFitted);
                    _currentLineContinued = true;

                    e.HasMorePages = true;
                    break;
                }

                if (DrawNumbers) DrawLineNumber();

                DrawText(text, place);
                yPos += textSize.Height + LineGap;

                _currentLineNumber++;
                _currentLineContinued = false;
            }

            void DrawText(string text, RectangleF place)
            {
                e.Graphics.DrawString(text, _font, Brushes.Black, place, StringFormat.GenericTypographic);
            }

            float DrawPageHeader()
            {
                string txt = _documentHeader;

                var plc = new RectangleF(e.MarginBounds.Left, e.MarginBounds.Top,
                    e.MarginBounds.Width * 0.8F, e.MarginBounds.Bottom);
                var txtSize = e.Graphics.MeasureString(txt, _font, plc.Size, StringFormat.GenericTypographic);
                e.Graphics.DrawString(txt, _font, Brushes.DarkGray, plc, StringFormat.GenericTypographic);

                return e.MarginBounds.Top + txtSize.Height + _fontHeight + LineGap; // next yPos
            }

            void DrawPageNumber()
            {
                string txt = $"{_currentPageNumber}";
                var txtSize = e.Graphics.MeasureString(txt, _font);

                e.Graphics.DrawString(txt, _font, Brushes.DarkGray, e.MarginBounds.Right - txtSize.Width, e.MarginBounds.Top,
                    StringFormat.GenericTypographic);
            }

            void DrawLineNumber()
            {
                if (!_currentLineContinued)
                {
                    string txt = $"{_currentLineNumber + 1}: ";
                    var txtSize = e.Graphics.MeasureString(txt, _font);

                    e.Graphics.DrawString(txt, _font, Brushes.LightGray, e.MarginBounds.Left - txtSize.Width, yPos,
                        StringFormat.GenericTypographic);
                }
            }

            void DrawZone(float x, float y, float width, float height)
            {
                e.Graphics.DrawRectangle(new Pen(Brushes.LightGray), x, y, width, height);
            }
        }
    }
}
