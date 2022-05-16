/*1.How many users are there?*/
select count(distinct user_id) as no_users
from users;

/*2.How many cookies does each user have on average? */
select avg(cookie_count)
from(
select user_id, count(cookie_id) as cookie_count
from users
group by user_id) x;

/*3.What is the unique number of visits by all users per month? */
select month(start_date) as months, count(distinct visit_id)
from events e
inner join users u on u.cookie_id = e.cookie_id
group by month(event_time)
order by months;

/*4.What is the number of events for each event type?*/
select event_type, count(event_type)
from events
group by event_type;

/* 5.What is the percentage of visits which have a purchase event? */

select concat(count(case when event_type = 3 then "purchase" end)*100/ count(distinct visit_id), "%")
from events e;

/*6.What is the percentage of visits which view the checkout page but do not have a purchase event? */

select
100-(count(case when event_type = 3 then 1 end)/count(case when e.page_id = 12 and event_type = 1 then visit_id end)*100)
from events e
inner join page_hierarchy pg_h
on pg_h.page_id = e.page_id;

/*7.What are the top 3 pages by number of views?*/
select page_name, count(visit_id) as visit_tot
from events e
inner join page_hierarchy pg_h
on pg_h.page_id = e.page_id
group by page_name
order by visit_tot desc
limit 3;


/*8.What is the number of views and cart adds for each product category? */
select event_name, e.event_type, product_category, count(product_category)
from page_hierarchy pg_h
inner join events e
on pg_h.page_id = e.page_id
inner join event_identifier e_id
on e_id.event_type = e.event_type
where event_name in ("Page View", "Add to Cart")
group by product_category, event_name
having product_category is not null
order by product_category;

/*9.What are the top 3 products by purchases? */
with t1 as(
select visit_id
from events e
inner join page_hierarchy pg_h on e.page_id = pg_h.page_id
where event_type = 3)
select page_name, count(visit_id) as count_visit
from events e
inner join page_hierarchy pg_h on e.page_id = pg_h.page_id
where visit_id in (select * from t1) and event_type = 2
group by page_name
order by count_visit desc
limit 3;