# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

FastAPI backend for a car-booking service. SQLAlchemy 2.0 (typed `Mapped` style) over SQLite by default, JWT auth via `python-jose`, bcrypt via `passlib`. Python `>=3.12`, dependencies managed with `uv` (see `uv.lock`).

## Commands

```bash
# Install / sync dependencies
uv sync

# Run dev server (auto-reloads, serves on :8000)
uv run uvicorn main:app --reload

# Interactive API docs once running: http://localhost:8000/docs
```

Required env vars in `.env` (loaded by `config.Settings`): `SECRET_KEY`, `DATABASE_URL`. Optional: `ALGORITHM` (default `HS256`), `ACCESS_TOKEN_EXPIRE_MINUTES` (default 30).

There is no test suite, linter, or formatter configured.

## Architecture

Layered flat module layout (no `src/` or `app/` package):

- `main.py` — FastAPI app construction. Calls `Base.metadata.create_all(engine)` at import time, so **the DB schema is auto-created on startup**; there is no migration tool (Alembic). Schema changes to `models.py` against an existing `sql_app.db` will *not* migrate — delete the file or add migrations.
- `db.py` — Engine, `SessionLocal`, and a `DeclarativeBase` subclass that injects an autoincrement `id` PK into every model.
- `models.py` — `User`, `Car`, `Booking`. `Booking` has `ON DELETE CASCADE` FKs to both, plus a DB-level `CheckConstraint("start_time < end_time")`. `Car` has a `UniqueConstraint(company, model)`. `User.permissions` is a free-form string role column (defaults to `"user"`); the only role checked in code is `"admin"`.
- `schemas.py` — Pydantic v2 request/response models. `UserCreate` carries `password`; `UserSchema` does not.
- `crud.py` — All DB write logic. `create_booking` does pessimistic locking: it first issues `SELECT ... FOR UPDATE` on the target `Car` row, then checks for time-overlapping bookings, then inserts. This is the concurrency-correctness path — preserve it.
- `deps.py` — FastAPI dependencies. Exports the `DB` type alias (`Annotated[Session, Depends(get_db)]`) used throughout routers, `get_current_user` which decodes the JWT and looks up the user by email (`sub` claim), and `require_admin` which 403s unless `current_user.permissions == "admin"`.
- `auth.py` / `security.py` — JWT encode and bcrypt hash/verify helpers.
- `routers/` — one module per resource (`users`, `cars`, `bookings`), each with its own `APIRouter(prefix=...)`. Wired up in `main.py`.

## Conventions worth knowing

- **Auth model**: `POST /users/login` is OAuth2 password-flow form-encoded (`username` + `password`); `username` is actually the email. Token's `sub` is the email, not the user id — `get_current_user` re-queries by email on every request.
- **Roles**: the very first registered user (when the `users` table is empty) is created as `"admin"`; every subsequent registration defaults to `"user"`. This is the only bootstrap path — once any user exists, new registrations are always regular users, and `POST /users/{user_id}/promote` (admin-only) is the way to elevate them. Other admin-gated endpoints: `POST /cars`, `DELETE /cars/{car_id}`, `DELETE /users/{user_id}`. Users can always delete themselves via `DELETE /users/me`.
- **Ownership checks** live in the router (`bookings.py`), not in CRUD — booking reads/deletes compare `booking.user_id != current_user.id` inline. New booking endpoints should follow the same pattern.
- **Error style**: CRUD functions raise `HTTPException` directly (e.g. on `IntegrityError` after `db.rollback()`). Routers mostly just forward to CRUD.
- **Imports are flat** (e.g. `from models import ...`, `from deps import DB`); the project is not installed as a package, so you must run from the repo root.
- `main.py` uses `from schemas import *` / `from security import *` — those wildcards aren't actually relied on, so adding new names to those modules won't change `main`'s behavior.
