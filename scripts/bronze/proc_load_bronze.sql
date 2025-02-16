-- BULK INSERT

-- CRM ==========================================

create or alter procedure bronze.load_bronze as
begin
declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
begin try
set @batch_end_time = getdate();
print '=========================================='
print 'loding Bronze Layer'
print '=========================================='

print '------------------------------------------'
print 'Loading CRM Tables'
print '------------------------------------------'

-- FIRST 
set @start_time = getdate();
truncate table bronze.crm_cust_info;
bulk insert bronze.crm_cust_info
from 'C:\Users\AC\Documents\Data Sets\SQL_Data_Warehouse\source_crm\cust_info.csv'
with (
     firstrow = 2,
	 fieldterminator = ',',
	 tablock
);

set @end_time = getdate();
print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';



-- SECOND
set @start_time = getdate();
truncate table bronze.crm_prd_info;
bulk insert bronze.crm_prd_info
from 'C:\Users\AC\Documents\Data Sets\SQL_Data_Warehouse\source_crm\prd_info.csv'
with (
     firstrow = 2,
	 fieldterminator = ',',
	 tablock
);
set @end_time = getdate();
print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';



-- THIRD
set @start_time = getdate();
truncate table bronze.crm_sales_details;

print '>> Insert Data Into: bronze.crm_cust'
bulk insert bronze.crm_sales_details
from 'C:\Users\AC\Documents\Data Sets\SQL_Data_Warehouse\source_crm\sales_details.csv'
with (
     firstrow = 2,
	 fieldterminator = ',',
	 tablock
);

set @end_time = getdate();
print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';



-- ERP =====================================
print '------------------------------------------'
print 'Loading ERP Tables'
print '------------------------------------------'


-- FIRST
set @start_time = getdate();
truncate table bronze.erp_cust_az12;
bulk insert bronze.erp_cust_az12
from 'C:\Users\AC\Documents\Data Sets\SQL_Data_Warehouse\source_erp\cust_az12.csv'
with (
     firstrow = 2,
	 fieldterminator = ',',
	 tablock
);
set @end_time = getdate();
print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';




-- SECOND
set @start_time = getdate();
truncate table bronze.erp_loc_a101;
bulk insert bronze.erp_loc_a101
from 'C:\Users\AC\Documents\Data Sets\SQL_Data_Warehouse\source_erp\loc_a101.csv'
with (
     firstrow = 2,
	 fieldterminator = ',',
	 tablock
);

set @end_time = getdate();
print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

-- THIRD
set @start_time = getdate();
truncate table bronze.erp_px_cat_g1v2;
bulk insert bronze.erp_px_cat_g1v2
from 'C:\Users\AC\Documents\Data Sets\SQL_Data_Warehouse\source_erp\px_cat_g1v2.csv'
with (
     firstrow = 2,
	 fieldterminator = ',',
	 tablock
);
set @end_time = getdate();
print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

set @batch_end_time = getdate();
print '========================================='
print 'Loading Bronze Layer is Completed';
print ' - Total Load Duration: ' + cast(datediff(second, @batch_start_time, @batch_end_time) as nvarchar) + 'seconds';
print '========================================='
end try
begin catch
print '========================================='
print 'ERROR OCCURED DURING LODING BRONZE LAYER'
print 'Error Message' + cast (ERROR_NUMBER() as nvarchar);
print 'Error Massage' + cast (ERROR_STATE() as nvarchar);
print '========================================='
end catch
end

