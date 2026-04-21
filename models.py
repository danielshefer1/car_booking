from sqlalchemy import UniqueConstraint, ForeignKey, CheckConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from db import Base
from datetime import datetime
from typing import List

class Car(Base):
    __tablename__ = "cars"

    company: Mapped[str] = mapped_column(nullable=False, index=True)
    model: Mapped[str] = mapped_column(nullable=False)
    year: Mapped[int] = mapped_column()

    bookings: Mapped[List["Booking"]] = relationship(back_populates="car")

    __table_args__ = (
        UniqueConstraint("company", "model", name="uq_car_company_model"),
    )

class User(Base):
    __tablename__ = "users"

    first_name: Mapped[str] = mapped_column(nullable=False)
    last_name: Mapped[str] = mapped_column(nullable=False)
    phone_number: Mapped[str] = mapped_column(unique=True, nullable=False)
    email: Mapped[str] = mapped_column(unique=True, index=True)
    hashed_password: Mapped[str] = mapped_column(nullable=False)
    permissions: Mapped[str] = mapped_column(nullable=False, default="user")

    bookings: Mapped[List["Booking"]] = relationship(back_populates="user")

class Booking(Base):
    __tablename__ = "bookings"

    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    car_id: Mapped[int] = mapped_column(ForeignKey("cars.id", ondelete="CASCADE"))

    start_time: Mapped[datetime] = mapped_column(nullable=False)
    end_time: Mapped[datetime] = mapped_column(nullable=False)
    
    user: Mapped["User"] = relationship(back_populates="bookings")
    car: Mapped["Car"] = relationship(back_populates="bookings")

    __table_args__ = (
        CheckConstraint("start_time < end_time", name="check_start_before_end"),
    )

