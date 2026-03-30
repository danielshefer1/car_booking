from sqlalchemy.orm import Session, joinedload
from sqlalchemy.exc import IntegrityError
from sqlalchemy import select, and_, func
from fastapi import HTTPException
import models, schemas
from security import hash_password

# --- USER CRUD ---
def create_user(db: Session, user_in: schemas.UserCreate):
    hashed_pw = hash_password(user_in.password)
    
    user_data = user_in.model_dump()
    user_data.pop("password")
    
    db_user = models.User(**user_data, hashed_password=hashed_pw)
    
    try:
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        return db_user
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="Email or phone already registered.")

def delete_user(db: Session, user_id: int):
    db_user = db.get(models.User, user_id)
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    db.delete(db_user)
    db.commit()
    return {"detail": "User deleted"}

# --- CAR CRUD ---
def create_car(db: Session, car_in: schemas.CarCreate):
    db_car = models.Car(**car_in.model_dump())
    try:
        db.add(db_car)
        db.commit()
        db.refresh(db_car)
        return db_car
    except IntegrityError:
        db.rollback()
        raise HTTPException(status_code=400, detail="This car model already exists for this company.")

def delete_car(db: Session, car_id: int):
    db_car = db.get(models.Car, car_id)

    if not db_car:
        raise HTTPException(status_code=404, detail="Car not found")
    
    db.delete(db_car)
    db.commit()

    return {"detail": "Car and associated bookings deleted"}

# --- BOOKING CRUD ---
def create_booking(db: Session, booking_in: schemas.BookingCreate, user_id: int):
    db.execute(
        select(models.Car).where(models.Car.id == booking_in.car_id).with_for_update()
    )

    conflict_query = (
        select(models.Booking)
        .options(joinedload(models.Booking.user)) 
        .where(
            and_(
                models.Booking.car_id == booking_in.car_id,
                models.Booking.start_time < booking_in.end_time,
                models.Booking.end_time > booking_in.start_time
            )
        )
        .limit(1)
    )
    

    conflict = db.execute(conflict_query).scalar_one_or_none()

    if conflict:
        user = conflict.user
        raise HTTPException(
            status_code=400, 
            detail=(
                f"Car booked by {user.first_name} {user.last_name} "
                f"({user.phone_number}) until {conflict.end_time.strftime('%H:%M')}"
            )
        )

    new_booking = models.Booking(**booking_in.model_dump(), user_id=user_id)
    db.add(new_booking)
    db.commit()
    db.refresh(new_booking)
    return new_booking