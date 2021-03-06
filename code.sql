Question 1:

select *
from subscriptions
limit 100;

Question 2:

select min (subscription_start), max(subscription_start) from subscriptions;


Questions 3-8:


With months as
(select
'2017-01-01' as first_day,
'2017-01-31' as last_day
UNION
select
'2017-02-01' as first_day,
'2017-02-28' as last_day
UNION
select
'2017-03-01' as first_day,
'2017-03-31' as last_day),
cross_join as
(select * from subscriptions
cross join months),
status as
(select
id,
first_day as month,
case when
(subscription_start < first_day) AND (subscription_end > first_day OR subscription_end is NULL) AND (segment = 87)
 then 1
 else 0
 end as is_active_87,
 case when
(subscription_start < first_day) AND (subscription_end > first_day OR subscription_end is NULL) AND (segment = 30)
 then 1
 else 0
 end as is_active_30,
  case when
 (subscription_end BETWEEN first_day and last_day) and (segment = 87)
 then 1
 else 0
 end as is_canceled_87,
  case when
 (subscription_end BETWEEN first_day and last_day) and (segment = 30)
 then 1
 else 0
 end as is_canceled_30
 from cross_join),
 status_aggregate as
 (select
  month,
 sum(is_active_87) as sum_active_87,
 sum(is_active_30) as sum_active_30,
 sum(is_canceled_87) as sum_canceled_87,
 sum(is_canceled_30) as sum_canceled_30
 from status
  group by month)
  select 
  month,
  round(1.0 * sum_canceled_87/sum_active_87,3) as churn_rate_87,
    round(1.0 * sum_canceled_30/sum_active_30,3) as churn_rate_30
    from status_aggregate;


Question 9:


With months as
(select
'2017-01-01' as first_day,
'2017-01-31' as last_day
UNION
select
'2017-02-01' as first_day,
'2017-02-28' as last_day
UNION
select
'2017-03-01' as first_day,
'2017-03-31' as last_day),
cross_join as
(select * from subscriptions
cross join months),
status as
(select
id,
first_day as month,
 segment,
case when
(subscription_start < first_day) AND (subscription_end > first_day OR subscription_end is NULL)
 then 1
 else 0
 end as is_active,
  case when
 (subscription_end BETWEEN first_day and last_day)
 then 1
 else 0
 end as is_canceled
 from cross_join),
 status_aggregate as
 (select
  month,
  segment,
 sum(is_active) as sum_active,
 sum(is_canceled) as sum_canceled
 from status
  group by month,segment)
  select 
  month, segment,
  round(1.0 * sum_canceled/sum_active,3) as churn_rate
    from status_aggregate
    order by segment asc;
