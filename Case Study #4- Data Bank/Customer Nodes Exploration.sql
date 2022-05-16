/* How many unique nodes are there on the Data Bank system? */
select count(distinct node_id)
from customer_nodes;

/* 2.What is the number of nodes per region? */
select region_id, count(node_id)
from customer_nodes
group by region_id
order by region_id;

/*3.How many customers are allocated to each region? */
select region_id, count(distinct customer_id)
from customer_nodes
group by region_id
order by region_id;

/*4.How many days on average are customers reallocated to a different node? */

select avg(date_diff)
from(select *, (end_date- start_date) as date_diff
from customer_nodes
where end_date != '9999-12-31') x; 

/*5.What is the median, 80th and 95th percentile for this same reallocation days metric for each region?*/
with t1 as (
select *, (end_date- start_date) as date_diff
from customer_nodes
where end_date != '9999-12-31'),
t2 as (select *,
percent_rank() over(partition by region_id order by date_diff) * 100 as per_rnk 
from t1),
t3 as (
select *,
row_number() over(partition by region_id) as rnk
from t2
where per_rnk >= 50)
select *
from t3
where rnk = 1;

with t1 as (
select *, (end_date- start_date) as date_diff
from customer_nodes
where end_date != '9999-12-31'),
t2 as (select *,
percent_rank() over(partition by region_id order by date_diff) * 100 as per_rnk 
from t1),
t3 as (
select *,
row_number() over(partition by region_id) as rnk
from t2
where per_rnk >= 80)
select *
from t3
where rnk = 1;

with t1 as (
select *, (end_date- start_date) as date_diff
from customer_nodes
where end_date != '9999-12-31'),
t2 as (select *,
percent_rank() over(partition by region_id order by date_diff) * 100 as per_rnk 
from t1),
t3 as (
select *,
row_number() over(partition by region_id) as rnk
from t2
where per_rnk >= 95)
select *
from t3
where rnk = 1;