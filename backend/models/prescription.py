from pydantic import BaseModel
from datetime import datetime

class Prescription(BaseModel):
    medicine_name: str
    dosage: str
    duration: int
    time: str
    created_at: datetime = datetime.utcnow()
