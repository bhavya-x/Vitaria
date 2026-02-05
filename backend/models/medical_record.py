from pydantic import BaseModel

class MedicalRecord(BaseModel):
    user_id: int
    file_path: str

    class Config:
        orm_mode = True