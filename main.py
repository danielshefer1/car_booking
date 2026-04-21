from fastapi import FastAPI

from db import Base, engine
import models  # noqa: F401  register mappers before create_all
from routers import users, cars, bookings


def init_db():
    Base.metadata.create_all(engine)


app = FastAPI()
init_db()

app.include_router(users.router)
app.include_router(cars.router)
app.include_router(bookings.router)