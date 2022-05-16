with t1 as(
select distinct visit_id, user_id
from users u
inner join events e
on e.cookie_id = u.cookie_id
group by visit_id, user_id, event_type)

select e.visit_id, user_id, event_time as visit_start_time,
sum(case when event_type = 1 then 1 else 0 end) page_views,
sum(case when event_type = 2 then 1 else 0 end) cart_adds,
sum(case when event_type = 3 then 1 else 0 end) purchase,
sum(case when event_type =4 then 1 else 0 end) impression,
sum(case when event_type = 5 then 1 else 0 end) click, campaign_name
from events e
inner join t1
on t1.visit_id = e.visit_id
left join campaign_identifier as c
on e.event_time between c.start_date and c.end_date
group by visit_id
having user_id = 1;
