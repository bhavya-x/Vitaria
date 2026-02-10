from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from database.connection import db
from bson.objectid import ObjectId

# Define the router
auth_router = APIRouter()

# Define the models for request bodies
class LoginRequest(BaseModel):
    email: str
    password: str

class SignupRequest(BaseModel):
    name: str
    email: str
    age: Optional[int]
    gender: Optional[str]
    password: str

# Replace mock database with MongoDB collection
users_collection = db["users"]

# Login endpoint
@auth_router.post("/login")
def login(request: LoginRequest):
    user = users_collection.find_one({"email": request.email})
    if not user or user['password'] != request.password:
        raise HTTPException(status_code=401, detail="Invalid email or password")
    return {"message": "Login successful", "user": {"id": str(user["_id"]), "name": user["name"], "email": user["email"]}}

# Signup endpoint
@auth_router.post("/signup")
def signup(request: SignupRequest):
    if users_collection.find_one({"email": request.email}):
        raise HTTPException(status_code=400, detail="Email already registered")
    new_user = {
        "name": request.name,
        "email": request.email,
        "age": request.age,
        "gender": request.gender,
        "password": request.password
    }
    result = users_collection.insert_one(new_user)
    return {"message": "Signup successful", "user": {"id": str(result.inserted_id), "name": new_user["name"], "email": new_user["email"]}}