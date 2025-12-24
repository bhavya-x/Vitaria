from fastapi import APIRouter, File, UploadFile, Depends
from sqlalchemy.orm import Session
import os
from database.connection import get_db
from models.medical_record import MedicalRecord  # Ensure this model exists

upload_router = APIRouter()

@upload_router.post("/upload/")
async def upload_file(file: UploadFile = File(...), db: Session = Depends(get_db)):
    file_location = f"backend/uploads/{file.filename}"
    with open(file_location, "wb+") as file_object:
        file_object.write(file.file.read())
    
    # Save file path to the database
    new_record = MedicalRecord(user_id=1, file_path=file_location)  # Replace with actual user ID
    db.add(new_record)
    db.commit()
    db.refresh(new_record)
    
    return {"info": f"file '{file.filename}' saved at '{file_location}'"}

@upload_router.get("/records/")
def get_records(db: Session = Depends(get_db)):
    records = db.query(MedicalRecord).all()
    return records
