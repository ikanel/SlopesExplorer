using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using NDesk.Options;

namespace Spatial
{
    class Program
    {
        static void Main(string[] args)
        {
            List<string> names = new List<string>();
            float latFrom = -90, latTo = 90, lngFrom = -180, lngTo = 180;
            int angle = 7, vdrop = 30, minlength = 0, vdroppercent = 0, amount = 0;
            string fileName = null, outputFileName = null;
            var p = new OptionSet() {
    { "lat1=","Lattitude from. Default:-180",  (float v) => latFrom=v },
    { "lat2=","Lattitude to. Default:180",  (float v) => latTo=v },
    { "lon1=","Longitude from. Default:-90",  (float v) => lngFrom=v },
    { "lon2=","Longitude to. Default:90",  (float v) => lngTo=v },
    { "f|filename=","Input file.Should be in ESRI GRID(ARC ASCII) format.",  (string v) => fileName=v },
    { "i|fileinfo", "Display  ESRI file info.", v => DisplaySrtFileInfo(fileName)},
    { "o|output=","Output kml filename.",  (string v) => outputFileName=v },
    { "a|angle=","Minimum slope angle. Default:7",  (int v) => angle=v },
    { "d|drop=","Minimum vertical drop for the slope. Default: 30",  (int v) => vdrop=v },
    { "dp|droppercent=","Top N percent of the slopes. Overrides drop if specified.",  (int dp) => vdroppercent=dp },
    { "n| number of slopes=","Top N slopes by vertical drop. Overrides drop and percent if specified.",  (int n) => amount=n },

    { "s|minlength=","Minimum slope length. Default: 100",  (int v) => minlength=v },
    { "l|load", "Load geo-data from  ESRI GRID(ARC ASCII) file to the database.", v => {Console.WriteLine("Loading data from ESRI GRID(ARC ASCII) File.");SrtLoader.LoadTopology(fileName,latFrom,latTo,lngFrom,lngTo,(q)=>{Console.Write("\r{0:f2}%   ", q);});}},
    { "p|preprocess", "Preprocess loaded data.", v => {
        Console.WriteLine("Preprocessing loaded data. It may take a looooooong time. Started at:"+DateTime.Now);
        DB.Preprocess(angle);
        Console.WriteLine("Completed at:"+DateTime.Now);
    } },
     { "z|save2db","Save results to databaZe 'results' table. Default:false",
            v => {
                Console.WriteLine("Storing result to DB.\nStarted at:"+DateTime.Now);
                DB.StoreResultsToDatabase(vdroppercent,amount,vdrop);
                Console.WriteLine("Finished at:"+DateTime.Now);
            }},
     { "e|echo", "Display slopes information.", v => {Console.WriteLine("Slopes info. Params: min vert drop:{0}, min length:{1}",vdrop,minlength); DisplaySlopesInfo(vdrop,minlength,amount);}},
    { "x|export", "Exporting results to kml.",
        v =>{Console.WriteLine("Generating KML from the results.");
        Console.WriteLine("Started at:"+DateTime.Now);
        KmlExporter.GenerateKml(outputFileName,vdrop,vdroppercent,amount,minlength);
        Console.WriteLine("Completed at:"+DateTime.Now);
            }}



        };

            List<string> extra;
            try
            {
                if (args == null || args.Count() == 0)
                {
                    StringWriter sw = new StringWriter();
                    Console.WriteLine("ESRI GRID(ARC ASCII) parser");
                    p.WriteOptionDescriptions(sw);
                    Console.WriteLine(sw.ToString());
                }
                else
                {
                    extra = p.Parse(args);
                }


            }
            catch (OptionException e)
            {
                Console.WriteLine(e.Message);
                return;
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex.Message);
                return;
            }
        }
        static void DisplaySrtFileInfo(string fileName)
        {
            var fi = SrtLoader.GetSrtMetaInfo(fileName);
            Console.WriteLine("ESRI File info");
            Console.WriteLine("Longitude {0} - {1}", fi.XLeft, fi.XRight);
            Console.WriteLine("Latitude {0} - {1}", fi.YTop, fi.YBottom);
            Console.WriteLine("Cell size {0} meters, {1} degrees", fi.CellSizeInMeters, fi.Cellsize);
            Console.WriteLine("{0} Columns, {1} Rows", fi.Cols, fi.Rows);
        }

        static void DisplaySlopesInfo(int minDrop, int minLength, int amount)
        {
            var cellsize = DB.GetSrtInfo().CellSizeInMeters;
            foreach (var slope in DB.GetSlopeDrops(minDrop, minLength, amount))
            {
                var len = slope.Segments * 2 * cellsize;
                if (slope.Segments == 0) len = 2 * cellsize;
                Console.WriteLine("Slope {0} m drop, {1} segments.", slope.VertDrop, Math.Round(len));
                foreach (var sp in DB.GetSlopeInfo(slope.ParentID))
                {
                    Console.WriteLine("Lat:{0}, Lng:{1}, Elevation:{2}", sp.Lat, sp.Lng, sp.Alt);
                }
            }

        }
    }

}