http://sqlmag.com/sql-server/memory-myths


-- Note: querying sys.dm_os_buffer_descriptors
-- requires the VIEW_SERVER_STATE permission.

DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
   FROM sys.dm_os_performance_counters 
   WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
   AND counter_name = 'Total Pages';

;WITH src AS
(
   SELECT 
       database_id, db_buffer_pages = COUNT_BIG(*)
       FROM sys.dm_os_buffer_descriptors
       --WHERE database_id BETWEEN 5 AND 32766
       GROUP BY database_id
)
SELECT
   [db_name] = CASE [database_id] WHEN 32767 
       THEN 'Resource DB' 
       ELSE DB_NAME([database_id]) END,
   db_buffer_pages,
   db_buffer_MB = db_buffer_pages / 128,
   db_buffer_percent = CONVERT(DECIMAL(6,3), 
       db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;

--DBCC DROPCLEANBUFFERS



-----------------



SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [counter_name] = 'Connection Memory (KB)'
- See more at: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-6-memory-metrics/#sthash.JYJ9oYx2.dpuf

SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [counter_name] = 'User Connections'
- See more at: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-6-memory-metrics/#sthash.JYJ9oYx2.dpuf

SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [counter_name] = 'Stolen Server Memory (KB)'
- See more at: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-6-memory-metrics/#sthash.JYJ9oYx2.dpuf

SELECT object_name, counter_name, cntr_value
FROM sys.dm_os_performance_counters
WHERE [counter_name] in ('Lock Blocks', 'Lock Blocks Allocated', 'Lock Memory (KB)', 'Lock Owner Blocks')
- See more at: http://www.sqlshack.com/sql-server-memory-performance-metrics-part-6-memory-metrics/#sthash.JYJ9oYx2.dpuf

select 
	type,
	sum(virtual_memory_reserved_kb) as [VM Reserved],
	sum(virtual_memory_committed_kb) as [VM Committed],
	sum(awe_allocated_kb) as [AWE Allocated],
	sum(shared_memory_reserved_kb) as [SM Reserved], 
	sum(shared_memory_committed_kb) as [SM Committed]
	--sum(multi_pages_kb) as [MultiPage Allocator],
	--sum(single_pages_kb) as [SinlgePage Allocator]
from sys.dm_os_memory_clerks 
group by type
order by 8 desc

--------------------------------

SELECT TOP 25 obj.[name], i.[name], i.[type_desc], count(*)AS Buffered_Page_Count , count(*) * 8192 / (1024 * 1024) as Buffer_MB -- ,obj.name ,obj.index_id, i.[name] 
FROM sys.dm_os_buffer_descriptors AS bd INNER JOIN ( SELECT object_name(object_id) AS name ,index_id ,allocation_unit_id, object_id FROM sys.allocation_units AS au INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id AND (au.type = 1 OR au.type = 3) UNION ALL SELECT object_name(object_id) AS name ,index_id, allocation_unit_id, object_id FROM sys.allocation_units AS au INNER JOIN sys.partitions AS p ON au.container_id = p.hobt_id AND au.type = 2 ) AS obj ON bd.allocation_unit_id = obj.allocation_unit_id LEFT JOIN sys.indexes i on i.object_id = obj.object_id AND i.index_id = obj.index_id WHERE database_id = db_id() GROUP BY obj.name, obj.index_id , i.[name],i.[type_desc] ORDER BY Buffered_Page_Count DESC 


- See more at: http://www.sqlteam.com/article/what-data-is-in-sql-server-memory#sthash.1p4idPvK.dpuf



--- http://www.mssqltips.com/sqlservertip/2393/determine-sql-server-memory-use-by-database-and-object/

