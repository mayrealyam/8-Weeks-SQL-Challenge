use foodie_fi;

#create sample data using temporary table
create temporary table sample_data
select customer_id, plans.plan_id, start_date, plan_name, price
from subscriptions
inner join plans
on subscriptions.plan_id = plans.plan_id
where customer_id in(1, 2, 11, 13, 15, 16, 18, 19);

select *
from sample_data;
#start and end date for which the data was collected
select min(start_date), max(start_date)
from sample_data;

select *
from sample_data
where customer_id = 19;

# BAsed off the 8 smaple customers provided in the sample from the subscriptions table,
#write a brief description about each customer's onboarding journey
/* Customer_id 1 subscribed for only basic monthly plan. 
customer_id2 subscribed for only pro annual plan after using the free trial.
customer_id11 signed up for to the 7 day free trial then cancel.
customer_id13 signed up for the 7 day free trial then subscribed for the basic monthly plan before upgrading to pro monthly.
customer_id15 signed up for the 7 day free trial then subscribed for the pro monthly plan then cancel the plan.
customer_id16 signed up for the free trial then subscribed to basic monthly plan before upgrading to pro annual plan
customer_id18 signed up for the free trial then subscribed to pro monthly plan.
customer_id19 signed up for the free trial then subscribd to pro monthly plan before upgrading to pro annual plan.


/* 1.How many customers has Foodie-Fi ever had? */
select count(distinct customer_id) as NoFoodie_Fi_Customer
from subscriptions;

/* 2.What is the monthly distribution of trial plan start_date values for our dataset-
use the start of the month as the group by the value? */
select start_date, month(start_date), count(plan_name)
from subscriptions
inner join plans
on plans.plan_id = subscriptions.plan_id
where plan_name = "trial"
group by month(start_date)
order by month(start_date);

/* 3.what plan start_date values occur after the year 2020 for our dataset?
show the breakdown by count of events for each plan_name? */
select plan_name, count(plan_name) as plan_after_2020
from subscriptions
inner join plans
on plans.plan_id = subscriptions.plan_id
where year(start_date) = 2021
group by plan_name;


/* 4.What is the customer count and percentage of customers who have churned rounded
to 1 decimal place? */
select plan_name, count(plan_name) as count_churn,
concat(round((count(plan_name)*100/1000), 2), "%") as per_churn
from subscriptions as s
inner join plans as p
on p.plan_id = s.plan_id
group by plan_name
having plan_name = "churn";

/* 5. How mnay customers have churned straight after their initial free trial-
what percenatge is this rounded to the nearest whole number */
with cte5 as (
	select p.plan_id, count(plan_name),
	sum(case
		when plan_name = "churn" then 1
		else 0
	end) as NoStraigh_Churn
	from subscriptions as s
	inner join plans as p
	on p.plan_id = s.plan_id
	group by customer_id
	having count(plan_name) = 2)
select count(NoStraigh_Churn), concat(truncate((count(NoStraigh_Churn)*100/1000), 0), "%") as per_straightChurn
from cte5
where NoStraigh_Churn = 1;

with CTE5 as (
	select customer_id, plans.plan_id, plan_name, price,
	rank() over(partition by customer_id order by plan_id) rnk
	from subscriptions
	inner join plans
	on plans.plan_id = subscriptions.plan_id
    order by customer_id, plans.plan_id)
    
select count(customer_id), concat(truncate(count(customer_id)*100/1000, 0), "%")
from CTE5
where rnk = 2 and plan_id = 4;

/* 6.What is the number and percentage of customer plans after their initial free trial? */
with cte6 as (
	select customer_id, plans.plan_id, plan_name, price,
	rank() over(partition by customer_id order by plans.plan_id) rnk
	from subscriptions
	inner join plans
	on subscriptions.plan_id = plans.plan_id
    where plan_name not in ("trial", "churn"))
select count(distinct customer_id) as no_cus_after_initial_plans, 
concat(count(distinct customer_id)*100/1000, "%") as per_cust
from cte6;

/* 7.What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31 */
select plan_id, count(customer_id), concat(round(count(customer_id)*100/1000, 2), "%")
from subscriptions
where start_date < "2020-12-31" and "2020-12-31" <= adddate(start_date, interval 1 month)
group by plan_id;

/* 8.How many customers have upgraded to an annual plan in 2020? */
select count(customer_id) as NoCust_upgrade_annnualPlan
from subscriptions
inner join plans
on plans.plan_id = subscriptions.plan_id
where year(start_date) = "2020" and plan_name = "pro annual";

/* 9.How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi */

with cte9 as(
	select plans.plan_id, customer_id, start_date, plan_name, price,
	lag(start_date) over(partition by customer_id) as firstTrial_date
	from subscriptions
	inner join plans
	on plans.plan_id = subscriptions.plan_id
	where price = 0.00 or price = 199.00)
select avg(date_diff) as avg_cust_annualPlan
from(
select customer_id, datediff(start_date, firstTrial_date) as date_diff
from cte9
where firstTrial_date is not null) as CTE;

/* 10. Can you further breakdown this average value into 30 da periods (i.e0-30 days, 31-60 days ect) */


with t1 as (
	select customer_id, plan_id, datediff(start_date, annu_date) as dateDif
	from (
		select *, lag(start_date) over(partition by customer_id order by customer_id) as annu_date
		from subscriptions
		where plan_id = 0 or plan_id = 3) x
	where x.annu_date is not null)

select date_range, count(date_range)
from(select *,
case 
	when dateDif >= 0 and dateDif <= 30 then "0-30 days"
    when dateDif >= 31 and dateDif <= 60 then "31-60 days"
    when dateDif >= 61 and dateDif <= 90 then "61-90 days"
    when dateDif >= 91 and dateDif <= 120 then "91-120 days"
    when dateDif >= 121 and dateDif <= 150 then "121-150 days"
    when dateDif >= 151 and dateDif <= 180 then "151-180 days"
    when dateDif >= 181 and dateDif <= 210 then "181-210 days"
    when dateDif >= 211 and dateDif <= 240 then "211-240 days"
    when dateDif >= 241 and dateDif <= 270 then "241-270 days"
    when dateDif >= 271 and dateDif <= 300 then "271-300 days"
    when dateDif >= 301 and dateDif <= 330 then "301-330 days"
    when dateDif >= 331 and dateDif <= 360 then "331-360 days"
    else null
end date_range
from t1) x
group by date_range
order by date_range;



/* 11.How many customers downgraded from a pro monthly plaan to a basic monthly plan in 2020 ? */
select count(customer_id)
from(
select customer_id, plans.plan_id, start_date, plan_name,price,
lag(plan_name) over(partition by customer_id) as prev_plan
from subscriptions
inner join plans
on plans.plan_id = subscriptions.plan_id) as table_with_prev
where plan_name = "basic monthly" and prev_plan = "pro monthly";

