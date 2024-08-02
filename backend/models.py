from sqlalchemy import Boolean, Column, ForeignKey, Integer, String
from backend.database import Base
from sqlalchemy.orm import relationship
import chromadb

chroma_client = chromadb.HttpClient(host='localhost', port=8000)
class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    email = Column(String, unique=True, index=True)
    username = Column(String, unique=True, index=True)
    hashed_password = Column(String)

    chats = relationship("Chat", back_populates="owner")

class Chat(Base):
    __tablename__ = "chats"

    id = Column(Integer, primary_key=True)
    owner_id = Column(Integer, ForeignKey("users.id"))
    title = Column(String)

    owner = relationship("User", back_populates="chats")
    messages = relationship("Message", back_populates="chat")

class Message(Base):
    __tablename__ = "messages"

    id = Column(Integer, primary_key=True)
    chat_id = Column(Integer, ForeignKey("chats.id"))
    message = Column(String)
    typeOfMessage = Column(String)

    chat = relationship("Chat", back_populates="messages")
