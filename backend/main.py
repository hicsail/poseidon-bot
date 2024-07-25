from typing import Union
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def get_root():
    return {"Hello": "World"}

@app.get("/chats/{chat_id}")
def get_messages(chat_id: str, q: str = None):
    #read data from database
    return {"chat_id": chat_id, "q": q}

@app.get("/chats/")
def get_chats(q: str = None):
    #read data from database
    return {"q": q}

@app.post("/chats/{chat_id}")
def create_message(chat_id: str, q: str = None):
    #write data to database
    return {"chat_id": chat_id, "q": q}

@app.post("/chats/")
def create_chat(q: str = None):
    #write data to database
    return {"q": q}

@app.delete("/chats/{chat_id}")
def delete_message(chat_id: str, message_id: str):
    #delete data from database
    return {"chat_id": chat_id}

@app.delete("/chats/{chat_id}")
def delete_chat(chat_id: str):
    #delete data from database
    return {"chat_id": chat_id}

