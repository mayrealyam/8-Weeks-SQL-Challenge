/*1.What was the total quantity sold for all products? */
select prod_id, count(prod_id) as tot_qty
from sales;

/*2.What is the total generated revenue for all products before discounts?*/
select sum(total_gen) as rev_before_disc
from(
select qty*price as total_gen
from sales) x;

/*3.What was the total discount amount for all products?*/
select sum(price*qty*discount/100) as discount_prod
from sales;