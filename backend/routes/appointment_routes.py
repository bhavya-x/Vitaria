from fastapi import APIRouter
from pydantic import BaseModel
from database.connection import db

appointment_router = APIRouter()

class Appointment(BaseModel):
    doctor_name: str
    date: str  # e.g., "2025-02-10"
    time: str  # e.g., "10:30 AM"

@appointment_router.post("/")
def add_appointment(appointment: Appointment):
    db.appointments.insert_one(appointment.dict())
    return {"message": "Appointment added successfully!"}

@appointment_router.get("/")
def get_appointments():
    appointments = list(db.appointments.find({}, {"_id": 0}))
    return {"appointments": appointments}

