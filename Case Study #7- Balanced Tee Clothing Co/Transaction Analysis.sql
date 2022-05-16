/*1.How many unique transactions were there?*/
select count(distinct txn_id)
from sales;

/*2.What is the average unique products purchased in each transaction? */
select sum(qty)/ count(distinct txn_id) as avg_uniq_prod
from sales;

/*3.What are the 25th, 50th and 75th percentile values for the revenue per transaction?*/
with t1 as(
select txn_id, prod_id, sum((price*qty)) over(partition by txn_id) as rev_per_txn
from sales),
t2 as(
select *, round(percent_rank() over(order by rev_per_txn), 2) as per_rank
from t1)
select *
from t2
where per_rank in (0.25, 0.50, 0.75);
/*4.What is the average discount value per transaction?*/
select txn_id, round(sum(price*qty*discount/100)/count(distinct txn_id), 3) as avg_disc
from sales;

/*5.What is the percentage split of all transactions for members vs non-members?*/
with t1 as (
select
count(distinct case when member = "t" then txn_id else 0 end) members,
count(distinct case when member = "f" then  txn_id else 0 end) non_members
from sales)
select *, concat(members*100/(sum(members) + sum(non_members)), "%") as mem_per,
concat(non_members*100/(sum(members) + sum(non_members)), "%") as Nmem_per
from t1;

/*6.What is the average revenue for member transactions and non-member transactions?*/
select member, sum(price*qty)/count(price) as avg_rev
from sales
group by member;
