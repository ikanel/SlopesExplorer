using Dapper;
using RestSharp;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace GeoNamesClient
{
    class Program
    {
       static  SqlConnection _con;
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
        static void Main(string[] args)
        {
            Console.WriteLine("TOP_RESULTS table will be enriched with names for the mountain, country and state.");
            RestClient rc = new RestClient("http://api.geonames.org");
            var res=Connection.Query<Result>("SELECT ZoneID,ParentID,Lat,Lng FROM TOP_Results where Country is null");
            foreach (var r in res)
            {
                var request = new RestRequest("findNearbyJSON", Method.GET);
                request.AddParameter("lat", r.Lat); // adds to POST or URL querystring based on Method
                request.AddParameter("lng", r.Lng); // adds to POST or URL querystring based on Method
                request.AddParameter("username", "kanel"); // adds to POST or URL querystring based on Method

                var rnb=rc.Execute<dynamic>(request);
                request.Resource = "countrySubdivisionJSON";
                var csb = rc.Execute<dynamic>(request);
                try
                {
                    string country;
                    try
                    {
                        country = csb.Data["countryName"];
                    }
                    catch (KeyNotFoundException)
                    {
                        country = rnb.Data["geonames"][0]["countryName"];
                    }
                  
                    string county = string.Empty; 
                    string name = string.Empty;
                    try
                    {
                        name = rnb.Data["geonames"][0]["name"];
                    }
                    catch (System.Collections.Generic.KeyNotFoundException)
                    {
                        //nothing to do here
                    }
                    catch (ArgumentOutOfRangeException)
                    {
                        //nothing to do here
                    }
                    try
                    {
                        county = csb.Data["adminName1"];
                    }
                    catch (System.Collections.Generic.KeyNotFoundException)
                    {
                        //nothing to do here
                    }
                    catch (ArgumentOutOfRangeException)
                    {
                        //nothing to do here
                    }

                    Connection.Execute("UPDATE TOP_Results SET Country=@c, Region=@r,MountName=@n WHERE ZoneID=@zid and ParentID=@pid", new { r = county, c = country, n = name, zid = r.ZoneID, pid = r.ParentID });
                    Console.WriteLine($"{name} {country} {county}");
                }
                catch (System.Collections.Generic.KeyNotFoundException ex)
                {
                    string errorMessage = string.Empty;
                    if (rnb != null && !string.IsNullOrEmpty(rnb.Content)) errorMessage += rnb.Content;
                    if (csb != null && !string.IsNullOrEmpty(csb.Content)) errorMessage += csb.Content;
                    Console.WriteLine("Request was throttled by server:"+errorMessage+" timeout 300 second.");
                    Thread.Sleep(300000);
                }
                    //there ia a throttling limit - 2000 request per hour
                    //so, we have to set timeout not to be throttled
                    Thread.Sleep(3800);
            }
        }
    }
}
