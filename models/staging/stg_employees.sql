select
    e.employee_id,
    e.facility_code,
    f.facility_name,
    f.region,
    e.department_code,
    d.department_name,
    d.standard_minutes_per_task
from {{ ref('raw_employees') }} e
join {{ ref('raw_facilities') }} f using (facility_code)
join {{ ref('raw_departments') }} d using (department_code)
