from pydantic import BaseModel

from datetime import datetime

class Appointment(BaseModel):
    doctor_name: str  # Name of the doctor
    date: datetime    # Date of the appointment
    time: str         # Time of the appointment (e.g., "10:00 AM")

    class Config:
        orm_mode = True
