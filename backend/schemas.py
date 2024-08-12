from pydantic import BaseModel

class MessageBase(BaseModel):
    message: str | None


class MessageCreate(MessageBase):
    chat_id: int
    message: str


class Message(MessageBase):
    id: int
    chat_id: int

    class Config:
        orm_mode = True

class ChatBase(BaseModel):
    title: str


class ChatCreate(ChatBase):
    title: str
    userId: str


class Chat(ChatBase):
    id: int
    owner_id: int
    messages: list[Message] = []

    class Config:
        orm_mode = True


class UserBase(BaseModel):
    email: str


class UserCreate(UserBase):
    password: str


class User(UserBase):
    id: int
    is_active: bool
    chats: list[Chat] = []

    class Config:
        orm_mode = True