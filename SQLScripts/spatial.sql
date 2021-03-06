/*    ==Scripting Parameters==

    Source Server Version : SQL Server 2016 (13.0.1601)
    Source Database Engine Edition : Microsoft SQL Server Enterprise Edition
    Source Database Engine Type : Standalone SQL Server

    Target Server Version : SQL Server 2017
    Target Database Engine Edition : Microsoft SQL Server Standard Edition
    Target Database Engine Type : Standalone SQL Server
*/
USE [master]
GO
/****** Object:  Database [SRT]    Script Date: 11/1/2017 11:52:33 AM ******/
CREATE DATABASE [SRT]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SRT', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SRT.mdf' , SIZE = 247936KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [MEMORY] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( NAME = N'fg_memory', FILENAME = N'c:\Temp\fg_memtest' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'SRT_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SRT_log.ldf' , SIZE = 7806976KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO
ALTER DATABASE [SRT] SET COMPATIBILITY_LEVEL = 130
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SRT].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [SRT] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SRT] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SRT] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SRT] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SRT] SET ARITHABORT OFF 
GO
ALTER DATABASE [SRT] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SRT] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SRT] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SRT] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SRT] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SRT] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SRT] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SRT] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SRT] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SRT] SET  DISABLE_BROKER 
GO
ALTER DATABASE [SRT] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SRT] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SRT] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SRT] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SRT] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SRT] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SRT] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [SRT] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [SRT] SET  MULTI_USER 
GO
ALTER DATABASE [SRT] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SRT] SET DB_CHAINING OFF 
GO
ALTER DATABASE [SRT] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [SRT] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [SRT] SET DELAYED_DURABILITY = ALLOWED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'SRT', N'ON'
GO
ALTER DATABASE [SRT] SET QUERY_STORE = OFF
GO
USE [SRT]
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO
USE [SRT]
GO
/****** Object:  Table [dbo].[Zones]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Zones](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](500) NULL,
	[lat] [float] NULL,
	[lng1] [float] NULL,
	[lat2] [float] NULL,
	[lng2] [float] NULL,
 CONSTRAINT [PK_Zones] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Results]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Results](
	[Lat] [float] NULL,
	[Lng] [float] NULL,
	[ZoneID] [int] NULL,
	[Elevation] [int] NULL,
	[ParentID] [int] NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Results] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_top_results]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[vw_top_results]
AS
SELECT MAX(r.Elevation) AS summit, MAX(r.Elevation)-MIN(r.Elevation) AS delta,r.ParentID,z.ID,z.Name, r2.Lat,r2.lng FROM dbo.Results r 
JOIN zones z ON r.ZoneID=z.ID
JOIN dbo.Results r2 ON r2.ParentID=r.ParentID AND r2.ZoneID=r.ZoneID 

GROUP BY r.ParentID,z.ID,z.Name,r2.Lat,r2.lng, r2.Elevation
HAVING MAX(r.Elevation)-MIN(r.Elevation)>500 AND r2.Elevation=MAX(r.Elevation)
--ORDER BY delta DESC

GO
/****** Object:  Table [dbo].[top_results]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[top_results](
	[ZoneID] [int] NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Lat] [float] NOT NULL,
	[Lng] [float] NOT NULL,
	[VertDrop] [int] NOT NULL,
	[Summit] [int] NOT NULL,
	[ParentID] [int] NOT NULL,
	[Segments] [int] NULL,
	[Country] [nvarchar](250) NULL,
	[Region] [nvarchar](250) NULL,
	[MountName] [nvarchar](250) NULL,
	[ResultID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_top_results] PRIMARY KEY CLUSTERED 
(
	[ResultID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[vw_top_results2]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[vw_top_results2]
AS
SELECT  t1.MountName,t1.VertDrop ,t1.Summit,t1.Country,t1.Region,t1.Lat,t1.Lng,t1.ZoneID,t1.Segments,t1.ParentID FROM top_results t1
WHERE t1.resultID = (
SELECT TOP 1 resultID FROM  dbo.top_results t2 WHERE t1.ZoneID=t2.ZoneID AND t1.MountName=t2.MountName AND t1.Country=t2.Country 
AND t1.Region=t2.Region 
ORDER BY t2.VertDrop DESC
)
AND ISNULL(t1.Region,'')<>'' AND t1.VertDrop>=300
--ORDER BY t1.Country,t1.Region,VertDrop DESC

GO
/****** Object:  Table [dbo].[chunks]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[chunks](
	[id1] [int] NOT NULL,
	[id2] [int] NOT NULL,
	[parentID] [int] NOT NULL,
	[alt] [int] NOT NULL,
	[level] [int] NOT NULL,
	[chunkID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Temp] PRIMARY KEY NONCLUSTERED 
(
	[chunkID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ParentID]    Script Date: 11/1/2017 11:52:33 AM ******/
