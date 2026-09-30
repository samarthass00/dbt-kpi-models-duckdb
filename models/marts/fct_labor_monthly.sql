-- Monthly roll-up recomputed from sums (never an average of daily ratios).
select
    date_trunc('month', shift_date)::date as month_start,
    facility_name,
    department_name,
    sum(shifts)          as shifts,
    sum(worked_hours)    as worked_hours,
    sum(overtime_hours)  as overtime_hours,
    sum(tasks_completed) as tasks_completed,
    {{ safe_ratio('sum(tasks_completed)', 'sum(worked_hours)', 2) }} as tasks_per_worked_hour,
    {{ safe_ratio('sum(overtime_hours)', 'sum(worked_hours)') }}     as overtime_rate
from {{ ref('fct_labor_daily') }}
group by all
