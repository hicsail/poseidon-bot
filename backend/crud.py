import chromadb

from sqlalchemy.orm import Session
import uuid

from . import models, schemas

chroma_client = chromadb.HttpClient(host='localhost', port=8000)


def add_document(document: str, doc_id: str):
    collection = chroma_client.get_or_create_collection(name="my_collection")
    collection.add(documents=[document], ids=[doc_id])

def get_documents():
    collection = chroma_client.get_or_create_collection(name="my_collection")
    return collection.peek()

def get_user(db: Session, user_id: str):
    return db.query(models.User).filter(models.User.id == user_id).first()


def get_user_by_email(db: Session, email: str):
    return db.query(models.User).filter(models.User.email == email).first()


def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()


def create_user(db: Session, user: schemas.UserCreate):
    fake_hashed_password = user.password + "notreallyhashed"
    db_user = models.User(email=user.email, hashed_password=fake_hashed_password)
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def delete_user(db: Session, user_id: str):
    db.query(models.User).filter(models.User.id == user_id).delete()
    db.commit()
    return {"message": "User deleted successfully"}


def get_chats(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Chat).offset(skip).limit(limit).all()


def get_chat(db: Session, chat_id: str):
    return db.query(models.Chat).filter(models.Chat.id == chat_id).first()


def create_user_chat(db: Session, chat_title: str, user_id: str):
    myuuid = uuid.uuid4()
    db_chat = models.Chat(id=str(myuuid), title=chat_title, owner_id=user_id)
    db.add(db_chat)
    db.commit()
    # db.refresh(db_chat)
    return db_chat


def delete_chat(db: Session, chat_id: str):
    db.query(models.Chat).filter(models.Chat.id == chat_id).delete()
    db.commit()
    return {"message": "Chat deleted successfully"}


def get_messages_in_chat(db: Session, chat_id: str, skip: int = 0, limit: int = 100):
    history = db.query(models.Message).filter(models.Message.chat_id == chat_id).offset(skip).limit(limit).all()
    return history


def get_user_messages_in_chat(db: Session, chat_id: str, skip: int = 0, limit: int = 100):
    history = db.query(models.Message).filter(models.Message.chat_id == chat_id).filter(models.Message.typeOfMessage == "user").offset(skip).limit(limit).all()
    messages = [msg.message for msg in history]
    return messages


def get_assistant_messages_in_chat(db: Session, chat_id: str, skip: int = 0, limit: int = 100):
    history = db.query(models.Message).filter(models.Message.chat_id == chat_id).filter(models.Message.typeOfMessage == "assistant").offset(skip).limit(limit).all()
    messages = [msg.message for msg in history]
    return messages


def create_message(db: Session, message: str, chat_id: str, typeOfMessage: str):
    print(chat_id)
    myuuid = uuid.uuid4()
    db_message = models.Message(id=myuuid, message=message, chat_id=chat_id, typeOfMessage=typeOfMessage)
    print(db)
    print(db_message)
    db.add(db_message)
    db.commit()
    # db.refresh(db_message)
    return db_message


def delete_message(db: Session, message_id: str):
    db.query(models.Message).filter(models.Message.id == message_id).delete()
    db.commit()
    return {"message": "Message deleted successfully"}  
