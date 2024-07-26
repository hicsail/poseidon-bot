from pydantic import BaseModel

class MessageBase(BaseModel):
    title: str
    message: str | None = None
    typeOfMessage: str | None = None


class MessageCreate(MessageBase):
    message: str


class Message(MessageBase):
    id: int
    chat_id: int

    class Config:
        orm_mode = True

class ChatBase(BaseModel):
    title: str


class ChatCreate(ChatBase):
    pass


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