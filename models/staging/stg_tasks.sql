select
    task_id,
    shift_id,
    employee_id,
    lower(trim(task_status)) as task_status
from {{ ref('raw_tasks') }}
