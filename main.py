from db import Base, engine
from models import User, Car, Booking
from fastapi import FastAPI
from schemas import *
from security import *
from deps import DB
from routers import users, cars, bookings

def init_db():
    Base.metadata.create_all(engine)

app = FastAPI()

# Initialize database
init_db()

# Include routers
app.include_router(users.router)
app.include_router(cars.router)
app.include_router(bookings.router)