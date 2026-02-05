import os
import pickle
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from google.auth.transport.requests import Request

SCOPES = ['https://www.googleapis.com/auth/calendar']

def authenticate_google_calendar():
    creds = None
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            flow = InstalledAppFlow.from_client_secrets_file('credentials.json', SCOPES)
            creds = flow.run_local_server(port=0)
        with open('token.pickle', 'wb') as token:
            pickle.dump(creds, token)
    service = build('calendar', 'v3', credentials=creds)
    return service

def create_calendar_event(event_details):
    service = authenticate_google_calendar()
    event = {
        'summary': event_details.get('summary', 'Event'),
        'location': event_details.get('location', 'N/A'),
        'description': event_details.get('description', ''),
        'start': {'dateTime': event_details['start'], 'timeZone': 'America/Los_Angeles'},
        'end': {'dateTime': event_details['end'], 'timeZone': 'America/Los_Angeles'},
        'reminders': {'useDefault': False, 'overrides': [{'method': 'email', 'minutes': 10}, {'method': 'popup', 'minutes': 10}]},
    }
    event = service.events().insert(calendarId='primary', body=event).execute()
    return event