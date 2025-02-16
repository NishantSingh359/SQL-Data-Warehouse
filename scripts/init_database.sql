-- Create Database 'DataWarehouse' 
use master;
go
if exists (select 1 from sys.databases where name = "DataWarehouse")
Begin
    alter database DataWarehouse  set single_user with rollback immdiate;
	drop database datawarehouse;
end;
go 
-- create the 'DataWarehouse' database

create database DataWarehouse;
use DataWarehouse;
-- create schemas
create schema bronze;
go 
create schema silver;
go
create schema gold;
go
