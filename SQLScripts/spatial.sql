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
/****** Object:  Index [IX_id1]    Script Date: 10/4/2017 10:44:23 AM ******/
CREATE CLUSTERED INDEX [IX_id1] ON [dbo].[Candidates]
(
	[id1] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[chunks]    Script Date: 10/4/2017 10:44:23 AM ******/
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
 CONSTRAINT [PK_Temp] PRIMARY KEY CLUSTERED 
(
	[chunkID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Points]    Script Date: 10/4/2017 10:44:23 AM ******/
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
/****** Object:  Table [dbo].[SrtMetaInfo]    Script Date: 10/4/2017 10:44:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SrtMetaInfo](
	[Cols] [int] NOT NULL,
	[Rows] [int] NOT NULL,
	[XLeft] [decimal](18, 12) NOT NULL,
	[YBottom] [decimal](18, 12) NOT NULL,
	[Cellsize] [decimal](18, 12) NOT NULL,
	[CellsizeInMeters] [decimal](18, 12) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[max_drops]    Script Date: 10/4/2017 10:44:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE view [dbo].[max_drops]
as
select (max(alt)-min(alt)) as VertDrop,ParentID, max(level) as Segments from chunks group by parentID --order by AltDrop desc


GO
/****** Object:  View [dbo].[slope_info]    Script Date: 10/4/2017 10:44:23 AM ******/
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
/****** Object:  Index [IX_Candidates_id2]    Script Date: 10/4/2017 10:44:23 AM ******/
CREATE NONCLUSTERED INDEX [IX_Candidates_id2] ON [dbo].[Candidates]
(
	[id2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Cover]    Script Date: 10/4/2017 10:44:23 AM ******/
CREATE UNIQUE NONCLUSTERED INDEX [IX_Cover] ON [dbo].[Candidates]
(
	[alt1] ASC,
	[id1] ASC,
	[id2] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [IX_Level]    Script Date: 10/4/2017 10:44:23 AM ******/
CREATE NONCLUSTERED INDEX [IX_Level] ON [dbo].[chunks]
(
	[level] ASC
)
INCLUDE ( 	[id2],
	[parentID]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  Index [ix_parent]    Script Date: 10/4/2017 10:44:23 AM ******/
CREATE NONCLUSTERED INDEX [ix_parent] ON [dbo].[chunks]
(
	[parentID] ASC
)
INCLUDE ( 	[id1],
	[alt],
	[level]) WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
GO
/****** Object:  StoredProcedure [dbo].[get_min_drop_by_percent]    Script Date: 10/4/2017 10:44:23 AM ******/
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
/****** Object:  StoredProcedure [dbo].[get_slope_info]    Script Date: 10/4/2017 10:44:23 AM ******/
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
/****** Object:  StoredProcedure [dbo].[preprocess]    Script Date: 10/4/2017 10:44:23 AM ******/
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

while 1=1
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
/****** Object:  StoredProcedure [dbo].[store_srt_meta_info]    Script Date: 10/4/2017 10:44:23 AM ******/
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
/****** Object:  StoredProcedure [dbo].[toggle_indexes_on_table]    Script Date: 10/4/2017 10:44:23 AM ******/
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