CREATE CLUSTERED INDEX [IX_ParentID] ON [dbo].[chunks]
(
	[parentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[max_drops]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[max_drops]
as
select (max(alt)-min(alt)) as VertDrop,ParentID, max(level) as Segments from chunks group by parentID --order by AltDrop desc


GO
/****** Object:  Table [dbo].[Candidates]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Candidates](
	[row1] [int] NOT NULL,
	[col1] [int] NOT NULL,
	[alt1] [int] NOT NULL,
	[id1] [int] NOT NULL,
	[row2] [int] NOT NULL,
	[col2] [int] NOT NULL,
	[alt2] [int] NOT NULL,
	[id2] [int] NOT NULL,
	[id] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Candidates] PRIMARY KEY NONCLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_id1]    Script Date: 11/1/2017 11:52:33 AM ******/
CREATE CLUSTERED INDEX [IX_id1] ON [dbo].[Candidates]
(
	[id1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Points]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Points](
	[Lat] [float] NOT NULL,
	[Lng] [float] NOT NULL,
	[Row] [int] NOT NULL,
	[Col] [int] NOT NULL,
	[Elevation] [int] NOT NULL,
	[ID] [int] NOT NULL,
 CONSTRAINT [PK_points2] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[slope_info]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[slope_info]
AS
WITH chains (id1,id2,level,parentID,alt)
AS
	(
		SELECT c1.id1,c1.id2,0 AS level,parentID,alt FROM dbo.Chunks c1 
		UNION ALL
		SELECT c1.id1,c1.id2, level+1 AS level,c2.ParentID AS parentID,c1.alt2 AS alt FROM candidates c1 JOIN chains c2 ON c1.id1=c2.id2
	)
		SELECT DISTINCT id1,id2,Lat,Lng, Row,Col, Elevation,level,ParentID FROM chains c1  
		JOIN Points p ON p.ID=c1.id2-- ORDER BY p.Elevation DESC
        
		
GO
/****** Object:  Table [dbo].[SrtMetaInfo]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SrtMetaInfo](
	[Cols] [int] NULL,
	[Rows] [int] NULL,
	[XLeft] [decimal](18, 12) NULL,
	[YBottom] [decimal](18, 12) NULL,
	[Cellsize] [decimal](18, 12) NULL,
	[CellsizeInMeters] [decimal](18, 12) NULL,
	[Name] [nvarchar](50) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[top_parents]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[top_parents](
	[Summit] [int] NOT NULL,
	[VertDrop] [int] NOT NULL,
	[ParentID] [int] NOT NULL,
	[ZoneID] [int] NOT NULL,
	[Name] [nvarchar](500) NOT NULL,
	[Lat] [float] NOT NULL,
	[Lng] [float] NOT NULL,
	[Segments] [nchar](10) NULL,
 CONSTRAINT [PK_top_parents] PRIMARY KEY CLUSTERED 
(
	[ParentID] ASC,
	[ZoneID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Index [IX_Candidates_id2]    Script Date: 11/1/2017 11:52:33 AM ******/
CREATE NONCLUSTERED INDEX [IX_Candidates_id2] ON [dbo].[Candidates]
(
	[id2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Cover]    Script Date: 11/1/2017 11:52:33 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cover] ON [dbo].[Candidates]
(
	[alt1] ASC,
	[id1] ASC,
	[id2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Level]    Script Date: 11/1/2017 11:52:33 AM ******/
CREATE NONCLUSTERED INDEX [IX_Level] ON [dbo].[chunks]
(
	[level] ASC
)
INCLUDE ( 	[id2],
	[parentID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_ZoneID]    Script Date: 11/1/2017 11:52:33 AM ******/
CREATE NONCLUSTERED INDEX [IX_ZoneID] ON [dbo].[top_parents]
(
	[ZoneID] ASC
)
INCLUDE ( 	[VertDrop],
	[Name],
	[Lat],
	[Lng]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[create_zone]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[create_zone]
	@Name NVARCHAR(50),
	@lat1 FLOAT NULL,
	@lng1 FLOAT NULL,
	@lat2 FLOAT NULL,
	@lng2 FLOAT NULL
AS
INSERT INTO [dbo].[Zones]
           ([Name]
           ,[lat]
           ,[lng1]
           ,[lat2]
           ,[lng2])
		   VALUES
		   (@Name
           ,@lat1
           ,@lng1
           ,@lat2
           ,@lng2)
SELECT SCOPE_IDENTITY()
GO
/****** Object:  StoredProcedure [dbo].[FILL_RESULTS_TABLE]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[FILL_RESULTS_TABLE]
@amount INT=5000,
@minDrop INT=300
AS
PRINT 'strated at: ' + CAST(GETDATE() AS NVARCHAR(max))
DECLARE @ZoneID int
INSERT INTO [dbo].[Zones]
           ([Name]
           ,[lat]
           ,[lng1]
           ,[lat2]
           ,[lng2])
SELECT
name, XLeft,YBottom,XLeft+Cols*Cellsize, YBottom+Rows*Cellsize
FROM dbo.SrtMetaInfo
SET @ZoneID=SCOPE_IDENTITY()

DECLARE CUR CURSOR FOR SELECT TOP (@amount) ParentID from max_drops where VertDrop>=@Mindrop  order by VertDrop DESC
DECLARE @ParentID INT
OPEN CUR
FETCH NEXT FROM CUR INTO @ParentID
WHILE @@FETCH_STATUS=0
BEGIN
 declare @l int, @id int
 select top 1 @l=level+1, @id=id2 from Chunks where ParentID=@parentID  order by alt asc;
	
 WITH res (id1,id2,level,parentID,alt,rt)
	AS
	(
	select top 1 id1,id2,level,parentID,alt,1 from Chunks where ParentID=@parentID  order by alt asc
	UNION ALL
	SELECT  c1.id1,c1.id2,c1.level,c1.parentID,c1.alt,cast(row_number() OVER (ORDER BY (SELECT 0)) as int)
	 FROM Chunks c1 INNER JOIN res c2 ON c1.id2=c2.id1 where  c1.level=c2.level -1 and c1.parentID=@parentID and c1.alt>c2.alt
	)
	INSERT INTO results (parentID,zoneID,lat,lng,elevation)
	SELECT @ParentID, @ZoneID,p.Lat,p.Lng, p.Elevation from points p where id in  
	(select top (@l) id1 from res   where rt=1)
	union
	select @ParentID, @ZoneID,Lat,Lng, Elevation from Points where id=@id

	FETCH NEXT FROM CUR INTO @ParentID

END

CLOSE CUR
DEALLOCATE CUR
PRINT 'finished at: ' + CAST(GETDATE() AS NVARCHAR(max))


GO
/****** Object:  StoredProcedure [dbo].[get_min_drop_by_percent]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create proc [dbo].[get_min_drop_by_percent]
@percent int=5
AS
select top 1 * from (select top (@percent) percent VertDrop from max_drops order by vertdrop desc) s 
 order by VertDrop asc
GO
/****** Object:  StoredProcedure [dbo].[get_slope_info]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[get_slope_info]
@parentID int
AS
 declare @l int, @id int
 select top 1 @l=level+1, @id=id2 from Chunks where ParentID=@parentID  order by alt asc;

 WITH res (id1,id2,level,parentID,alt,rt)
	AS
	(
	select top 1 id1,id2,level,parentID,alt,1 from Chunks where ParentID=@parentID  order by alt asc
	UNION ALL
	SELECT  c1.id1,c1.id2,c1.level,c1.parentID,c1.alt,cast(row_number() OVER (ORDER BY (SELECT 0)) as int)
	 FROM Chunks c1 INNER JOIN res c2 ON c1.id2=c2.id1 where  c1.level=c2.level -1 and c1.parentID=@parentID and c1.alt>c2.alt
	)

	SELECT   p.Lat,p.Lng, p.Row,p.Col, p.Elevation as alt,p.ID from points p where id in  
	(select top (@l) id1 from res   where rt=1)
	union
	select * from Points where id=@id

GO
/****** Object:  StoredProcedure [dbo].[get_slope_info_from_results]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[get_slope_info_from_results]
@parentID INT,
@ZoneID int
AS
SELECT   p.Lat,p.Lng, p.Elevation as alt,p.ID from dbo.Results p WHERE
 p.ZoneID=@ZoneID AND p.ParentID  = @parentID
 ORDER BY alt desc

GO
/****** Object:  StoredProcedure [dbo].[GET_TOP_RESULTS]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[GET_TOP_RESULTS]
@pecision INT=1,
@amount INT =5000,
@VertDrop INT = 300,
@Segments INT=2
AS
IF @amount IS NULL OR @amount=0 
SET @amount=1000000

TRUNCATE TABLE [top_parents]
INSERT INTO [dbo].[top_parents]
           ([summit]
           ,VertDrop
		   ,Segments
           ,[ParentID]
           ,[ZoneID]
           ,[Name]
           ,[Lat]
           ,[lng])

SELECT  MAX(r.Elevation) AS summit, MAX(r.Elevation)-MIN(r.Elevation) AS VertDrop,COUNT(*) AS segments,r.ParentID,z.ID,z.Name, r2.Lat,r2.lng
 FROM dbo.Results r 
JOIN zones z ON r.ZoneID=z.ID
JOIN dbo.Results r2 ON r2.ParentID=r.ParentID AND r2.ZoneID=r.ZoneID 

GROUP BY r.ParentID,z.ID,z.Name,r2.Lat,r2.lng, r2.Elevation
HAVING r2.Elevation=MAX(r.Elevation)
ORDER BY VertDrop DESC
--DECLARE @pecision INT=1, @amount INT =5000
TRUNCATE TABLE top_results
INSERT INTO TOP_RESULTS (zoneID,Name,Lat,Lng,VertDrop,Summit,ParentId,Segments)
SELECT TOP(@amount) p.ZoneID,p.Name,r.Lat,r.Lng,r.VertDrop,r.Summit,r.ParentID,r.Segments
 FROM [dbo].[top_parents] p 
 JOIN [top_parents] r on p.zoneID=r.ZoneID 
 AND ROUND(p.Lng,@pecision)=ROUND(r.Lng,@pecision) 
 AND ROUND(p.lat,@pecision)=ROUND(r.lat,@pecision)
 GROUP BY p.zoneID,p.Name,ROUND(p.lat,@pecision),ROUND(p.Lng,@pecision),r.parentID,r.VertDrop,r.lat,r.lng,r.summit, r.Segments
 HAVING r.VertDrop=MAX(p.VertDrop) AND r.VertDrop>@VertDrop AND r.Segments>@segments
ORDER BY r.VertDrop DESC
SELECT * FROM dbo.top_results
--SELECT TOP 100 * FROM vw_top_results2  ORDER BY VertDrop DESC 
GO
/****** Object:  StoredProcedure [dbo].[preprocess]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROC [dbo].[preprocess]
	@delta int=30
AS
declare @cols int
select @cols= MAX(col)-1 from points
print 'Truncating candidates table'
truncate table candidates
print 'Filling candidates table'
exec toggle_indexes_on_table @table='candidates',@enable=0
BEGIN TRAN
INSERT into candidates WITH(ROWLOCK) (row1,col1,alt1,id1,row2,col2,alt2,id2) 
select distinct p1.[Row] as row1,p1.[Col] as col1,p1.[Elevation] as alt1,p1.id as id1,p2.[Row] as row2,p2.[Col] as col2,p2.[Elevation] as alt2,p2.id as id2 
from 
 Points  p1 WITH(NOLOCK) join Points p2 WITH(NOLOCK) 
 on (p2.id in (p1.id-@cols-2,p1.id-@cols-1,p1.id-@cols,p1.id-1,p1.id+1,p1.id+@cols ,p1.id+@cols+1,p1.id+@cols+2)) 
WHERE  p1.Elevation-p2.Elevation>@delta and abs(p2.col-p1.col)<2 and abs(p2.row-p1.row)<2
COMMIT TRAN WITH(DELAYED_DURABILITY=ON)
exec toggle_indexes_on_table @table='candidates',@enable=1
PRINT 'truncating chunks table'
TRUNCATE TABLE Chunks
PRINT 'filling chunks table'

INSERT INTO Chunks(id1,id2,parentID,alt,level)
SELECT  c1.id1,c1.id2,c1.id1, c1.alt1 ,0
FROM candidates c1 WITH(NOLOCK)
 WHERE 
	NOT EXISTS (SELECT * FROM  candidates c2 WITH(NOLOCK) WHERE c2.id2=c1.id1) 
	AND EXISTS(SELECT * FROM  candidates c2 WITH(NOLOCK) WHERE c2.id1=c1.id2)

declare @level int, @rows int
select @level=max(level) from chunks
PRINT @level

--remove junk points and shrink the database to free up some space
DELETE FROM dbo.Points WHERE id NOT IN (SELECT id1 FROM dbo.Candidates UNION SELECT id2 FROM dbo.Candidates)
DBCC SHRINKDATABASE(N'SRT' )
DBCC SHRINKFILE (N'SRT_log' , 0, TRUNCATEONLY)
DBCC SHRINKFILE (N'SRT' , 0, TRUNCATEONLY)


WHILE 1=1
 BEGIN
 begin tran
 INSERT INTO [dbo].chunks
           ([id1]
           ,[id2]
           ,[parentID]
           ,[alt]
           ,[level])

	select distinct   c.[id1],c.[id2],t.[parentID],c.[alt1],t.[level]+1 from chunks t join Candidates c on c.id1=t.id2
	where  t.level=@level and not exists (select id1 from chunks tt where tt.id1=c.id1 and tt.id2=c.id2 and tt.level=t.level+1 and tt.parentID=t.parentID)
 set @rows=@@rowcount
 commit tran

 print @rows
 print @level
 SET @level=@level+1
 if @rows=0 break 
 else continue
 end



GO
/****** Object:  StoredProcedure [dbo].[store_result]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[store_result]
@Lat FLOAT,
@Lng FLOAT,
@ZoneID INT,
@ParentID INT,
@Alt int
AS

INSERT INTO [dbo].[Results]
           ([Lat]
           ,[Lng]
           ,[ZoneID]
           ,[Elevation]
           ,[ParentID])
     VALUES
           (@Lat,@Lng,@ZoneID,@Alt,@ParentID)
GO
/****** Object:  StoredProcedure [dbo].[store_srt_meta_info]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[store_srt_meta_info]
	 @Cols int
    ,@Rows int
    ,@XLeft decimal(18,12) 
    ,@YBottom decimal(18,12)
    ,@Cellsize decimal(18,12)
    ,@CellsizeInMeters decimal(18,12)
	,@Name NVARCHAR(500)
	
		   as
truncate table [SrtMetaInfo]
INSERT INTO [dbo].[SrtMetaInfo]
           ([Cols]
           ,[Rows]
           ,[XLeft]
           ,[YBottom]
           ,[Cellsize]
           ,[CellsizeInMeters]
		   ,[Name])
     VALUES
	 (@Cols
           ,@Rows
           ,@XLeft
           ,@YBottom
           ,@Cellsize
           ,@CellsizeInMeters
		   ,@Name)


GO
/****** Object:  StoredProcedure [dbo].[toggle_indexes_on_table]    Script Date: 11/1/2017 11:52:33 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[toggle_indexes_on_table]
@enable bit=1,
@Table sysname = 'Points'

AS
-- Set the name of the schema and table here
DECLARE @Schema sysname
SET @Schema = 'dbo'
declare @sql nvarchar(max)
-- Get the non-clustered indexes
select @sql='ALTER INDEX ' + I.name + ' ON ' + T.name + 
case 
when @enable=1 then ' REBUILD'
else ' DISABLE' 
end
from sys.indexes I
inner join sys.tables T on I.object_id = T.object_id
where I.type_desc = 'NONCLUSTERED'
and I.name is not null and t.name=@Table

execute(@sql)
GO
USE [master]
GO
ALTER DATABASE [SRT] SET  READ_WRITE 
GO
