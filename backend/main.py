from fastapi import FastAPI
from routes.prescription_routes import prescription_router
from routes.appointment_routes import appointment_router
from routes.chatbot_routes import chatbot_router
from routes.reports_routes import reports_router

from app.routes.appointment_routes import appointment_router
#error
app.include_router(appointment_router)


app = FastAPI(title="Smart Healthcare Assistant API")

# Registering API routes
app.include_router(prescription_router, prefix="/prescriptions", tags=["Prescriptions"])
app.include_router(appointment_router, prefix="/appointments", tags=["Appointments"])
app.include_router(chatbot_router, prefix="/chatbot", tags=["Chatbot"])
app.include_router(reports_router, prefix="/reports", tags=["Reports"])

@app.get("/")
def home():
    return {"message": "Welcome to Vitaria"}
