from pydantic import BaseModel, validator
from datetime import datetime
from typing import List

class Prescription(BaseModel):
    medicines: List[str]
    dosage: str
    duration: int
    start_date: str  # e.g., "2025-02-10"
    created_at: datetime = datetime.utcnow()
    user_id: int

    @validator('start_date', pre=True)
    def parse_start_date(cls, value):
        return datetime.strptime(value, "%Y-%m-%d").isoformat()