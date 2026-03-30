from pydantic import BaseModel, ConfigDict, EmailStr
from datetime import datetime

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
    
    model_config = ConfigDict(from_attributes=True)
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

class Token(BaseModel):
    access_token: str
    token_type: str