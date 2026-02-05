from pydantic import BaseModel, validator
from datetime import datetime

class Report(BaseModel):
    filename: str
    uploaded_at: str

    @validator('uploaded_at', pre=True)
    def parse_uploaded_at(cls, value):
        return datetime.strptime(value, "%Y-%m-%d %H:%M:%S").isoformat()