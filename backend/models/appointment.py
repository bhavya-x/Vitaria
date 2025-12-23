from pydantic import BaseModel

class Appointment(BaseModel):
    doctor_name: str
    date: str
    time: str
