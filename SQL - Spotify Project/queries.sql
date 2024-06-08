-- Q1: Find total active users each day
select event_date, count(distinct user_id) AS active_users
from spotify_db.activity
group by event_date;

-- Q2: Find total active users each week
select week(event_date, 0) as 'week', count(distinct user_id) as active_users
from spotify_db.activity
group by `week`;

-- Q3: Date-wise total number of users who made purchase same day they installed the app
with cte as
(select T1.event_date, T1.user_id
from spotify_db.activity T1
join spotify_db.activity T2
on T1.user_id = T2.user_id and
T1.event_date = T2.event_date 
and T1.event_name = 'app-installed' and T2.event_name = 'app-purchase')

select T.event_date, count(distinct C.user_id) as cnt
from spotify_db.activity T
left join cte C
on T.user_id = C.user_id
group by T.event_date;

-- Q4. Percentage of paid users in India, USA and all other countries as Others
with cte as
(select case when country in ('India', 'USA') then country else 'others' end as country, 
count(distinct user_id) as cnt
from spotify_db.activity
where event_name = 'app-purchase'
group by case when country in ('India', 'USA') then country else 'others' end)

select country, round(cnt/(select sum(cnt) from cte) * 100, 2) as 'paid_user_percentage'
from cte;

-- Q5: Among all users who installed app on a given day, how many made a purchase on the next day?
-- Give day-wise count.
select T2.event_date, count(T1.user_id) as cnt
from spotify_db.activity T1
right join spotify_db.activity T2
on T1.user_id = T2.user_id
and T1.event_name = 'app-installed' and  T2.event_name = 'app-purchase'
and T2.event_date = date_add(T1.event_date, interval 1 day)
group by T2.event_date;
