from fastapi import APIRouter, UploadFile, File
import shutil
import os

reports_router = APIRouter()

UPLOAD_DIR = "uploads/"
os.makedirs(UPLOAD_DIR, exist_ok=True)

@reports_router.post("/")
def upload_report(file: UploadFile = File(...)):
    file_path = os.path.join(UPLOAD_DIR, file.filename)
    if os.path.exists(file_path):
        return {"error": f"File {file.filename} already exists!"}
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
    return {"message": f"File {file.filename} uploaded successfully!"}