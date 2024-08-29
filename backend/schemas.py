from pydantic import BaseModel
from typing import Union

class MessageBase(BaseModel):
    chat_id: str
    message: Union[str, None]


class MessageCreate(MessageBase):
    chat_id: str
    message: str


class Message(MessageBase):
    id: str
    chat_id: str

    class Config:
        orm_mode = True

class ChatBase(BaseModel):
    title: str


class ChatCreate(ChatBase):
    title: str
    userId: str


class Chat(ChatBase):
    id: str
    owner_id: str
    messages: list[Message] = []

    class Config:
        orm_mode = True


class UserBase(BaseModel):
    email: str


class UserCreate(UserBase):
    password: str


class User(UserBase):
    id: str
    is_active: bool
    chats: list[Chat] = []

    class Config:
        orm_mode = True