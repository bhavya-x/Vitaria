from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from datetime import timedelta

#for integrating the google calendar api 
#need to download the json file(check requirements)
creds = Credentials.from_authorized_user_file('credentials/credentials.json')

def create_calendar_event(medicines, start_date, duration, user_id):
    # Load credentials from a file or environment
    creds = Credentials.from_authorized_user_file('path/to/credentials.json')
    service = build('calendar', 'v3', credentials=creds)

    event = {
        'summary': 'Medication Reminder',
        'description': ', '.join(medicines),
        'start': {
            'dateTime': start_date.isoformat(),
            'timeZone': 'America/Los_Angeles',  #need to update it to the user's timezone
        },
        'end': {
            'dateTime': (start_date + timedelta(days=duration)).isoformat(),
            'timeZone': 'America/Los_Angeles',
        },
    }

    service.events().insert(calendarId='primary', body=event).execute()
