-- ================================================================
-- Checking 'silver.crm_cust_info'
-- ================================================================

-- Check for NULLs or Duplicates in Primary Key
select 
    cst_id,
    count(*) 
from silver.crm_cust_info
group by cst_id
having(*) > 1 or cst_id is null;

-- Check for Unwanted Spaces
select
    cst_key 
from silver.crm_cust_info
where cst_key != trim(cst_key);

-- And also for cst_firstname, cst_lastname 
select
    cst_firstname 
from silver.crm_cust_info
where cst_firstname != trim(cst_lastname);

select
    cst_firstname 
from silver.crm_cust_info
where cst_firstname != trim(cst_lastname);

-- Data Standardization & Consistency
select distinct 
    cst_material_status 
from silver.crm_cust_info;

select distinct 
    cst_gndr
from silver.crm_cust_info;


-- ================================================================
-- Checking 'silver.crm_prd_info'
-- ================================================================

-- Check for NULLs or Duplicates in Primary Key
select 
    prd_id,
    count(*) 
from silver.crm_prd_info
group by prd_id
having count(*) > 1 or prd_id IS NULL;

-- Check for Unwanted Spaces
select 
    prd_nm 
from silver.crm_prd_info
where prd_nm != trim(prd_nm);

-- Check for NULLs or Negative Values in Cost
select 
    prd_cost 
from silver.crm_prd_info
where prd_cost < 0 or prd_cost IS NULL;

-- Data Standardization & Consistency
select distinct 
    prd_line 
from silver.crm_prd_info;

-- Check for Invalid Date orders (Start Date > End Date)
select 
    * 
from silver.crm_prd_info
where prd_end_dt < prd_start_dt;


-- ================================================================
-- Checking 'silver.crm_sales_details'
-- ================================================================

-- Check for Product Key who not present in Product Table
-- Expecting: No Result
select * from silver.crm_sales_details
where sls_ord_key not in (select prd_key from silver.crm_prd_info);

-- Check for Customer key who not present in Customer Table
-- Expecting: No Result
select * from silver.crm_sales_details
where sls_cust_id not in (select cst_id from silver.crm_cust_info);

-- Check for Invalid Date orders (order Date > Shipping/Due Dates)
select 
    * 
from silver.crm_sales_details
where sls_order_dt > sls_ship_dt 
   or sls_order_dt > sls_due_dt;

-- Check Data Consistency: Sales = Quantity * Price
select distinct 
    sls_sales,
    sls_quantity,
    sls_price 
from silver.crm_sales_details
where sls_sales != sls_quantity * sls_price
   or sls_sales IS NULL 
   or sls_quantity IS NULL 
   or sls_price IS NULL
   or sls_sales <= 0 
   or sls_quantity <= 0 
   or sls_price <= 0
order by sls_sales, sls_quantity, sls_price;


-- ================================================================
-- Checking 'silver.erp_cust_az12'
-- ================================================================

-- Check for Duplicate Primery Key
-- Expecting: No Result
select
  cid,
  count(*)
from silver.erp_cust_az12
group by cid
having count(*) > 1;
  
-- Check Out-of-Range Dates
select distinct 
    bdate 
from silver.erp_cust_az12
where bdate < '1924-01-01' 
   or bdate > GETDATE();

-- Data Standardization & Consistency
select distinct 
    gen 
from silver.erp_cust_az12;


-- ================================================================
-- Checking 'silver.erp_loc_a101'
-- ================================================================

-- Check for Duplicate Primary Key
-- Expecting: No Result
select
cid,
count(*) 
from silver.erp_loc_a101
group by cid
having count(*) > 1;

-- Data Standardization & Consistency
select distinct 
    cntry 
from silver.erp_loc_a101
order by cntry;

-- ================================================================
-- Checking 'silver.erp_px_cat_g1v2'
-- ================================================================

-- Check for Duplicate Primary Key
-- Expecting: No Results
select id, count(*)
from silver.erp_px_cat_g1v2
group by id 
having count(*) >1;

-- Check for Unwanted Spaces
-- Expecting: No Results
select 
    * 
from silver.erp_px_cat_g1v2
where cat != trim(cat) 
   or subcat != trim(subcat) 
   or maintenance != trim(maintenance);

-- Data Standardization & Consistency
select distinct 
    maintenance 
from silver.erp_px_cat_g1v2;
