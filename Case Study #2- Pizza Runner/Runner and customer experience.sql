use pizza_runner;
/* 1.How many runners signed up for each 1 week period */
select week(registration_date), count(runner_id)
from runners
group by week(registration_date);

/* 2B.What was the average time in minutes it 
took for each runner to arrive at the Pizza Runner HQ to pickup the order */

with cte2 as(
	select order_time as distinct_order_time ,customer_orders.order_id, 
	runner_id, pickup_time, timestampdiff(minute, order_time, pickup_time) as time_runner_picked
	from runner_orders
	inner join customer_orders
	on customer_orders.order_id = runner_orders.order_id
    where cancellation is null)
select runner_id, avg(time_runner_picked) as avgTime_mins_runner_picked
from cte2
group by runner_id;


/*3B Is there any relationship between the number of pizzas
 and how long the order takes to prepare */
with cte3 as (
	select count(customer_orders.order_id) as pizza_ordered, order_time, pickup_time, timestampdiff(minute, order_time, pickup_time) as time_diff
	from customer_orders
	inner join runner_orders
	on customer_orders.order_id = runner_orders.order_id
    where cancellation is null
    group by customer_orders.order_id)
select pizza_ordered, avg(time_diff)
from cte3
group by pizza_ordered;

/*4B What was the average distance travelled for each customer */
with cte4 as(
select customer_id, distance, regexp_substr(distance, "[:digit:]{1,}") as dis
from runner_orders
inner join customer_orders
on customer_orders.order_id = runner_orders.order_id
where distance is not null)
select customer_id, avg(dis)
from cte4
group by customer_id;

/* 5B.What was the difference between the longest and shortest delivery times for all orders */
with cte4 as(
select customer_id, duration, regexp_substr(duration, "[:digit:]{1,}") as dur
from runner_orders
inner join customer_orders
on customer_orders.order_id = runner_orders.order_id
where duration is not null)
select max(dur)-min(dur)
from cte4;

/*6B. What was the average speed for each runner for each delivery
and do you notice any trend for these values */
with cte6 as (
select *,
(regexp_substr(distance, "[0-9]{1,}"))/(regexp_substr(duration, "[[:digit:]]{1,}")/60) as speed_in_km_perhr
from runner_orders
where duration is not null)
select order_id, runner_id, avg(speed_in_km_perhr)
from cte6
group by runner_id, order_id;
#there is increase in the speed of the runners

/* 7B. What is the successful delivery percentage for each runner */
select *, concat((100-(count(cancellation) * 100/count(runner_id))), "%") as per_successful_delivery
from runner_orders
group by runner_id;
