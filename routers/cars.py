from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session
from typing import List

import models
import schemas
import crud
from deps import DB, get_current_user

router = APIRouter(prefix="/cars", tags=["cars"])


@router.post("", response_model=schemas.CarSchema)
def create_car(car_in: schemas.CarCreate, db: DB, current_user: models.User = Depends(get_current_user)):
    """Create a new car (authenticated users only)"""
    return crud.create_car(db, car_in)


@router.get("", response_model=List[schemas.CarSchema])
def list_cars(db: DB):
    """Get all available cars"""
    cars = db.query(models.Car).all()
    return cars


@router.get("/{car_id}", response_model=schemas.CarSchema)
def get_car(car_id: int, db: DB):
    """Get a specific car by ID"""
    car = db.get(models.Car, car_id)
    
    if not car:
        raise HTTPException(status_code=404, detail="Car not found")
    
    return car


@router.delete("/{car_id}")
def delete_car(car_id: int, db: DB, current_user: models.User = Depends(get_current_user)):
    """Delete a car (authenticated users only)"""
    return crud.delete_car(db, car_id)
