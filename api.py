from db import Base, engine
from models import User, Car, Booking
from fastapi import FastAPI
from schemas import *
from security import *
from deps import DB

def init_db():
    Base.metadata.create_all(engine)

app = FastAPI()
