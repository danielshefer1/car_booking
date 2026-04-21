from pydantic import BaseModel, ConfigDict, EmailStr, Field
from datetime import datetime
from typing import Literal, Optional

Role = Literal["user", "elevated", "admin"]

# BOOKING START
# -------------
# -------------
# -------------
class BookingBase(BaseModel):
    car_id: int
    start_time: datetime
    end_time: datetime

class BookingCreate(BookingBase):
    pass

class BookingSchema(BookingBase):
    id: int
    user_id: int

    model_config = ConfigDict(from_attributes=True)

class BookingUserInfo(BaseModel):
    id: int
    first_name: str
    last_name: str
    phone_number: str

    model_config = ConfigDict(from_attributes=True)

class BookingWithUser(BookingBase):
    id: int
    user_id: int
    user: BookingUserInfo

    model_config = ConfigDict(from_attributes=True)
# -------------
# -------------
# -------------
# BOOKING END

# USER START
# -------------
# -------------
# -------------
class UserBase(BaseModel):
    first_name: str
    last_name: str
    email: EmailStr
    phone_number: str

class UserCreate(UserBase):
    password: str 

class UserSchema(UserBase):
    id: int
    permissions: str

    model_config = ConfigDict(from_attributes=True)

class UserUpdate(BaseModel):
    first_name: Optional[str] = Field(default=None, min_length=1)
    last_name: Optional[str] = Field(default=None, min_length=1)
    phone_number: Optional[str] = Field(default=None, min_length=1)
    password: Optional[str] = Field(default=None, min_length=1)
# -------------
# -------------
# -------------
# USER END

# CAR START
# -------------
# -------------
# -------------
class CarBase(BaseModel):
    company: str
    model: str
    year: int

class CarCreate(CarBase):
    pass 

class CarSchema(CarBase):
    id: int
    model_config = ConfigDict(from_attributes=True)
# CAR END
# -------------
# -------------
# -------------

class UserRolePromotion(BaseModel):
    role: Literal["elevated", "admin"]

class Token(BaseModel):
    access_token: str
    token_type: str