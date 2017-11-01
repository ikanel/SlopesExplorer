using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Spatial
{
   public class SlopeDrop
    {
        public int ZoneID {get; set; }
        public int ParentID { get; set; }
        public int VertDrop { get; set; }
        public int Segments { get; set; }
        public string Country { get; set; }
        public string Region { get; set; }
        public string MountName { get; set; }

    }
}
