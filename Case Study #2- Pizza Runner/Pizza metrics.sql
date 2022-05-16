#1A How many pizzas were ordered */
use pizza_runner;
select count(order_id)
from customer_orders;

#2A How many unique customers orders were made
select customer_id, count(order_id) 
from customer_orders
group by customer_id;

#3A How many successful orders were delivered by each runner?
select runner_id, 
sum(case when cancellation is null then 1
	else 0 end) no_of_sucessful_orders
from runner_orders
group by runner_id;

#4A How many of each type of pizza was delivered
select pizza_name, count(pizza_name)
from (customer_orders inner join pizza_names
on customer_orders.pizza_id = pizza_names.pizza_id)
inner join runner_orders on runner_orders.order_id = customer_orders.order_id
where cancellation is null
group by pizza_name;

#5A How many vegetarians and meatlovers were ordered by each customer?
select customer_id, pizza_name, count(pizza_name)
from customer_orders inner join pizza_names
on customer_orders.pizza_id = pizza_names.pizza_id
group by customer_id, pizza_name
order by customer_id;

#6A What was the max no of pizzas delivered in a single order
with ct1 as
(select order_id, count(order_id) as count_order, max(count(order_id)) over() as max_order
from customer_orders
group by order_id)
select max_order
from ct1
where ct1.max_order = count_order;

/*7A For each customer, how many delivered pizzas had at least 1 chnage and how many had no change */
/*delivered order with change
with CTE as (
	with cte1 as (select customer_orders.order_id, customer_id, exclusions, extras, cancellation
	from customer_orders
	left join runner_orders
	on customer_orders.order_id = runner_orders.order_id
	where cancellation is null)
	select *
	from cte1
	where exclusions regexp "[[:digit:]]" or extras regexp "[[:digit:]]") 
select customer_id, count(order_id) as delivered_order_with_change
from CTE
group by customer_id; */

select customer_id,
sum(case
    when extras is null and exclusions is null then 0
    else 1
end) with_change,
sum(case
	when extras is not null or exclusions is not null then 1
    else 0
end) no_change
from customer_orders
inner join runner_orders
on runner_orders.order_id = customer_orders.order_id
where cancellation is null
group by customer_id; 

/*delivred order without change
with CTE2 as(
with cte1 as (select customer_orders.order_id, customer_id, exclusions, extras, cancellation
	from customer_orders
	left join runner_orders
	on customer_orders.order_id = runner_orders.order_id
	where cancellation is null)
select *
from cte1
where extras is null and exclusions is null
or extras = "" and exclusions = ""
or extras is null and exclusions = ""
or extras = "" and exclusions  is null)
select customer_id, count(order_id) as delivered_order_without_change
from CTE2
group by customer_id; */
    
/*8.How many pizzas were delivered that had both exclusions and extras */
with CTE8 as (
with cte8 as (select customer_orders.order_id, customer_id, exclusions, extras, cancellation
	from customer_orders
	left join runner_orders
	on customer_orders.order_id = runner_orders.order_id
	where cancellation is null)
select *
from cte8
where exclusions regexp "[[:digit:]]" and extras regexp "[[:digit:]]")
select count(order_id) as pizzas_delivered_both_exclusions_extras
from CTE8;

/* 9.What was the total volume of pizzas ordered for each hour of the day */
select date(order_time), hour(time(order_time)), count(order_id) as totVol_pizza_per_hourDay
from customer_orders
group by date(order_time), hour(time(order_time));

/*10.What was the volume of orders for each day of the week */
select order_time, week(date(order_time)),day(date(order_time)), count(order_id) as vol_eachDay
from customer_orders
group by week(date(order_time)), day(date(order_time));