from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from datetime import timedelta

def create_calendar_event(medicines, start_date, duration, user_id):
    # Load credentials from a file or environment
    creds = Credentials.from_authorized_user_file('path/to/credentials.json')
    service = build('calendar', 'v3', credentials=creds)

    event = {
        'summary': 'Medication Reminder',
        'description': ', '.join(medicines),
        'start': {
            'dateTime': start_date.isoformat(),
            'timeZone': 'America/Los_Angeles',  # Adjust as necessary
        },
        'end': {
            'dateTime': (start_date + timedelta(days=duration)).isoformat(),
            'timeZone': 'America/Los_Angeles',
        },
    }

    service.events().insert(calendarId='primary', body=event).execute()
