-- Singular test: no worked hours are lost or duplicated between staging and the mart.
with s as (select round(sum(worked_hours), 2) as h from {{ ref('stg_shifts') }}),
     m as (select round(sum(worked_hours), 2) as h from {{ ref('fct_labor_daily') }})
select s.h as staging_hours, m.h as mart_hours
from s cross join m
where abs(s.h - m.h) > 0.01
