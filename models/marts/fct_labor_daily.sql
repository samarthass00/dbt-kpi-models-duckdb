-- Grain: one row per facility, department and day.
with completed_tasks as (
    select shift_id, count(*) as tasks_completed
    from {{ ref('stg_tasks') }}
    where task_status = 'completed'
    group by shift_id
),

shift_level as (
    select
        s.shift_date,
        e.facility_code,
        e.facility_name,
        e.department_code,
        e.department_name,
        s.scheduled_hours,
        s.worked_hours,
        s.overtime_hours,
        coalesce(t.tasks_completed, 0)                               as tasks_completed,
        coalesce(t.tasks_completed, 0) * e.standard_minutes_per_task as earned_minutes
    from {{ ref('stg_shifts') }} s
    join {{ ref('stg_employees') }} e using (employee_id)
    left join completed_tasks t using (shift_id)
)

select
    shift_date,
    facility_code,
    facility_name,
    department_code,
    department_name,
    count(*)                        as shifts,
    sum(scheduled_hours)            as scheduled_hours,
    sum(worked_hours)               as worked_hours,
    sum(overtime_hours)             as overtime_hours,
    sum(tasks_completed)            as tasks_completed,
    {{ safe_ratio('sum(tasks_completed)', 'sum(worked_hours)', 2) }}         as tasks_per_worked_hour,
    {{ safe_ratio('sum(earned_minutes)', 'sum(worked_hours) * 60') }}        as productivity_index,
    {{ safe_ratio('sum(overtime_hours)', 'sum(worked_hours)') }}             as overtime_rate
from shift_level
group by all
