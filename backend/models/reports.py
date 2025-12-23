from pydantic import BaseModel

class Report(BaseModel):
    filename: str
    uploaded_at: str
