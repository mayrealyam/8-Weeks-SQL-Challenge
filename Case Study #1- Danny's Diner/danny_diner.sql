/* 1.What is the total amount each customer spent at the restaurant? */
select customer_id, menu.product_id, sum(price)
from sales
inner join menu
on menu.product_id = sales.product_id
group by customer_id;

/* 2.How many days has each customer visited the restaurant? */
select customer_id, count( distinct order_date)  as no_of_date 
from sales
group by customer_id;

/*3. What was the first item from the menu purchased by each customer? */
select *
from(
select *,
dense_rank() over(partition by customer_id order by order_date) as rn
from(
select customer_id, order_date, product_name
from sales
inner join menu
on menu.product_id = sales.product_id) as rnk) as dataset
where dataset.rn=1;

/* 4.What is the most purchased item on the menu 
and how many times was it purchased by all customers? */
select product_name, count(customer_id) as no_customer
from sales
inner join menu
on menu.product_id = sales.product_id
group by product_name
order by no_customer desc
limit 1;

/*5.Which item was the most popular for each customer?*/
select customer_id, product_name
from(
	select customer_id, product_name, count_name,
	 max(count_name) over(partition by customer_id) as max_count_name
	from(
	select customer_id, product_name, count( product_name) as count_name
	from sales
	inner join menu
	on menu.product_id = sales.product_id
	group by customer_id, product_name) as c_n) as max_c
where max_c.count_name = max_count_name;

/*6.Which item was purchased first by the customer after they became a member? */
select *
from(
select customer_id, order_date, join_date, product_name,
rank() over(partition by customer_id order by order_date) as rnk
from(
select sales.customer_id, product_id, order_date, join_date
from sales
join members
on sales.customer_id = members.customer_id ) as d1
inner join menu
on menu.product_id = d1.product_id
where join_date <= order_date
order by customer_id, order_date) as rnks
where rnks.rnk=1;

/* 7.Which item was purchased just before the customer became a member? */

SELECT 
  customer_id, product_name, order_date, join_date
FROM
    (SELECT 
        sales.customer_id, product_id, order_date, join_date
    FROM
        sales
    INNER JOIN members ON sales.customer_id = members.customer_id) AS d1
        INNER JOIN
    menu ON menu.product_id = d1.product_id
WHERE
    join_date > order_date
order by customer_id, order_date;

 /*8.What is the total items and amount spent for each member before they became a member? */
SELECT 
    customer_id, count(distinct product_name), sum(price)
FROM
    (SELECT 
        sales.customer_id, product_id, order_date, join_date
    FROM
        sales
    INNER JOIN members ON sales.customer_id = members.customer_id) AS d1
        INNER JOIN
    menu ON menu.product_id = d1.product_id
WHERE
    join_date > order_date
group by customer_id;

/* 9.If each $1 spent equates to 10 points 
and sushi has a 2x points multiplier - how many points would each customer have? */ 

select customer_id, sum(points)
from(
select *,
case
	when product_name = "sushi" then price * 20
    else price * 10
end as "points"
from(
select customer_id, product_name, price
from sales 
inner join menu
on menu.product_id = sales.product_id) as d1) as d2
group by customer_id;

/* 10.In the first week after a customer joins the program(including their join date) they earn 2* points
on all items, not just shushi- how many points do customer A AND B have at the end of January */

select customer_id, price, month(order_date) as month, join_date, sum(points) 
from(
select customer_id, price, month(order_date), join_date, order_date,
case 
	when product_name = "sushi" or order_date between join_date and (date_add(join_date, interval 1 week))  then price * 20
    else price * 10
end as "points"
from(
select members.customer_id, product_id, product_name, price, order_date, join_date
from(
select customer_id, menu.product_id, product_name, price, order_date
from sales
inner join menu
on sales.product_id = menu.product_id) as sales_menu
inner join members
on members.customer_id = sales_menu.customer_id
) as d3) as d4
group by customer_id, month(order_date)
having month = 1;

/* Bonus.adding a membership column */
 select *,
 case
 when members="Y" then (rank() over(partition by members, customer_id order by order_date))
 else "null"
 end as ranking
 from(
select customer_id, order_date, product_name, price, 
case
	when order_date < join_date or join_date is null then "N"
    when order_date >= join_date then "Y"
    else "Y"
end as "members"
from(
select menu_sales.customer_id, order_date, product_id, product_name, price, join_date
from(
select customer_id, order_date, sales.product_id, product_name, price
from sales
inner join menu
on sales.product_id = menu.product_id) as menu_sales
left join members
on members.customer_id = menu_sales.customer_id) as whole_date) as dataset
order by customer_id, order_date;


