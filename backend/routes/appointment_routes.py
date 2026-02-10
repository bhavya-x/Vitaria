from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime
from database.connection import db
from utils.google_calendar import create_calendar_event
import logging

appointment_router = APIRouter(tags=["Appointments"])
logger = logging.getLogger(_name_)

class Appointment(BaseModel):
    doctor_name: str
    date: str  # Format: YYYY-MM-DD
    time: str  # Format: HH:MM

class CalendarEvent(BaseModel):
    summary: str
    description: str
    start_time: str  # Format: YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS
    end_time: str    # Format: YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS
    location: str = "N/A"

def validate_datetime(dt_str: str) -> bool:
    """Validate datetime string format"""
    try:
        if 'T' in dt_str:
            datetime.fromisoformat(dt_str.replace('Z', '+00:00'))
        else:
            datetime.strptime(dt_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False

@appointment_router.get("/", summary="Get all appointments")
async def get_appointments():
    """Retrieve all appointments from database"""
    try:
        appointments = list(db.appointments.find({}, {"_id": 0}))
        return {"appointments": appointments}
    except Exception as e:
        logger.error(f"Error fetching appointments: {str(e)}")
        raise HTTPException(status_code=500, detail="Failed to fetch appointments")

@appointment_router.post("/appointment", summary="Create new appointment")
async def create_appointment(event: CalendarEvent):
    """
    Create a new appointment in both database and Google Calendar
    
    Accepts either:
    - Date only (YYYY-MM-DD) for all-day events
    - Full datetime (YYYY-MM-DDTHH:MM:SS) for timed events
    """
    try:
        # Validate datetime formats
        if not validate_datetime(event.start_time) or not validate_datetime(event.end_time):
            raise HTTPException(
                status_code=400,
                detail="Invalid datetime format. Use YYYY-MM-DD or YYYY-MM-DDTHH:MM:SS"
            )
        
        # Prepare event details
        event_details = {
            "summary": event.summary,
            "description": event.description,
            "start": event.start_time,
            "end": event.end_time,
            "location": event.location
        }
        
        logger.info(f"Creating calendar event: {event_details}")
        
        # Create Google Calendar event
        calendar_event = create_calendar_event(event_details)
        
        # Store in database (optional)
        db.appointments.insert_one({
            "summary": event.summary,
            "description": event.description,
            "start_time": event.start_time,
            "end_time": event.end_time,
            "calendar_event_id": calendar_event.get("id"),
            "calendar_link": calendar_event.get("htmlLink")
        })
        
        return {
            "message": "Appointment created successfully",
            "event_id": calendar_event.get("id"),
            "calendar_link": calendar_event.get("htmlLink"),
            "is_all_day": 'T' not in event.start_time
        }
        
    except Exception as e:
        logger.error(f"Error creating appointment: {str(e)}")
        raise HTTPException(status_code=500, detail=str(e))