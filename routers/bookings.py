from fastapi import APIRouter, HTTPException, status, Depends
from sqlalchemy.orm import Session, joinedload
from sqlalchemy import select
from typing import List

import models
import schemas
import crud
from deps import DB, get_current_user

router = APIRouter(prefix="/bookings", tags=["bookings"])


@router.post("", response_model=schemas.BookingSchema)
def create_booking(booking_in: schemas.BookingCreate, db: DB, current_user: models.User = Depends(get_current_user)):
    """Create a new booking for the current user"""
    return crud.create_booking(db, booking_in, current_user.id)


@router.get("", response_model=List[schemas.BookingSchema])
def list_user_bookings(db: DB, current_user: models.User = Depends(get_current_user)):
    """Get all bookings for the current user"""
    bookings = db.query(models.Booking).filter(
        models.Booking.user_id == current_user.id
    ).all()
    return bookings


@router.get("/all", response_model=List[schemas.BookingWithUser])
def list_all_bookings(db: DB, _: models.User = Depends(get_current_user)):
    """Get every booking across all users, with booker info embedded."""
    bookings = (
        db.query(models.Booking)
        .options(joinedload(models.Booking.user))
        .all()
    )
    return bookings


@router.get("/{booking_id}", response_model=schemas.BookingSchema)
def get_booking(booking_id: int, db: DB, current_user: models.User = Depends(get_current_user)):
    """Get a specific booking (user can only see their own bookings)"""
    booking = db.get(models.Booking, booking_id)
    
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    
    if booking.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only view your own bookings"
        )
    
    return booking


@router.delete("/{booking_id}")
def cancel_booking(booking_id: int, db: DB, current_user: models.User = Depends(get_current_user)):
    """Cancel/delete a booking (user can only delete their own bookings)"""
    booking = db.get(models.Booking, booking_id)
    
    if not booking:
        raise HTTPException(status_code=404, detail="Booking not found")
    
    if booking.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="You can only delete your own bookings"
        )
    
    db.delete(booking)
    db.commit()
    return {"detail": "Booking cancelled"}
