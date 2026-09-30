"""Create small synthetic seed files for the dbt project (fictitious staff IDs and facilities)."""
from pathlib import Path

import numpy as np
import pandas as pd

SEEDS = Path(__file__).resolve().parents[1] / "seeds"
rng = np.random.default_rng(3)

facilities = pd.DataFrame(
    [("F001", "Riverside General", "West"), ("F002", "Lakeview Medical Center", "Midwest"), ("F003", "Harbor Community Hospital", "Northeast")],
    columns=["facility_code", "facility_name", "region"],
)
departments = pd.DataFrame(
    [("EVS", "Environmental Services", 25), ("PT", "Patient Transport", 20), ("FS", "Food Services", 15)],
    columns=["department_code", "department_name", "standard_minutes_per_task"],
)

employees = pd.DataFrame({
    "employee_id": [f"E{i:04d}" for i in range(1, 121)],
    "facility_code": rng.choice(facilities.facility_code, 120),
    "department_code": rng.choice(departments.department_code, 120),
})

days = pd.date_range("2025-03-01", "2025-03-28", freq="D")
shifts = employees.merge(pd.DataFrame({"shift_date": days}), how="cross").sample(frac=0.7, random_state=3)
shifts["scheduled_hours"] = 8.0
shifts["worked_hours"] = np.clip(rng.normal(8.1, 0.6, len(shifts)), 4, 12).round(2)
shifts.insert(0, "shift_id", [f"S{i:06d}" for i in range(len(shifts))])

std = departments.set_index("department_code")["standard_minutes_per_task"]
tasks_per_shift = rng.poisson(lam=(shifts["worked_hours"] * 60 * 0.8 / shifts["department_code"].map(std)).to_numpy())
tasks = shifts.loc[shifts.index.repeat(tasks_per_shift), ["shift_id", "employee_id"]].reset_index(drop=True)
tasks.insert(0, "task_id", [f"K{i:07d}" for i in range(len(tasks))])
tasks["task_status"] = rng.choice(["completed", "completed", "completed", "cancelled"], len(tasks))

for name, df in {"facilities": facilities, "departments": departments, "employees": employees,
                 "shifts": shifts.drop(columns=["facility_code", "department_code"]), "tasks": tasks}.items():
    df.to_csv(SEEDS / f"raw_{name}.csv", index=False, date_format="%Y-%m-%d")
    print(f"raw_{name}.csv {len(df)} rows")
