from fastapi import APIRouter, HTTPException, status, Depends, Form
from sqlalchemy.orm import Session
from datetime import timedelta

import models
import schemas
import crud
from auth import create_access_token
from security import verify_password
from deps import DB, get_current_user
from config import settings

router = APIRouter(prefix="/users", tags=["users"])


@router.post("/register", response_model=schemas.UserSchema)
def register(user_in: schemas.UserCreate, db: DB):
    """Register a new user"""
    return crud.create_user(db, user_in)


@router.post("/login", response_model=schemas.Token)
def login(db: DB, username: str = Form(), password: str = Form()):
    """Login user and return access token"""
    user = db.query(models.User).filter(models.User.email == username).first()
    
    if not user or not verify_password(password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}


@router.get("/me", response_model=schemas.UserSchema)
def get_current_user_info(current_user: models.User = Depends(get_current_user)):
    """Get current authenticated user info"""
    return current_user


@router.delete("/me")
def delete_current_user(db: DB, current_user: models.User = Depends(get_current_user)):
    """Delete current user account"""
    return crud.delete_user(db, current_user.id)


@router.delete("/{user_id}")
def delete_user_by_id(user_id: int, db: DB, current_user: models.User = Depends(get_current_user)):
    """Delete a specific user (must be authenticated)"""
    return crud.delete_user(db, user_id)
