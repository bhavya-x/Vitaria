import os
import pickle
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from google.auth.transport.requests import Request
import logging
from datetime import datetime

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(_name_)

SCOPES = ['https://www.googleapis.com/auth/calendar']
TIMEZONE = 'India/Kolkata'  # Set your timezone here

def authenticate_google_calendar():
    """Handles OAuth2 authentication and returns a calendar service"""
    creds = None
    if os.path.exists('token.pickle'):
        with open('token.pickle', 'rb') as token:
            creds = pickle.load(token)
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            creds.refresh(Request())
        else:
            logger.info("Starting OAuth flow...")
            flow = InstalledAppFlow.from_client_secrets_file(
                os.path.join(os.path.dirname(_file_), '..', 'credentials.json'),
                SCOPES
            )
            creds = flow.run_local_server(port=0)
            with open('token.pickle', 'wb') as token:
                pickle.dump(creds, token)
    
    return build('calendar', 'v3', credentials=creds)

def validate_datetime(dt_str):
    """Validates datetime string format"""
    try:
        if 'T' in dt_str:
            datetime.fromisoformat(dt_str.replace('Z', '+00:00'))
        else:
            datetime.strptime(dt_str, '%Y-%m-%d')
        return True
    except ValueError:
        return False

def create_calendar_event(event_details):
    """
    Creates a calendar event with proper date/time handling
    Args:
        event_details: {
            'summary': string,
            'description': string,
            'start': 'YYYY-MM-DD' or 'YYYY-MM-DDTHH:MM:SS',
            'end': 'YYYY-MM-DD' or 'YYYY-MM-DDTHH:MM:SS',
            'location': string (optional),
            'reminders': list (optional)
        }
    """
    try:
        service = authenticate_google_calendar()
        
        # Validate required fields
        if not all(key in event_details for key in ['start', 'end']):
            raise ValueError("Both start and end times are required")
        
        if not validate_datetime(event_details['start']) or not validate_datetime(event_details['end']):
            raise ValueError("Invalid datetime format. Use 'YYYY-MM-DD' or 'YYYY-MM-DDTHH:MM:SS'")
        
        # Format datetimes
        start = event_details['start'] if 'T' in event_details['start'] else f"{event_details['start']}T00:00:00"
        end = event_details['end'] if 'T' in event_details['end'] else f"{event_details['end']}T00:00:00"
        
        # Create event body
        event = {
            'summary': event_details.get('summary', 'New Event'),
            'description': event_details.get('description', ''),
            'location': event_details.get('location', ''),
            'start': {
                'dateTime': start,
                'timeZone': TIMEZONE
            },
            'end': {
                'dateTime': end,
                'timeZone': TIMEZONE
            },
            'reminders': event_details.get('reminders', {
                'useDefault': False,
                'overrides': [
                    {'method': 'popup', 'minutes': 30},
                    {'method': 'email', 'minutes': 24 * 60}
                ]
            })
        }
        
        logger.info(f"Creating event: {event}")
        created_event = service.events().insert(
            calendarId='primary',
            body=event
        ).execute()
        
        logger.info(f"Event created: {created_event.get('htmlLink')}")
        return created_event
        
    except Exception as e:
        logger.error(f"Error creating event: {str(e)}")
        raise

def get_upcoming_events(max_results=5):
    """Retrieves upcoming calendar events"""
    try:
        service = authenticate_google_calendar()
        now = datetime.utcnow().isoformat() + 'Z'  # 'Z' indicates UTC time
        events_result = service.events().list(
            calendarId='primary',
            timeMin=now,
            maxResults=max_results,
            singleEvents=True,
            orderBy='startTime'
        ).execute()
        return events_result.get('items', [])
    except Exception as e:
        logger.error(f"Error retrieving events: {str(e)}")
        raise

if _name_ == "_main_":
    # Test with a sample event
    test_event = {
        'summary': 'Integration Test',
        'description': 'Testing calendar integration',
        'start': '2023-12-15T14:00:00',
        'end': '2023-12-15T15:00:00'
    }
    create_calendar_event(test_event)
    
    # Print upcoming events
    print("Upcoming events:")
    for event in get_upcoming_events():
        start = event['start'].get('dateTime', event['start'].get('date'))
        print(f"{start} - {event['summary']}")
