from fastapi import APIRouter, File, UploadFile
import os
from database.connection import db
from models.medical_record import MedicalRecord

upload_router = APIRouter()

@upload_router.post("/upload/")
async def upload_file(file: UploadFile = File(...)):
    file_location = f"backend/uploads/{file.filename}"
    with open(file_location, "wb+") as file_object:
        file_object.write(file.file.read())
    new_record = {"user_id": 1, "file_path": file_location}  # MongoDB dict
    db.medical_records.insert_one(new_record)
    return {"info": f"file '{file.filename}' saved at '{file_location}'"}

@upload_router.get("/records/")
def get_records():
    records = list(db.medical_records.find({}, {"_id": 0}))
    return {"records": records}