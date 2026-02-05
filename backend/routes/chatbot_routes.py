import os
from fastapi import APIRouter
from models.chatbot import ChatbotQuery

chatbot_router = APIRouter()

@chatbot_router.post("/")
async def chat_with_ai(query: ChatbotQuery):
    response = await query.get_response()
    return {"response": response}