USE [master]
GO
/****** Object:  Database [SRT]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE DATABASE [SRT]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SRT', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SRT.mdf' , SIZE = 18620416KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB ), 
 FILEGROUP [MEMORY] CONTAINS MEMORY_OPTIMIZED_DATA  DEFAULT
( NAME = N'fg_memory', FILENAME = N'c:\Temp\fg_memtest' , MAXSIZE = UNLIMITED)
 LOG ON 
( NAME = N'SRT_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\SRT_log.ldf' , SIZE = 41689088KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
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
ALTER DATABASE [SRT] SET RECOVERY FULL 
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
ALTER DATABASE [SRT] SET DELAYED_DURABILITY = DISABLED 
GO
EXEC sys.sp_db_vardecimal_storage_format N'SRT', N'ON'
GO
ALTER DATABASE [SRT] SET QUERY_STORE = OFF
GO
USE [SRT]
GO
ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO
ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO
ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
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
/****** Object:  Table [dbo].[Results]    Script Date: 2/28/2017 3:18:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Results](
	[Lat] [float] NOT NULL,
	[Lng] [float] NOT NULL,
	[Row] [int] NOT NULL,
	[Col] [int] NOT NULL,
	[Elevation] [int] NOT NULL,
	[Level] [int] NOT NULL,
	[ParentID] [int] NOT NULL,
	[ID] [int] IDENTITY(1,1) NOT NULL,
 CONSTRAINT [PK_Results] PRIMARY KEY NONCLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Index [IX_Results]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE CLUSTERED INDEX [IX_Results] ON [dbo].[Results]
(
	[ParentID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  View [dbo].[max_drops]    Script Date: 2/28/2017 3:18:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[max_drops]
as
select (max(Elevation)-min(Elevation)) as VertDrop,ParentID, max(level) as Segments from Results group by parentID --order by AltDrop desc



GO
/****** Object:  Table [dbo].[Candidates]    Script Date: 2/28/2017 3:18:17 PM ******/
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
 CONSTRAINT [PK_Candidates] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
/****** Object:  Table [dbo].[Points]    Script Date: 2/28/2017 3:18:17 PM ******/
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
/****** Object:  View [dbo].[slope_info]    Script Date: 2/28/2017 3:18:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE view [dbo].[slope_info]
AS
with chains (id,id1,id2,level,parentID,alt)
AS
(
select c1.id,c1.id1,c1.id2,0 as level,c1.id as parentID, c1.alt1 as alt from candidates c1 where not exists (select * from  candidates c2 where c2.id2=c1.id1) and exists(select * from  candidates c2 where c2.id1=c1.id2)
UNION ALL
select c1.id,c1.id1,c1.id2, level+1 as level,c2.id as parentID,c1.alt2 as alt from candidates c1 join chains c2 on c1.id1=c2.id2
)
select distinct p.*,level,ParentID  from chains c1 join candidates c2 on c1.id=c2.id
join Points p on p.ID=c2.id1 or p.id=c2.id2
--where parentID=3005

GO
/****** Object:  Table [dbo].[SrtMetaInfo]    Script Date: 2/28/2017 3:18:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SrtMetaInfo](
	[Cols] [int] NOT NULL,
	[Rows] [int] NOT NULL,
	[XLeft] [decimal](18, 16) NOT NULL,
	[YBottom] [decimal](18, 16) NOT NULL,
	[Cellsize] [decimal](18, 16) NOT NULL,
	[CellsizeInMeters] [decimal](18, 16) NOT NULL
) ON [PRIMARY]

GO
/****** Object:  Index [IX_id1]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_id1] ON [dbo].[Candidates]
(
	[id1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id2]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_id2] ON [dbo].[Candidates]
(
	[id2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_alt]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_alt] ON [dbo].[Points]
(
	[Elevation] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_col]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_col] ON [dbo].[Points]
(
	[Col] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_cover]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_cover] ON [dbo].[Points]
(
	[Elevation] ASC,
	[Row] ASC,
	[Col] ASC,
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_id]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_id] ON [dbo].[Points]
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_row]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_row] ON [dbo].[Points]
(
	[Row] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Alt]    Script Date: 2/28/2017 3:18:17 PM ******/
CREATE NONCLUSTERED INDEX [IX_Alt] ON [dbo].[Results]
(
	[Elevation] DESC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[preprocess]    Script Date: 2/28/2017 3:18:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC [dbo].[preprocess]
	@delta int=30
AS
declare @cols int
select @cols= MAX(col)-1 from points
print 'Truncationg candidates table'
truncate table candidates
print 'Filling candidates table'
insert into candidates (row1,col1,alt1,id1,row2,col2,alt2,id2) 
select distinct p1.[Row] as row1,p1.[Col] as col1,p1.[Elevation] as alt1,p1.id as id1,p2.[Row] as row2,p2.[Col] as col2,p2.[Elevation] as alt2,p2.id as id2 
from 
 Points  p1 join Points p2 
 on (p2.id in (p1.id-@cols-2,p1.id-@cols-1,p1.id-@cols,p1.id-1,p1.id+1,p1.id+@cols ,p1.id+@cols+1,p1.id+@cols+2)) 
WHERE  p1.Elevation-p2.Elevation>@delta and abs(p2.col-p1.col)<2 and abs(p2.row-p1.row)<2
print 'Truncationg results table'
truncate table results
print 'Filling results table'
insert into Results (Lat,Lng, Row,Col, Elevation,level,ParentID)  SELECT distinct Lat,Lng, Row,Col, Elevation,level,ParentID from slope_info
print 'Well done'

select * from results order by level desc

GO
/****** Object:  StoredProcedure [dbo].[store_srt_meta_info]    Script Date: 2/28/2017 3:18:17 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE proc [dbo].[store_srt_meta_info]
	 @Cols int
    ,@Rows int
    ,@XLeft decimal(18,8) 
    ,@YBottom decimal(18,8)
    ,@Cellsize decimal(18,8)
    ,@CellsizeInMeters decimal(18,8)
		   as
truncate table [SrtMetaInfo]
INSERT INTO [dbo].[SrtMetaInfo]
           ([Cols]
           ,[Rows]
           ,[XLeft]
           ,[YBottom]
           ,[Cellsize]
           ,[CellsizeInMeters])
     VALUES
	 (@Cols
           ,@Rows
           ,@XLeft
           ,@YBottom
           ,@Cellsize
           ,@CellsizeInMeters)



GO
USE [master]
GO
ALTER DATABASE [SRT] SET  READ_WRITE 
GO
