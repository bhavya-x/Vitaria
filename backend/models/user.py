from pydantic import BaseModel, EmailStr
from typing import Optional

class User(BaseModel):
    name: str
    email: EmailStr
    age: Optional[int]
    gender: Optional[str]
    password: str

    class Config:
        schema_extra = {
            "example": {
                "name": "John Doe",
                "email": "johndoe@example.com",
                "age": 25,
                "gender": "Male",
                "password": "your_password"
            }
        }