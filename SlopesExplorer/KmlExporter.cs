using SharpKml.Base;
using SharpKml.Dom;
using SharpKml.Engine;
using System;
using System.Collections.Generic;
using System.Device.Location;
using System.IO;
using System.Linq;
using System.Security.Permissions;
using System.Text;
using System.Threading.Tasks;

namespace Spatial
{
    public static class KmlExporter
    {
        public static void GenerateKml(string fileName, int minDrop,int percent, int amount, int minLength, bool fromResults=false)
        {
            if (string.IsNullOrWhiteSpace(fileName)) throw new ApplicationException("Output filename is required");
            if (percent > 0 && amount==0)  minDrop=DB.GetMinDropByPercent(percent);
            var drops = fromResults?DB.GetSlopeDropsFromResults(minDrop,amount): DB.GetSlopeDrops(minDrop,minLength,amount);

            if (drops == null || drops.Count() == 0)
            {
                throw new ApplicationException("Slopes data not found or there are no slopes in the selected area. Please change filter conditions or run preprocess(-p) prior to export.");
            }
            Folder fld = new Folder();

          //  var srtInfo = DB.GetSrtInfo();

            // This will be the location of the Placemark.
            foreach (var slope in drops)
            {
                LineString line = new LineString();
                line.Coordinates = new CoordinateCollection();
                var points = fromResults?DB.GetSlopeInfoFromResults(slope.ZoneID,slope.ParentID):DB.GetSlopeInfo(slope.ParentID);
                line.Coordinates = new CoordinateCollection(ExtractPoint(points));
                Placemark placemark = new Placemark();
                placemark.Geometry = line;
                
                var length = GetLineLength(line.Coordinates);
                placemark.Name = 
                    string.IsNullOrWhiteSpace(slope.MountName)==false?
                    string.Format("{0} ({1})",slope.MountName??"",slope.Region??"").Trim():
                string.Format("H{0}:L{1}:A{2}", slope.VertDrop, Math.Round(length), Math.Round(Math.Atan(slope.VertDrop / length) * (180.0 / Math.PI))).Trim();
                placemark.Description = new Description()
                {
                    Text = $"Vertical Drop:{slope.VertDrop}m/{Math.Round(slope.VertDrop*3.28084)}ft\nLength:{Math.Round(length)}m/{Math.Round(length*3.28084)}ft\nAvg.incline:{Math.Round(Math.Atan(slope.VertDrop / length) * (180.0 / Math.PI))} degrees"
                };
                
                fld.AddFeature(placemark);
            }
            // This allows us to save and Element easily.
            KmlFile kml = KmlFile.Create(fld, false);
            using (var stream = System.IO.File.Open(fileName, FileMode.Create))
            {
                kml.Save(stream);
            }
        }

        public static void ParseKml(string fileName)
        {
            KmlFile kml;
            using (var stream = System.IO.File.Open(fileName, FileMode.Open))
            {
                kml=KmlFile.Load(stream);
            }
            int parentID = 1;
            FileInfo fi = new FileInfo(fileName);
            int zoneId = DB.CreateZone(fi.Name);
            
            
            DB.StoreSrtInfo(new SrtMetaInfo()
            {
                Name = fi.Name,
            });
            foreach (var coords in kml.Root.Flatten().Where(q=>q is CoordinateCollection).Select(s=>(CoordinateCollection)s))
            {
                foreach (var coord in coords)
                {
                    DB.StoreResult(coord.Latitude,coord.Longitude,(int)coord.Altitude,zoneId,parentID);
                }
                parentID++;
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
