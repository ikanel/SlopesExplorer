﻿using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Dapper;
using System.Data;

namespace Spatial
{
    public class DB
    {
        private static SqlConnection _con;
        static SqlConnection Connection
        {
            get
            {
                if (_con != null) return _con;
                string connstr = ConfigurationManager.ConnectionStrings["stat"].ConnectionString;
                _con = new SqlConnection(connstr);
                _con.Open();
                return _con;
            }
        }

        public static void Preprocess(double angle)
        {
            var srtInfo = GetSrtInfo();
            var delta = Math.Tan(angle * (Math.PI / 180)) * srtInfo.CellSizeInMeters;
            Connection.Execute("preprocess", new { delta = delta }, null, 3600*3, CommandType.StoredProcedure);
        }

        public static void StoreSrtInfo(SrtMetaInfo info)
        {
            Connection.Execute("store_srt_meta_info", new
            {
                Cols = info.Cols,
                Rows = info.Rows,
                XLeft = info.XLeft,
                YBottom = info.YBottom,
                Cellsize = info.Cellsize,
                CellsizeInMeters = info.CellSizeInMeters
            }, commandType: CommandType.StoredProcedure);
        }
        public static SrtMetaInfo GetSrtInfo()
        {
            return Connection.Query<SrtMetaInfo>("SELECT * FROM SrtMetaInfo").FirstOrDefault();
        }

        public static IEnumerable<SlopeDrop> GetSlopeDrops(int minDrop, int minLength)
        {
            var segments = Math.Ceiling(minLength / GetSrtInfo().CellSizeInMeters);
            return Connection.Query<SlopeDrop>("select ParentID, VertDrop,Segments from max_drops where VertDrop>=@drop and 2*Segments>=@seg order by VertDrop desc", new { drop = minDrop, seg = segments });
        }

        public static IEnumerable<Point> GetSlopeInfo(int ParentID)
        {
            return Connection.Query<Point>("SELECT distinct Lat,Lng, Row,Col, Elevation as Alt from Results WHERE ParentID=@pid ORDER BY Alt DESC", new { pid = ParentID });
        }

        public static void AddPoint(Point point)
        {
            string processQuery = "INSERT INTO [dbo].[Points] ([Lat],[Lng],[Row],[Column],[Elevation])  VALUES (@Lat,@Lng,@Row,@Col,@Alt)";
            Connection.Execute(processQuery, point, null, 3600 * 1);
        }

        public static void AddPoints(List<Point> points, int rowSize)
        {
            DataTable dt = new DataTable();
            dt.Columns.Add("Lat", typeof(decimal));
            dt.Columns.Add("Lng", typeof(decimal));
            dt.Columns.Add("Row", typeof(int));
            dt.Columns.Add("Column", typeof(int));
            dt.Columns.Add("Elevation", typeof(decimal));
            dt.Columns.Add("ID", typeof(int));

            points.ForEach(q => dt.Rows.Add(new object[] { q.Lat, q.Lng, q.Row, q.Col, q.Alt,(q.Row-1)*rowSize+q.Col }));
            using (SqlBulkCopy bc = new SqlBulkCopy(Connection))
            {
                bc.DestinationTableName = "Points";
                bc.WriteToServer(dt);
            }
        }
        public static void ClearPoints()
        {
            Connection.Execute("truncate table points");
        }
    }
}
