from typing import Union
from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy.orm import Session

from . import crud, models, schemas
from .database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

def get_db():
    db = SessionLocal()
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

@app.post("/users/", response_model=schemas.User)
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_email(db, email=user.email)
    if db_user:
        raise HTTPException(status_code=400, detail="Email already registered")
    return crud.create_user(db=db, user=user)


@app.get("/users/", response_model=list[schemas.User])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    users = crud.get_users(db, skip=skip, limit=limit)
    return users


@app.get("/users/{user_id}", response_model=schemas.User)
def read_user(user_id: int, db: Session = Depends(get_db)):
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user


@app.post("/users/{user_id}/items/", response_model=schemas.Item)
def create_item_for_user(
    user_id: int, item: schemas.ItemCreate, db: Session = Depends(get_db)
):
    return crud.create_user_item(db=db, item=item, user_id=user_id)


@app.get("/items/", response_model=list[schemas.Item])
def read_items(skip: int = 0, limit: int = 100, db: Session = Depends(get_db)):
    items = crud.get_items(db, skip=skip, limit=limit)
    return items