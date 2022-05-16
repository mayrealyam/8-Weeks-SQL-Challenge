#analysis by region
with t1 as(
select *,
 sum(case when date_metrics = "before" then sales end) sales_before,
sum(case when date_metrics = "after" or date_metrics = "start" then sales end) sales_after
from demo_table
where (date_sub(date("2020-06-15"), interval 12 week) 
			<= week_date and week_date < date("2020-06-15"))
	or ((date("2020-06-15")) <= week_date and 
			week_date < date_add(date("2020-06-15"), interval 12 week))
group by region)
select *, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t1
;

#analysis by customer_type
with t1 as(
select *, sum(case when date_metrics = "before" then sales end) sales_before,
sum(case when date_metrics = "after" or date_metrics = "start" then sales end) sales_after
from demo_table
where (date_sub(date("2020-06-15"), interval 12 week) 
			<= week_date and week_date < date("2020-06-15"))
	or ((date("2020-06-15")) <= week_date and 
			week_date < date_add(date("2020-06-15"), interval 12 week))
group by customer_type)
select customer_type, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t1
;

#analysis by demographic
with t1 as(
select *,
 sum(case when date_metrics = "before" then sales end) sales_before,
sum(case when date_metrics = "after" or date_metrics = "start" then sales end) sales_after
from demo_table
where (date_sub(date("2020-06-15"), interval 12 week) 
			<= week_date and week_date < date("2020-06-15"))
	or ((date("2020-06-15")) <= week_date and 
			week_date < date_add(date("2020-06-15"), interval 12 week))
group by demographic)
select demographic, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t1
;

#analysis by platform
with t1 as(
select *,
 sum(case
	when date_metrics = "before" then sales end) sales_before,
sum(case when date_metrics = "after" or date_metrics = "start" then sales end) sales_after
from demo_table
where (date_sub(date("2020-06-15"), interval 12 week) 
			<= week_date and week_date < date("2020-06-15"))
	or ((date("2020-06-15")) <= week_date and 
			week_date < date_add(date("2020-06-15"), interval 12 week))
group by platform)
select platform, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t1
;

#analysis by age_band
with t1 as(
select *,
 sum(case when date_metrics = "before" then sales end) sales_before,
sum(case when date_metrics = "after" or date_metrics = "start" then sales end) sales_after
from demo_table
where (date_sub(date("2020-06-15"), interval 12 week) 
			<= week_date and week_date < date("2020-06-15"))
	or ((date("2020-06-15")) <= week_date and 
			week_date < date_add(date("2020-06-15"), interval 12 week))
group by age_band)
select age_band, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t1
;