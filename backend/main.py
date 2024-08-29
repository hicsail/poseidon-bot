from contextlib import asynccontextmanager
from typing import List
from fastapi import Depends, FastAPI, HTTPException, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session
from . import crud, models, schemas, database
import ollama
import uuid
import chromadb
import torch
from transformers import AutoTokenizer, AutoModel

# Setup database models
models.Base.metadata.create_all(bind=database.engine)

# Initialize FastAPI app
app = FastAPI()

# CORS configuration
origins = [
    "http://localhost",
    "http://localhost:51201",
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],
    allow_headers=["X-Requested-With", "Content-Type", "Access-Control-Allow-Origin"],
)

# Initialize Chroma client and collection
chroma_client = chromadb.HttpClient(host='localhost', port=8000)
documents = ["Hello world", "Chroma is great for embeddings"]
collection = chroma_client.get_or_create_collection(name="my_collection")
collection.add(documents=documents, ids=['0', '1'])

# Define the embedding function
class LlamaEmbeddingFunction(chromadb.EmbeddingFunction):
    def __init__(self, model_name: str):
        self.tokenizer = AutoTokenizer.from_pretrained(model_name)
        self.model = AutoModel.from_pretrained(model_name)
    
    def __call__(self, input: chromadb.Documents) -> chromadb.Embeddings:
        inputs = self.tokenizer(input, return_tensors='pt', padding=True, truncation=True)
        with torch.no_grad():
            outputs = self.model(**inputs)
        embeddings = outputs.last_hidden_state.mean(dim=1)
        return embeddings.cpu().numpy()

# Dependency for database session
def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# Root endpoint
@app.get("/")
async def root():
    return {"message": "Hello World"}

# Query endpoint
@app.post('/query')
def query(input: schemas.Input, db: Session = Depends(get_db)):
    try:
        chroma_result = collection.query(
            query_texts=input.query,
            n_results=len(crud.get_documents()),
        )

        messages = [{'role': 'user', 'content': doc} for doc in chroma_result['documents'][0]]
        chat_history = crud.get_messages_in_chat(db, chat_id=input.chat_id)
        messages.extend({
            'role': chat_message.typeOfMessage,
            'content': chat_message.message,
        } for chat_message in chat_history)
        messages.append({'role': 'user', 'content': input.query})
        
        ollama_result = ollama.chat(model='llama3.1', messages=messages, stream=True)
        response = "".join(chunk['message']['content'] for chunk in ollama_result)
        
        crud.create_message(db, id=str(uuid.uuid4()), message=input.query, chat_id=input.chat_id, typeOfMessage="user")
        response_id = uuid.uuid4()
        crud.create_message(db, id=response_id, message=response, chat_id=input.chat_id, typeOfMessage="assistant")

        return JSONResponse(content={
            "message": response,
            "chat_id": input.chat_id,
            "typeOfMessage": "assistant",
            "id": str(response_id)
        })
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Document endpoints
@app.post("/document")
def create_document(input: schemas.DocumentInput):
    for document in input.document:
        id = str(uuid.uuid4())
        collection.add(documents=[document], ids=[id])
    return {"document": input.document}

@app.get("/document")
def get_document():
    return {"document": str(crud.get_documents())}

# Chat endpoints
@app.get("/chats/{chat_id}")
def get_messages(chat_id: str):
    return {"chat_id": chat_id}

@app.get("/chats")
def get_chats(db: Session = Depends(get_db)):
    chats = crud.get_chats(db)
    response = []
    for chat in chats:
        messages = crud.get_messages_in_chat(db, chat.id)
        json_messages = [{
            "message": message.message,
            "chat_id": message.chat_id,
            "typeOfMessage": message.typeOfMessage,
            "id": message.id
        } for message in messages]
        response.append({
            "chat_id": chat.id,
            "title": chat.title,
            "owner_id": chat.owner_id,
            "messages": json_messages
        })
    return response

@app.post("/chats/{chat_id}")
def create_message(input: schemas.MessageInput, db: Session = Depends(get_db)):
    crud.create_message(db, id=str(uuid.uuid4()), message=input.message, chat_id=input.chat_id, typeOfMessage="user")
    return {"chat_title": input.chat_id, "message": input.message}

@app.post("/chats")
def create_chat(input: schemas.ChatInput, db: Session = Depends(get_db)):
    chat = crud.create_user_chat(db, input.chat_title, input.user_id)
    return {"title": chat.title, "owner_id": chat.owner_id, "chat_id": chat.id, "messages":[]}

@app.delete("/messages/")
def delete_message(input: schemas.DeleteMessageInput, db: Session = Depends(get_db)):
    message = crud.delete_message(db, input.message_id)
    return {"message": message}

@app.delete("/chats/")
def delete_chat(input: schemas.DeleteChatInput, db: Session = Depends(get_db)):
    message = crud.delete_chat(db, input.chat_id)
    return {"message": message}

# User endpoints
@app.post("/users", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db=db, user=user)

@app.get("/users", response_model=List[schemas.User])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    return crud.get_users(db, skip=skip, limit=limit)

@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(user_id: str, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

# Lifespan event for Chroma client
@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        yield
    finally:
        await chroma_client.close()

# Main entry point
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)
