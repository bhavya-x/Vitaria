from pydantic import BaseModel
from datetime import datetime
from typing import List

class Prescription(BaseModel):
    medicines: List[str]  # List of prescribed medicines
    dosage: str
    duration: int  # Duration in days
    start_date: datetime  # Start date for the prescription
    created_at: datetime = datetime.utcnow()
    user_id: int  # ID of the user associated with the prescription
