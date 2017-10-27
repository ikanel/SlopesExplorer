using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace GeoNamesClient
{
   public class Result
    {
        public int ZoneID { get; set; }
        public int ParentID { get; set; }
        public double Lat { get; set; }
        public double Lng { get; set; }
    }
}
