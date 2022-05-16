create table clean_weekly_sales as 
 select str_to_date(week_date, "%d/%m/%Y") as week_date,
 week(str_to_date(week_date, "%d/%m/%Y")) as week_number,
 month(str_to_date(week_date, "%d/%m/%Y")) as month_number,
 year(str_to_date(week_date, "%d/%m/%Y")) as calendar_year,
 region, platform,
 case
	when right(segment, 1) = "1" then 1
    when right(segment, 1) = "2" then 2
    when right(segment, 1) = "3" then 3
    when right(segment, 1) = "4" then 4
    else "unknown"
end segment,
case
	when right(segment, 1) = "1" then "Young Adults"
    when right(segment, 1) = "2" then "Middle Aged"
    when right(segment, 1) = "3" or right(segment, 1) = "4" then "Retirees"
    else "unknown"
end "age_band", customer_type,
case
	when left(segment, 1) = "C" then "Couples"
    when left(segment, 1) = "F" then "Families"
    else "unknown"
end "demographic", transactions, sales,
round(sales/transactions, 2) as avg_transaction
from weekly_sales;

drop table clean_weekly_sales;