from pydantic import BaseModel

class ChatbotQuery(BaseModel):
    text: str
