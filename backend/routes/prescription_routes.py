from fastapi import APIRouter
from models.prescription import Prescription
from database.connection import db

prescription_router = APIRouter()

@prescription_router.post("/")
def add_prescription(prescription: Prescription):
    db.prescriptions.insert_one(prescription.dict())
    return {"message": "Prescription added successfully!"}

@prescription_router.get("/")
def get_prescriptions():
    prescriptions = list(db.prescriptions.find({}, {"_id": 0}))
    return {"prescriptions": prescriptions}