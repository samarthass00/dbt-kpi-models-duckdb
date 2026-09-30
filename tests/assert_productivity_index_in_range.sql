-- Singular test: a daily productivity index outside 0-1.5 signals bad hours or task data.
select *
from {{ ref('fct_labor_daily') }}
where productivity_index < 0 or productivity_index > 1.5
