from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column, sessionmaker

engine = create_engine("sqlite:///./test.db")
SessionLocal = sessionmaker(bind=engine)

class Base(DeclarativeBase):
    id : Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
