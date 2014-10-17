----
http://stackoverflow.com/questions/771248/size-of-a-single-record-sql

dbcc showcontig ('TableName') with tableresults

http://technet.microsoft.com/en-us/library/aa933068(v=sql.80).aspx


-- use msc_results
-- exec dbo.available_tablerowsize2 @tablename='property_indexes'

alter procedure available_tablerowsize2
(
-- Add the parameters for the function here
@tablename varchar(50)
)
-- RETURNS int
AS
BEGIN
-- variables to track fixed and variable column sizes   
DECLARE @num_columns int
DECLARE @result int
DECLARE @num_fixed_columns int
DECLARE @fixed_data_size int
DECLARE @var_data_size int
DECLARE @num_var_columns int
DECLARE @max_var_size int
DECLARE @null_bitmap_size int
DECLARE @row_size int

-- Find the total number of columns
select @num_columns = count(*)
from syscolumns,systypes 
where syscolumns.id=object_id(@tablename) 
and syscolumns.xtype=systypes.xtype 


-- Find the size occupied by fixed length columns (Note: not possible to exist outside the 8060 bytes limit)
select @num_fixed_columns = count(*)
from syscolumns,systypes 
where syscolumns.id=object_id(@tablename) 
and syscolumns.xtype=systypes.xtype and systypes.variable=0

select sum(syscolumns.length) 
from syscolumns,systypes 
where syscolumns.id=object_id('property_indexes_short2') 
and syscolumns.xtype=systypes.xtype and systypes.variable=0

-- Find the size occupied by variable length columns within the 8060 page size limit 

-- number of variable length columns
select @num_var_columns=count(*)
from syscolumns, systypes
where syscolumns.id=object_id(@tablename) 
and syscolumns.xtype=systypes.xtype and systypes.variable=1
-- max size of all variable length columns
select @max_var_size =max(syscolumns.length) 
from syscolumns,systypes 
where syscolumns.id=object_id(@tablename) 
and syscolumns.xtype=systypes.xtype and systypes.variable=1
-- calculate variable length storage
begin
if @num_var_columns>0
set @var_data_size=2+(@num_var_columns*2)+@max_var_size
--set @var_data_size = @num_var_columns*24
else
set @var_data_size=0
end

-- If there are fixed-length columns in the table, a portion of the row, known as the null bitmap, is reserved to manage column nullability.
select @null_bitmap_size = 2 + ((@num_columns+7)/8)

-- Calculate total rowsize
select @row_size = @fixed_data_size + @var_data_size + @null_bitmap_size + 4

PRINT @fixed_data_size 
PRINT @var_data_size 
PRINT @null_bitmap_size + 4

-- Return the available bytes in the row available for expansion
select @result = 8060 - @row_size 

PRINT @result


END
GO


select 8060.0 / 2798.0
select 2798.0 * 2

select (8060.0- 5596.0) / 8060.0 * 100

select 3 * 200 * 0.3

select 8060.0 / select (110+8)*28
select (8060.0- 110 * 73) / 8060.0 * 100

select 22 * 28

select 2015 - 1987