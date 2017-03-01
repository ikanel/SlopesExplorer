using SharpKml.Base;
using SharpKml.Dom;
using SharpKml.Engine;
using System;
using System.Collections.Generic;
using System.Device.Location;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Spatial
{
    public static class KmlExporter
    {
        public static void GenerateKml(string fileName, int minDrop, int minLength)
        {
            if (string.IsNullOrWhiteSpace(fileName)) throw new ApplicationException("Output filename is required");
            var drops = DB.GetSlopeDrops(minDrop,minLength);
            if (drops == null || drops.Count() == 0)
            {
                throw new ApplicationException("Slopes data not found or there are no slopes in the selected area. Please run preprocess(-p) prior to export.");
            }
            Folder fld = new Folder();

            var srtInfo = DB.GetSrtInfo();

            // This will be the location of the Placemark.
            foreach (var slope in drops)
            {
                LineString line = new LineString();
                line.Coordinates = new CoordinateCollection();
                var points = DB.GetSlopeInfo(slope.ParentID);
                line.Coordinates = new CoordinateCollection(ExtractPoint(points));
                Placemark placemark = new Placemark();
                placemark.Geometry = line;
                var length = GetLineLength(line.Coordinates);
                placemark.Name = string.Format("H{0}:L{1}:A{2}", slope.VertDrop, Math.Round(length),Math.Round(Math.Atan(slope.VertDrop/length)*(180.0 / Math.PI)));
                fld.AddFeature(placemark);
            }
            // This allows us to save and Element easily.
            KmlFile kml = KmlFile.Create(fld, false);

            using (var stream = System.IO.File.Open(fileName, FileMode.Create))
            {
                kml.Save(stream);
            }

        }

        static double GetLineLength(CoordinateCollection coords)
        {
            double length = 0;
            var coordsArray=coords.ToArray();
            for(int i=0;i< coordsArray.Length-1;i++)
            {
                var sCoord = new GeoCoordinate(coordsArray[i].Latitude, coordsArray[i].Longitude, coordsArray[i].Altitude.Value);
                var eCoord = new GeoCoordinate(coordsArray[i+1].Latitude, coordsArray[i+1].Longitude, coordsArray[i+1].Altitude.Value);
                length+=sCoord.GetDistanceTo(eCoord);
            }
            return length;
        }

        static List<Vector> ExtractPoint(IEnumerable<Point> points)
        {
            var vector = new List<Vector>();
            foreach (var p in points)
            {
                Vector v = new Vector(Decimal.ToDouble((decimal)p.Lat), Decimal.ToDouble((decimal)p.Lng), (double)p.Alt);
                vector.Add(v);
            }
            return vector;
        }

    }
}
