create temporary table product_table1 as (
with t1 as (
	select e.visit_id, event_type, page_name as product_name, product_category,
	sum(case when event_type = 1 then 1 else 0 end) "page_viewed" ,
	sum(case when event_type = 2 then 1 else 0 end) "cart_added"
	from events e
	inner join page_hierarchy pg_h
	on pg_h.page_id = e.page_id
	where product_category is not null
	group by e.visit_id, product_name),
t2 as (
select distinct visit_id
from events
where event_type = 3),
t3 as (
select t1.visit_id, event_type, product_name, product_category, page_viewed, cart_added,
case when t2.visit_id is not null then 1 else 0 end purchase
from t1
left join t2
on t1.visit_id = t2.visit_id)
select product_name, product_category, sum(page_viewed) as page_viewed, sum(cart_added) as cart_added,
	sum(case when cart_added = 1 and purchase = 0 then 1 end) abandoned,
    sum(case when cart_added = 1 and purchase = 1 then 1 end) purchase
from t3
group by product_name);

create temporary table product_table2 as (
with cte1 as (
	select e.visit_id, event_type, page_name as product_name, product_category,
	sum(case when event_type = 1 then 1 else 0 end) "page_viewed" ,
	sum(case when event_type = 2 then 1 else 0 end) "cart_added"
	from events e
	inner join page_hierarchy pg_h
	on pg_h.page_id = e.page_id
	where product_category is not null
	group by e.visit_id, page_name, product_category),
cte2 as (
select distinct visit_id
from events
where event_type = 3),
cte3 as (
select cte1.visit_id, event_type, product_name, product_category, page_viewed, cart_added,
case when cte2.visit_id is not null then 1 else 0 end purchase
from cte1
left join cte2
on cte1.visit_id = cte2.visit_id)
select product_category, sum(page_viewed) as page_viewed, sum(cart_added) as cart_added,
	sum(case when cart_added = 1 and purchase = 0 then 1 end) abandoned,
    sum(case when cart_added = 1 and purchase = 1 then 1 end) purchase
from cte3
group by product_category);

/* 1.Which product had the most views, cart adds and purchase?
# Most viewed - Oyster
# Most cart adds - Lobster
# Most purchased - Lobster
2. What product was most likely to be abandoned?
# Most abandoned - Russian Caviar 
3. Which product had the highest view to purchase percentage*/
select product_name, concat(round((page_viewed*100/purchase), 2), "%") as view_to_purchase
from product_table1
order by view_to_purchase desc
limit 1;

#4.What is the average conversion rate from view to cart add?
select avg((page_viewed/cart_added)) as avg_conv_view_to_cart
from product_table1;

#5 What is the average conversion rate from cart add to purchase?
select avg((cart_added/purchase)) as avg_conv_cart_to_purchase
from product_table1;