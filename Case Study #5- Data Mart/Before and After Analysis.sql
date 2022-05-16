create temporary table demo_table as
select *,
case
	when week_date < date("2020-06-15") then "before"
    when week_date > date("2020-06-15") then "after"
    when week_date = date("2020-06-15") then "start"
end date_metrics
from clean_weekly_sales;

/*1. What is the total sales for the 4 weeks before and after 2020-06-15?
 What is the growth or reduction rate in actual vales and percentage of sales? */

with t1 as(
select
 sum(case
	when date_metrics = "before" then sales
end) sales_before,
sum(case
	when date_metrics = "after" or date_metrics = "start" then sales
end) sales_after
from demo_table
where ((date_sub(date("2020-06-15"), interval 4 week) 
			<= week_date and week_date < date("2020-06-15"))
	or ((date("2020-06-15")) <= week_date and 
			week_date < date_add(date("2020-06-15"), interval 4 week)))
order by week_number)
select *, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t1;

/* 2.What about the entire 12 weeks before and after ? */
with t1 as(
select
 sum(case
	when date_metrics = "before" then sales
end) sales_before,
sum(case
	when date_metrics = "after" or date_metrics = "start" then sales
end) sales_after
from demo_table
where ((date_sub(date("2020-06-15"), interval 12 week) 
			<= week_date and week_date < date("2020-06-15"))
	or ((date("2020-06-15")) <= week_date and 
			week_date < date_add(date("2020-06-15"), interval 12 week)))
order by week_number)
select *, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t1;

/*3. How do the sale metrics for these 2 periods before 
and after compare with the previous years in 2018 and 2019 
2020-06-15 is the 24th week. Thus, the 4 weeks before starts on 20th and 
ends on 23rd while the after starts on 24th and end on 27th. Also, 
the range of 12 weeks before is week 12-23 while the range of 12 weeks after is week 24-37*/

with t1 as (
select calendar_year, week_number, sum(sales) as sales_total
from demo_table
where (20 <= week_number and week_number < 24) or (24 <= week_number and week_number < 28)
group by calendar_year, week_number),
t3 as (
select calendar_year, 
 sum(case
	when (20 <= week_number and week_number < 24) then sales_total
end) sales_before,
sum(case
	when (24 <= week_number and week_number < 28) then sales_total
end) sales_after
from t1
group by calendar_year)
select *, sales_after-sales_before as diff, concat((sales_after-sales_before)*100/sales_before, "%") as per_diff
from t3
order by calendar_year;

/*The analysis showed that there was increase in sales by 0.193% in 2018 in the 4 weeks after the week 24
and 0.104% increase in 2019 in the same period
but decrease in 2020 by 1.146% in the same period.

with t1 as (
select calendar_year, week_number, sum(sales) as sales_total
from demo_table
where (12 <= week_number and week_number < 24) or (24 <= week_number and week_number < 37)
group by calendar_year, week_number),
t3 as (
select calendar_year, 
 sum(case
	when (12 <= week_number and week_number < 24) then sales_total
end) sales_before,
sum(case
	when (24 <= week_number and week_number < 37) then sales_total
end) sales_after
from t1
group by calendar_year)
select *, sales_after-sales_before as diff, concat(round((sales_after-sales_before)*100/sales_before, 3), "%") as per_diff
from t3
order by calendar_year;
/* In 2018, there was 1.63% increase in the 12 weeks after week 24. 
Also, there was 0.3% decrease in 2019 in the 12 weeks and 2.14% in 2020 of the same period.