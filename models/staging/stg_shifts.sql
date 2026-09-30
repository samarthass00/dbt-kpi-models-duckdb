select
    shift_id,
    employee_id,
    cast(shift_date as date)            as shift_date,
    cast(scheduled_hours as double)     as scheduled_hours,
    cast(worked_hours as double)        as worked_hours,
    greatest(worked_hours - 8.0, 0)     as overtime_hours
from {{ ref('raw_shifts') }}
