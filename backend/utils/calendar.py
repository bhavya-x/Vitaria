from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from datetime import timedelta

creds = Credentials.from_authorized_user_file('credentials/credentials.json')

def create_calendar_event(medicines, start_date, duration, user_id):
    if not isinstance(start_date, datetime):
        raise ValueError("start_date must be a datetime object")
    service = build('calendar', 'v3', credentials=creds)
    event = {
        'summary': 'Medication Reminder',
        'description': ', '.join(medicines),
        'start': {'dateTime': start_date.isoformat(), 'timeZone': 'America/Los_Angeles'},
        'end': {'dateTime': (start_date + timedelta(days=duration)).isoformat(), 'timeZone': 'America/Los_Angeles'},
    }
    event = service.events().insert(calendarId='primary', body=event).execute()
    return event