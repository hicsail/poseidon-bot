from contextlib import asynccontextmanager
from typing import Union
from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session
# import crud, models, schemas, database
from . import crud, models, schemas, database
from llama_index import LLamaIndex
from flask import Flask, request, jsonify


# from .embeddings import LlamaEmbeddingFunction
import chromadb
# from chromadb.server import Server
# from embeddings import LlamaEmbeddingFunction

models.Base.metadata.create_all(bind=database.engine)
app = FastAPI()
chroma_client = chromadb.Client()
llama_index = LLamaIndex()
def main():
    documents = ["Hello world", "Chroma is great for embeddings"]
    # embedding_function = LlamaEmbeddingFunction(model_name="huggingface/llama")
    # embeddings = embedding_function(documents)
    # print(embeddings)      

    # server = Server(host='localhost', port=8000)
    # server.start()

    chroma_client = chromadb.HttpClient(host='localhost', port=8000)
    collection = chroma_client.get_or_create_collection(name="my_collection")
    collection.add(documents=documents, ids=['0', '1'])
if __name__ == "__main__":
    main()

# client = chromadb.PersistentClient(path="backend/temp.data")
 
@app.route('/query', methods=['POST'])
def query():
    data = request.json
    query_text = data.get('query')

    chroma_result = chroma_client.query(query_text)
    
    llama_result = llama_index.query(query_text)

    return jsonify({
        'chroma_result': chroma_result,
        'llama_result': llama_result
    })

if __name__ == '__main__':
    app.run(debug=True)
    
@asynccontextmanager
async def lifespan(app: FastAPI):
    try:
        yield
    finally:
        await client.close()

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
def get_chats(q: str = None):
    #read data from database
    return {"q": q}

@app.post("/chats/{chat_id}")
def create_message(chat_id: str, q: str = None):
    #write data to database
    return {"chat_id": chat_id, "q": q}

@app.post("/chats")
def create_chat(q: str = None):
    #write data to database
    return {"q": q}

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