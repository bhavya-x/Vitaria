from pydantic import BaseModel


from pydantic import BaseModel
import httpx

class ChatbotQuery(BaseModel):
    text: str
    medical_records: dict  # Placeholder for medical records

    async def get_response(self):
        # Prepare the request to your friend's chatbot
        records = self.medical_records
        
        # This function will now only return the chatbot's response without integrating with the database.
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "http://friend-chatbot/api/chat",
                json={"text": self.text}
            )
        
        return response.json()
    
#Rutuj will be integrating chatbot and the database , the above code is partially wrong 
#as the above code is integrating the chatbot and database(which is rutujs part) 
#So need to modify the code just to display the output of the chatbot(Rutuj)
