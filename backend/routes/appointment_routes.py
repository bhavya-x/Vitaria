from fastapi import APIRouter
from pydantic import BaseModel
from database.connection import db
from utils.google_calendar import create_calendar_event

appointment_router = APIRouter()

class Appointment(BaseModel):
    doctor_name: str
    date: str
    time: str

@appointment_router.get("/")
def get_appointments():
    appointments = list(db.appointments.find({}, {"_id": 0}))
    return {"appointments": appointments}

@appointment_router.post("/appointment")
async def create_appointment(summary: str, description: str, start_time: str, end_time: str):
    event_details = {
        "summary": summary,
        "description": description,
        "start": start_time,
        "end": end_time,
        "location": "N/A"  # Add default if required
    }
    event = create_calendar_event(event_details)
    return {"message": "Appointment created", "event_id": event.get("id", "N/A")}