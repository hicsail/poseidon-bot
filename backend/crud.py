from sqlalchemy.orm import Session

from . import models, schemas


def get_user(db: Session, user_id: int):
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

def delete_user(db: Session, user_id: int):
    db.query(models.User).filter(models.User.id == user_id).delete()
    db.commit()
    return {"message": "User deleted successfully"}


def get_chats(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Chat).offset(skip).limit(limit).all()


def get_chat(db: Session, chat_id: int):
    return db.query(models.Chat).filter(models.Chat.id == chat_id).first()


def create_user_chat(db: Session, chat: schemas.ChatCreate, user_id: int):
    db_chat = models.Chat(chat.title, owner_id=user_id)
    db.add(db_chat)
    db.commit()
    db.refresh(db_chat)
    return db_chat


def delete_chat(db: Session, chat_id: int):
    db.query(models.Chat).filter(models.Chat.id == chat_id).delete()
    db.commit()
    return {"message": "Chat deleted successfully"}


def get_messages_in_chat(db: Session, owner_id: int, skip: int = 0, limit: int = 100):
    return db.query(models.Message).filter(models.Message.chat_id == owner_id).offset(skip).limit(limit).all()


def create_message(db: Session, message: schemas.MessageCreate, chat_id: int):
    db_message = models.Message(**message.model_dump(), chat_id=chat_id)
    db.add(db_message)
    db.commit()
    db.refresh(db_message)
    return db_message


def delete_message(db: Session, message_id: int):
    db.query(models.Message).filter(models.Message.id == message_id).delete()
    db.commit()
    return {"message": "Message deleted successfully"}  
