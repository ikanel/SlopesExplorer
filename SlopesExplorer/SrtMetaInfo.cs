using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Device.Location;
namespace Spatial
{
    public class SrtMetaInfo
    {
        public string Name;
        public int Cols;
        public int Rows;
        public decimal XLeft;
        public decimal YBottom;
        public decimal Cellsize;
        public int NODATA_value;

        public double CellSizeInMeters
        {
            get
            {
                return GetDistanceBetweenPoints(0, 0, (double)Cellsize, 0);
            }
        }

        public decimal XRight
        {
            get
            {
                return XLeft + Cellsize * Cols;
            }
        }

        public decimal YTop
        {
            get
            {
                return YBottom + Cellsize * Cols;
            }
        }

        public int GetSegmentsCountFromDistance(double distance)
        {
            return (int)Math.Ceiling(distance / CellSizeInMeters);
        }

        public static double GetDistanceBetweenPoints(double lat1, double lat2, double lon1, double lon2)
        {
            var sCoord = new GeoCoordinate(lat1, lon1);
            var eCoord = new GeoCoordinate(lat2, lon2);
            return sCoord.GetDistanceTo(eCoord);
        }
    }
}