from contextlib import asynccontextmanager
from typing import Union
from fastapi import Depends, FastAPI, HTTPException, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel
from sqlalchemy.orm import Session
# import crud, models, schemas, database
from . import crud, models, schemas, database
import ollama

# from .embeddings import LlamaEmbeddingFunction
import chromadb
# from chromadb.server import Server
# from embeddings import LlamaEmbeddingFunction

models.Base.metadata.create_all(bind=database.engine)
app = FastAPI()

origins = [
    "http://localhost",
    "http://localhost:51201",
    "*",
]

chroma_client = chromadb.Client()

documents = ["Hello world", "Chroma is great for embeddings"]
chroma_client = chromadb.HttpClient(host='localhost', port=8000)
collection = chroma_client.get_or_create_collection(name="my_collection")
collection.add(documents=documents, ids=['0', '1'])

def main():
    # embedding_function = LlamaEmbeddingFunction(model_name="huggingface/llama")
    # embeddings = embedding_function(documents)
    # print(embeddings)      

    # server = Server(host='localhost', port=8000)
    # server.start()
    print("HI")

if __name__ == "__main__":
    main()

# client = chromadb.PersistentClient(path="backend/temp.data")
class Input(BaseModel):
    query: str
 
@app.post('/query')
def query(input: Input):
    try:
        chroma_result = collection.query(
            query_texts=input.query,
            n_results=2
        )

        print(chroma_result)
        print(chroma_result['documents'][0][0])

        ollama_result = ollama.chat(
            model='llama3.1',
            messages=[{'role': 'user', 'content': chroma_result['documents'][0][0] + input.query}],
        )

        print(ollama_result["message"]["content"])

        response = {
            'text': ollama_result["message"]["content"],
        }

        return JSONResponse(content=response)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == '__main__':
    app.run(debug=True)
    
@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        yield
    finally:
        await chroma_client.close()

@app.get("/")
async def root():
    return {"message": "Hello World"}

def get_db():
    db = database.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def get_root():
    return {"Hello": "World"}

@app.get("/chats/{chat_id}")
def get_messages(chat_id: str, q: str = None):
    #read data from database
    return {"chat_id": chat_id, "q": q}

@app.get("/chats")
def get_chats(db: Session = Depends(get_db)):
    chats = crud.get_chats(db)
    return {"title" : chats[0].title}

@app.post("/chats/{chat_id}")
def create_message(input: schemas.MessageCreate, db: Session = Depends(get_db)):
    print(input)
    crud.create_message(db, input)
    return {"chat_title": input.chat_id, "message": input.message}

@app.post("/chats")
def create_chat(input: schemas.ChatCreate, db: Session = Depends(get_db)):
    chat = crud.create_user_chat(db, input)
    return {"chat_title": input.title, "userId": input.userId, "chat_id": chat.id}

@app.delete("/messages/{message_id}")
def delete_message(message_id: str):
    #delete data from database
    return {"message_id": message_id}

@app.delete("/chats/{chat_id}")
def delete_chat(chat_id: str):
    #delete data from database
    return {"chat_id": chat_id}

@app.post("/users", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db=db, user=user)

@app.get("/users", response_model=list[schemas.User])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = crud.get_users(db, skip=skip, limit=limit)
    return users

@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(user_id: int, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # Allows all origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "OPTIONS"],  # Allows all methods
    allow_headers=["X-Requested-With", "Content-Type", "Access-Control-Allow-Origin"],  # Allows all headers
    # expose_headers=["*"], # Exposes all headers
)