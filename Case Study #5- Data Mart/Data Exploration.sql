/* 1.What day of the week is used for each week_date value? */
select dayname(week_date) as day
from clean_weekly_sales;

/*2. What range of week numbers are missing from the dataset? */
with week_no as (
	select distinct week_number
	from clean_weekly_sales
	order by week_number),
    
    t2 as (
	select *, lag(week_number, 1, 0) over() as lag_week,
	case
		when week_number != last_value(week_number) over() 
			and week_number-lag(week_number, 1, 0) over() = 1 then null
		when week_number != last_value(week_number) over() 
			and week_number-lag(week_number, 1, 0) over() != 1 then concat(lag(week_number, 1, 0) over(), "-", week_number)
		when week_number = last_value(week_number) over() 
			and  last_value(week_number) over() != 52 then concat(last_value(week_number) over(), "-", "52")
	end wk_range
	from week_no)
select wk_range
from t2
where wk_range is not null;

/* 3. How many total transactions were there for each year in the dataset */
select calendar_year, sum(transactions) as txn_total 
from clean_weekly_sales
group by calendar_year;

/*4. What is the total sales for each region for each month */
select region, month_number, sum(sales)
from clean_weekly_sales
group by region, month_number
order by region;

/* 5. What is the total count of transactions for each platform */
select platform, count(transactions) as txn_count
from clean_weekly_sales
group by platform;

/* 6. What is the percentage of sales for retail vs shopify for each month */
with sum_table as (
	select platform, month_number, sum(sales) as tot_sales_plat
	from clean_weekly_sales
	group by platform, month_number)
select *, concat(tot_sales_plat* 100/sum(tot_sales_plat) over(partition by month_number order by month_number), "%") as per_sales_month
from(
select *,
sum(tot_sales_plat) over(partition by month_number order by month_number) as tot_sales_month
from sum_table) x;

/*7. What is the percentage of sales by demographic for each year in the dataset */
with t2 as (
	select *, sum(sales) as tot_sales
	from clean_weekly_sales
	group by demographic, calendar_year),
    t3 as (
select *, sum(tot_sales) over(partition by calendar_year order by calendar_year) as total
from t2)
select calendar_year, demographic, concat(tot_sales/total, "%") as per_demo_sales
from t3;

/* 8.WHich age_band and demographic values contribute the most to retail sales */

with age_tot as(
	select age_band, sum(sales) as tot_sales
	from clean_weekly_sales
	where platform = "Retail" and age_band != "unknown"
	group by age_band
	order by tot_sales desc)
select *
from(
select *, row_number() over() as rn
from age_tot) x
where x.rn = 1;

with demo_tot_sales as (
	select demographic, sum(sales) as tot_sales
	from clean_weekly_sales
	where demographic != "unknown" and platform = "Retail"
	group by demographic
	order by tot_sales desc)
select *
from(
select *, row_number() over() as rn
from demo_tot_sales) x
where x.rn = 1;

/* 9.Can we use the avg_transactions column to find the average transaction 
size for each year for Reatil vs Shopify? if not- how would you calculate it instead */

select platform, calendar_year, avg(sales_tot/tranc_total)
from(
select platform, calendar_year, sum(sales) as sales_tot, sum(transactions) as tranc_total
from clean_weekly_sales
group by calendar_year, platform) x
group by calendar_year, platform;
