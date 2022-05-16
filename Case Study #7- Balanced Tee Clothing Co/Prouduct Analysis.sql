/*1.What are the top 3 products by total revenue before discount?*/
with rev_tab as (
select prod_id, (qty*price) as rev_before_disc
from sales
group by prod_id),
order_tab as (
select *,
dense_rank() over(order by rev_before_disc desc) drnk
from rev_tab)
select *
from order_tab
where drnk in (1, 2, 3);

/*2.What is the total quantity, revenue and discount for each segment?*/
select segment_name, segment_id, sum(qty) as tot_qty, sum(s.price*qty) as tot_rev, sum(s.price*qty*discount/100) as tot_disc
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by segment_name;

/*3.What is the top selling product for each segment?*/
with table1 as(
select product_id, product_name, segment_id, segment_name, 
count(product_id) as count_prod, sum(qty) as tot_qty
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by segment_name, product_id),
table2 as (select *,
dense_rank() over(partition by segment_id order by tot_qty desc) as dnk
from table1)
select product_id, product_name, segment_id, segment_name, dnk
from table2
where dnk = 1;

/*4.What is the total quantity, revenue and discount for each category?*/
select category_id, category_name, sum(qty)as tot_qty, (s.price*qty*discount/100) as revenue, sum(discount) as tot_discount
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by category_id;

/*5.What is the top selling product for each category?*/
with t1 as(
select category_id, category_name, product_name, sum(qty)as tot_qty, count(product_id) as count_prod
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by category_id, product_name)
select *
from(
select *,
dense_rank() over(partition by category_name order by tot_qty desc) drnk
from t1)x
where x.drnk = 1;

/*6.What is the percentage split of revenue by product for each segment?*/
with rev_tab as (
select product_name, segment_name, sum(qty*s.price) as rev
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by segment_id, product_id),
rev_seg as(select *, sum(rev) over(partition by segment_name) as T_rev_seg,
row_number() over(partition by segment_name) as rn
from rev_tab)
select *, T_rev_seg/sum(T_rev_seg) over() as per_split
from rev_seg
where rn = 1;

/*7. What is the percentage split of revenue by segment for each category?*/
with rev_tab as (
select segment_name, category_id, category_name, sum(qty*s.price) as rev
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by segment_id, category_id),
cat_rev as (select *, sum(rev) over(partition by category_name) as T_rev_cat,
row_number() over(partition by category_name) as rn
from rev_tab)
select *, T_rev_cat/sum(T_rev_cat) over() as per_split
from cat_rev
where rn = 1;

/*8.What is the percentage split of total revenue by category?*.*/
select category_name, sum(qty*s.price) as tot_rev
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by category_id;

/*9.What is the total transaction “penetration” for each product? 
(hint: penetration = number of transactions where at least 1 quantity 
of a product was purchased divided by total number of transactions)*/
select prod_id, product_name, count(distinct txn_id)/(select count(distinct txn_id) from sales) as peneration
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
group by prod_id;

/*10.What is the most common combination of at least 1 quantity of any 3 products in a 1 single transaction?*/
select *
from(
select *,
row_number()over(partition by product_name order by rn desc) as rnk1
from(
select prod_id, product_name, txn_id, style_name, row_number() over(partition by product_name) as rn
from sales s
inner join product_details as prod_det
on s.prod_id = prod_det.product_id
order by txn_id) x) y
where rnk1 = 1
order by rn desc
limit 3;
