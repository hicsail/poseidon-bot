from typing import Union, List
from pydantic import BaseModel

class MessageBase(BaseModel):
    chat_id: str
    message: Union[str, None]  # This allows message to be either a string or None

class MessageCreate(MessageBase):
    message: str  # Ensures message is required for creation

class Message(MessageBase):
    id: str  # Includes the message ID

    class Config:
        orm_mode = True  # Allows compatibility with SQLAlchemy models

class ChatBase(BaseModel):
    title: str

class ChatCreate(ChatBase):
    userId: str  # User ID for creating a chat

class Chat(ChatBase):
    id: str  # Includes chat ID
    owner_id: str  # Owner's user ID
    messages: List[Message] = []  # List of associated messages

    class Config:
        orm_mode = True  # Allows compatibility with SQLAlchemy models

class UserBase(BaseModel):
    email: str

class UserCreate(UserBase):
    password: str  # Password is required for user creation

class User(UserBase):
    id: str  # Includes user ID
    is_active: bool  # Indicates if the user is active
    chats: List[Chat] = []  # List of associated chats

    class Config:
        orm_mode = True  # Allows compatibility with SQLAlchemy models
