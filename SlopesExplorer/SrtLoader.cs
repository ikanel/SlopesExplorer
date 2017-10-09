using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Spatial
{
    public class SrtLoader
    {
        public static void LoadTopology(string fileName, double lat1, double lat2, double lon1, double lon2, Action<double> cb = null)
        {

            if (string.IsNullOrWhiteSpace(fileName)) throw new ApplicationException("Input file is required");
            FileInfo fi = new FileInfo(fileName);
            if (!fi.Exists) throw new ApplicationException("Input file not found");
            DB.ClearPoints();

            using (FileStream fs = File.Open(fileName, FileMode.Open, FileAccess.Read, FileShare.Read))
            using (BufferedStream bs = new BufferedStream(fs))
            using (StreamReader sr = new StreamReader(fileName))
            {

                int row = 1;
                int column = 1;

                SrtMetaInfo mi = GetSrtMetaInfo(sr,fi.Name);
                DB.StoreSrtInfo(mi);

                int startCol = 1, endCol = mi.Cols, startRow = 1, endRow = mi.Rows;
                if ((double)mi.XLeft < lon1) startCol = (int)((lon1 - (double)mi.XLeft) / (double)mi.Cellsize) + 1;
                if ((double)mi.XRight > lon2) endCol = mi.Cols - (int)(((double)mi.XRight - lon2) / (double)mi.Cellsize);

                if ((double)mi.YTop > lat2) startRow = 1 + (int)(((double)mi.YTop - lat2) / (double)mi.Cellsize);
                if ((double)mi.YBottom < lat1) endRow = mi.Rows - (int)((lat1 - (double)mi.YBottom) / (double)mi.Cellsize);



                string line = null;
                for (row = 0; row < startRow; row++)
                    line = sr.ReadLine();

                decimal lat = mi.YTop - mi.Cellsize * row;
                decimal lng = mi.XLeft;


                while (line != null)
                {
                    List<Point> points = new List<Point>();
                    column = 1;
                    //lng = mi.XLeft+mi.Cellsize*startCol;
                    foreach (
                        var p in
                            line.Split(' ')
                                .Where(s => !string.IsNullOrWhiteSpace(s))
                                .Select(q => int.Parse(q))
                                .ToArray())
                    {
                        if (column < startCol || column > endCol)
                        {
                            column++;
                            continue;
                        }
                        lng = mi.Cellsize * (column - 1) + mi.XLeft;
                        lat = mi.YTop - mi.Cellsize * (row - 1);


                        if (p != mi.NODATA_value)
                        {
                            points.Add(new Point() { Lat = lat, Lng = lng, Row = row, Col = column, Alt = p });
                        }

                        column++;
                    }
                    DB.AddPoints(points, mi.Cols);
                    row++;
                    if (cb != null)
                    {
                        double percent = 100.0 * (row - startRow) / (endRow - startRow);
                        cb(percent);
                    }

                    if (row > endRow) break;
                    line = sr.ReadLine();
                }
            }
        }

        static int GetIntFromText(string str)
        {
            return int.Parse(str.Substring(str.LastIndexOf(" ")));
        }

        static decimal GetDecFromText(string str)
        {
            return decimal.Parse(str.Substring(str.LastIndexOf(" ")), CultureInfo.InvariantCulture);
        }

        public static SrtMetaInfo GetSrtMetaInfo(string fileName)
        {
            if (string.IsNullOrWhiteSpace(fileName)) throw new ApplicationException("Input file is required");
            FileInfo fi = new FileInfo(fileName);
            if (!fi.Exists) throw new ApplicationException("Input file not found");
            using (FileStream fs = File.Open(fileName, FileMode.Open, FileAccess.Read, FileShare.Read))
            using (StreamReader sr = new StreamReader(fileName))
            {
                return GetSrtMetaInfo(sr,fs.Name);
            }

        }
        public static SrtMetaInfo GetSrtMetaInfo(StreamReader sr, string name)
        {
            SrtMetaInfo res = new SrtMetaInfo
            {
                Name=name,
                Cols = GetIntFromText(sr.ReadLine()),
                Rows = GetIntFromText(sr.ReadLine()),
                XLeft = GetDecFromText(sr.ReadLine()),
                YBottom = GetDecFromText(sr.ReadLine()),
                Cellsize = GetDecFromText(sr.ReadLine()),
                NODATA_value = GetIntFromText(sr.ReadLine())
            };
            return res;
        }

    }
}
