/*1.What is the unique count and total amount for each transaction type? */
select distinct txn_type,count(txn_type) as tno_ranc_type, sum(txn_amount) as total_tranc
from customer_transactions
group by txn_type;

/*2.What is the average total historical deposit counts and amounts for all customers? */

select avg(txn_amount) as average_amount
from customer_transactions
where txn_type = "deposit";

/*3.For each month - how many Data Bank customers make more than 1 
deposit and either 1 purchase or 1 withdrawal in a single month?*/
with t1 as(
select customer_id, month(txn_date) as months,
sum(case when txn_type = "deposit" then 1 else 0 end) deposit,
sum(case when txn_type = "withdrawal" then 1 else 0 end) withdrawal,
sum(case when txn_type = "purchase" then 1 else 0 end) purchase
from customer_transactions
group by month(txn_date), customer_id),
t2 as(
	select *
	from t1
	where deposit >= 2 and  (withdrawal = 1 or purchase = 1))
select months, count(customer_id)
from t2
group by months;
    
/*4.What is the closing balance for each customer at the end of the month?*/

with t1 as(
	select *, last_day(txn_date), month(txn_date) as months,
	sum(case 
		when txn_type = "purchase" or txn_type = "withdrawal"
			then (-txn_amount)
		else txn_amount
	end) tot_amount
	from customer_transactions
	group by customer_id, month(txn_date), txn_type
	order by customer_id, months , txn_type),

t2 as (
	select customer_id, txn_date, last_day(txn_date), months, sum(tot_amount) as end_each_monthTot
	from t1
	group by customer_id, months)

select customer_id,last_day(txn_date), months, end_each_monthTot as txn_of_the_month,
sum(end_each_monthTot) over(partition by customer_id order by customer_id, months) as closing_balance
from t2;

select 
	date_format(
    adddate("2020-01-31", @num:=@num+1), "%Y-%m-%d"
) date
from customer_transactions,
(select @num:=-1) num
limit 365;
    
with recursive nrows(date) as (
select makedate(2020, 333) union all
select date_add(date, interval 1 month)
from nrows where date <= current_date)
select date from nrows;

select makedate(2020, 333);

/* 5.What is the percentage of customers who increase their closing balance by more than 5% */
with t1 as(
	select *, last_day(txn_date), month(txn_date) as months,
	sum(case 
		when txn_type = "purchase" or txn_type = "withdrawal"
			then (-txn_amount)
		else txn_amount
	end) tot_amount
	from customer_transactions
	group by customer_id, month(txn_date), txn_type
	order by customer_id, months , txn_type),

t2 as (
	select customer_id, txn_date, last_day(txn_date), months, sum(tot_amount) as end_each_monthTot
	from t1
	group by customer_id, months),
    
t3 as (
	select customer_id,last_day(txn_date) as lastDay, months, end_each_monthTot as txn_of_the_month,
	sum(end_each_monthTot) over(partition by customer_id order by customer_id, months) as closing_balance
	from t2),
t4 as (
select *, lead(closing_balance) over(partition by customer_id order by lastDay) as lead_balance
from t3)

select lastDay, count(distinct customer_id) as No_customer,
sum(case when ((lead_balance-closing_balance)/closing_balance) > 0.05 
	then 1 else 0 end) increased_cus, 
concat(round(sum(case when ((lead_balance-closing_balance)/closing_balance) > 0.05 
	then 1 else 0 end)/count(distinct customer_id), 3), "%") as per_increasedCus
from t4
group by lastDay;