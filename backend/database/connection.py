from pymongo import MongoClient
import os
from dotenv import load_dotenv

load_dotenv()

MONGO_URL = os.getenv("MONGO_URL")
if not MONGO_URL:
    raise ValueError("MONGO_URL not found in .env file")
try:
    client = MongoClient(MONGO_URL)
    client.server_info()  # Test connection
    db = client["Vitaria"]
except Exception as e:
    raise ConnectionError(f"Failed to connect to MongoDB: {e}")