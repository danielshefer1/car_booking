from fastapi import APIRouter, HTTPException, status, Depends, Form
from sqlalchemy.orm import Session
from datetime import timedelta
from typing import List

import models
import schemas
import crud
from auth import create_access_token
from security import verify_password
from deps import DB, get_current_user, require_admin
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


@router.patch("/me", response_model=schemas.UserSchema)
def update_current_user(
    body: schemas.UserUpdate,
    db: DB,
    current_user: models.User = Depends(get_current_user),
):
    """Update current user's info. Email cannot be changed; only provided fields are modified."""
    return crud.update_user(db, current_user.id, body)


@router.get("", response_model=List[schemas.UserSchema])
def list_users(db: DB, _: models.User = Depends(require_admin)):
    """List all users (admin only). Password hashes are excluded by schema."""
    return db.query(models.User).order_by(models.User.id).all()


@router.delete("/{user_id}")
def delete_user_by_id(user_id: int, db: DB, _: models.User = Depends(require_admin)):
    """Delete a specific user (admin only)"""
    return crud.delete_user(db, user_id)


@router.post("/{user_id}/promote", response_model=schemas.UserSchema)
def promote_user(
    user_id: int,
    body: schemas.UserRolePromotion,
    db: DB,
    _: models.User = Depends(require_admin),
):
    """Promote a user to elevated or admin (admin only). Role must be strictly higher than current."""
    return crud.set_user_permissions(db, user_id, body.role)
