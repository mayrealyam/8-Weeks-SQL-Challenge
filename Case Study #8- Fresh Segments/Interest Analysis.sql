/*1.Which interests have been present in all month_year dates in our dataset?*/
select count(distinct month_year)
from cleaned_interest_metrics;
#There are 14 unique month_year in the table

with table1 as (select month_year, interest_id, interest_name, 
row_number() over(partition by interest_id) as rn
from cleaned_interest_metrics i_met
left join interest_map i_map
on i_map.id = i_met.interest_id
where interest_id is not null)
select *
from table1
where rn = 14;

/*2.Using this same total_months measure - calculate the cumulative percentage 
of all records starting at 14 months - which total_months value passes the 90% cumulative percentage value?*/
with table1 as (select month_year, interest_id, interest_name, percentile_ranking,
row_number() over(partition by interest_id) as rn
from cleaned_interest_metrics i_met
left join interest_map i_map
on i_map.id = i_met.interest_id
where interest_id is not null),
table2 as(
select rn, count(rn) count_rn
from table1
group by rn
order by rn desc),
table3 as(select *, concat((count_rn*100/(select count_rn from table2 where rn=1)), "%") as cum_per_value
from table2)
select *
from table3
where cum_per_value >= 90;

/*3.If we were to remove all interest_id values which are lower than 
the total_months value we found in the previous question - 
how many total data points would we be removing?*/
with table1 as (select month_year, interest_id,
row_number() over(partition by interest_id) as rn
from cleaned_interest_metrics i_met
where interest_id is not null),
table2 as (select distinct interest_id
from table1
where rn > 6),
table3 as(
select distinct interest_id
from table1
where interest_id not in (select * from table2))
select count(interest_id) - 
(select count(interest_id) from table1 where interest_id not in(select * from table3))
from interest_metrics;

/*After removing these interests - how many unique interests are there for each month?*/
with table1 as (select month_year, interest_id,
row_number() over(partition by interest_id) as rn
from cleaned_interest_metrics i_met
where interest_id is not null),
table2 as (select distinct interest_id
from table1
where rn > 6),
table3 as(
select distinct interest_id
from table1
where interest_id not in (select * from table2))

select month_year, count(distinct interest_id) as distinct_id
from interest_metrics
where interest_id not in(select * from table3)
group by month_year;