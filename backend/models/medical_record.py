from pydantic import BaseModel

class MedicalRecord(BaseModel):
    user_id: int  # ID of the user associated with the medical record
    file_path: str  # Path to the uploaded file
