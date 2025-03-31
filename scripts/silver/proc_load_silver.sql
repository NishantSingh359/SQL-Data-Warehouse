
-- ==================== LOAD DATA BRONZE TO SILVER ====================

-- EXECUTE PROCEDURE ======
EXEC silver.load_silver

-- ============== CREATE PROCEDURE ==============

create or alter procedure  silver.load_silver AS
begin
    declare @start_time datetime, @end_time datetime, @batch_start_time datetime, @batch_end_time datetime;
	begin try
	    set @batch_start_time = getdate();
		print '=============================================';
		print 'Loading Silver Layer';
		print '=============================================';

		print '---------------------------------------------';
		print 'Loading CRM Tables';
		print '---------------------------------------------';

		-- ====================== LOAD CRM TABLES ======================

		-- crm_cust_info ===================================
		set @start_time = getdate();

		print '>> TRUNCATE silver.crm_cust_info TABLE';
		TRUNCATE TABLE silver.crm_cust_info;
		print '>> INSERTING DATE INTO silver.crm_cust_info TABLE';

		insert into silver.crm_cust_info(
		cst_id,
		cst_key,
		cst_firstname,
		cst_lastname,
		cst_marital_status,
		cst_gndr,
		cst_create_date)

		select 
		cst_id,
		cst_key,
		trim(cst_firstname) as cst_firstname ,
		trim(cst_lastname) as cst_lastname,

		case when upper(trim(cst_marital_status)) = 'S' then 'Single'
			 when upper(trim(cst_marital_status)) = 'M' then 'Married'
			 else 'n/a'
		end cst_material_status,

		case when upper(trim(cst_gndr)) = 'F' then 'Female'
			 when upper(trim(cst_gndr)) = 'M' then 'Male'
			 else 'n/a'
		end cst_gndr,
		cst_create_date from (
		select
		*,
		row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
		from bronze.crm_cust_info
		where cst_id is not null
		)t where flag_last = 1;

		set @end_time = getdate();  
		print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

		print '>> ---------------';

		-- crm_prd_info ====================================

		set @start_time = getdate();

		print '>> TRUNCATE silver.crm_prd_info TABLE';
		truncate table silver.crm_prd_info;
		print '>> INSERTING DATE INTO silver.crm_prd_info TABLE';
		insert into silver.crm_prd_info(
		prd_id,
		cat_id,
		prd_key,
		prd_nm,
		prd_cost,
		prd_line,
		prd_start_dt,
		prd_end_dt
		)

		select 
		prd_id,
		replace(substring(prd_key, 1, 5),'-','_') as cat_id,
		substring(prd_key, 7, len(prd_key)) as prd_key,
		prd_nm,
		isnull(prd_cost,0) as prd_cost,
		case upper(trim(prd_line))
			 when 'M' then 'Mountain'
			 when 'R' then 'Road'
			 when 'S' then 'Other Sales'
			 when 'T' then 'Touring'
			 else 'n/a'
		end as prd_line,
		cast(prd_start_dt as date) as prd_start_dt,
		cast(lead(prd_start_dt) over (partition by prd_key order by prd_start_dt)-1 as date) as prd_end_dt
		from bronze.crm_prd_info;
		
		set @end_time = getdate();  
		print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

		print '>> ---------------';

		-- crm_sales_details ============================================

		set @start_time = getdate();

		print '>> TRUNCATE silver.crm_sales_details TABLE';
		truncate table silver.crm_sales_details;
		print '>> INSERTING DATE INTO silver.crm_sales_details TABLE';

		insert into silver.crm_sales_details (
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,
		sls_order_dt,
		sls_ship_dt,
		sls_due_dt,
		sls_sales,
		sls_quantity,
		sls_price
		)
		select 
		sls_ord_num,
		sls_prd_key,
		sls_cust_id,

		case when sls_order_dt = 0 or len(sls_order_dt) != 8 then null  -- invalid data
			 else cast(cast(sls_order_dt as varchar) as date)  -- data type casting
		end as sls_order_dt,

		case when sls_ship_dt = 0 or len(sls_ship_dt) != 8 then null
			 else cast(cast(sls_ship_dt as varchar) as date)
		end as sls_ship_dt,

		case when sls_due_dt = 0 or len(sls_due_dt) != 8 then null
			 else cast(cast(sls_due_dt as varchar) as date)
		end as sls_due_dt,

		case when sls_sales is null or sls_sales <=0 or sls_sales != sls_quantity * abs(sls_price)  -- handilling missing data
				 then sls_quantity * abs(sls_price)
			 else sls_sales
		end as sls_sales,
		sls_quantity,

		case when sls_price is null or sls_price <= 0    -- handilling missing data
			 then sls_sales / nullif(sls_quantity, 0)
			else  sls_price
		end as sls_price
		from bronze.crm_sales_details;

		set @end_time = getdate();  
		print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

		print '>> ---------------';

		print '---------------------------------------------';
		print 'Loading CRM Tables';
		print '---------------------------------------------';

		-- ====================== LOAD ERP TABLES ======================

		-- erp_cust_az12 ==========================================

		set @start_time = getdate();

		print '>> TRUNCATE silver.erp_cust_az12 TABLE';
		truncate table silver.erp_cust_az12; 
		print '>> INSERTING DATE INTO silver.erp_cust_az12 TABLE';

		insert into silver.erp_cust_az12 (
		cid,
		bdate,
		gen
		)
		select
		case when cid like 'NAS%' then substring(cid, 4, len(cid)) -- invalid values
			 else cid
		end cid,
		case when bdate > getdate() then null  -- invalid values
			 else bdate
		end bdate,
		case when upper(trim(gen)) in ('F', 'FEMALE') then 'Female'   -- data normalization
			when upper(trim(gen)) in ('M', 'MALE') then 'Male'
			else 'n/a' 
		end as gen
		from bronze.erp_cust_az12;

		set @end_time = getdate();  
		print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

		print '>> ---------------';

		-- erp_loc_a101 =============================================

		set @start_time = getdate();

		print '>> TRUNCATE silver.erp_loc_a101 TABLE';
		truncate table silver.erp_loc_a101;
		print '>> INSERTING DATE INTO silver.erp_loc_a101 TABLE';

		insert into silver.erp_loc_a101 (
		cid,
		cntry
		)
		select 
		replace(cid,'-','') as cid, -- invalid_values
		case 
		   when upper(trim(cntry)) IN ('USA', 'US') then 'United States'  -- data normalization
		   when upper(trim(cntry)) = 'DE' then 'United States'
		   when upper(trim(cntry)) = 'NULL' then 'n/a'
		   when upper(trim(cntry))= '' then 'n/a'
		   else cntry
		end as cntry
		from bronze.erp_loc_a101

		set @end_time = getdate();  
		print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

		print '>> ---------------';

		-- erp_px_cat_g1v2 ==========================================

		set @start_time = getdate();

		print '>> TRUNCATE silver.erp_px_cat_g1v2 TABLE';
		truncate table silver.erp_px_cat_g1v2;
		print '>> INSERTING DATE INTO silver.erp_px_cat_g1v2 TABLE';

		insert into silver.erp_px_cat_g1v2 (
		id,
		cat,
		subcat,
		maintenance
		)
		select 
		id,
		cat,
		subcat,
		maintenance
		from bronze.erp_px_cat_g1v2;

		set @end_time = getdate();  
		print '>> Load Duration: ' + cast(datediff(second, @start_time, @end_time) as nvarchar(50)) + 'seconds';

		print '>> ---------------';

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
