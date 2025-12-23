from google.oauth2 import service_account
from googleapiclient.discovery import build
import datetime

SCOPES = ["https://www.googleapis.com/auth/calendar"]

def create_calendar_event(summary, start_time, end_time):
    credentials = service_account.Credentials.from_service_account_file("path_to_your_credentials.json", scopes=SCOPES)
    service = build("calendar", "v3", credentials=credentials)

    event = {
        "summary": summary,
        "start": {"dateTime": start_time, "timeZone": "UTC"},
        "end": {"dateTime": end_time, "timeZone": "UTC"}
    }
    
    event = service.events().insert(calendarId="primary", body=event).execute()
    return event["id"]
