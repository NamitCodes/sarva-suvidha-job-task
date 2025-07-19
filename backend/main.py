from fastapi import FastAPI, HTTPException, Query
from pydantic import BaseModel
from typing import Dict, Optional
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy import Column, Integer, String, Date, JSON, select
from contextlib import asynccontextmanager
from datetime import date
from fastapi.middleware.cors import CORSMiddleware
import os
from dotenv import load_dotenv

load_dotenv()

DATABASE_URL = os.getenv("DATABASE_URL")

engine = create_async_engine(DATABASE_URL, echo=True)
async_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)
Base = declarative_base()

class WheelSpecModel(Base):
    __tablename__ = "wheel_specifications"

    id = Column(Integer, primary_key=True, index=True)
    form_number = Column(String, nullable=False)
    submitted_by = Column(String, nullable=False)
    submitted_date = Column(Date, nullable=False)
    fields = Column(JSON, nullable=False)
    status = Column(String, default="Saved")

class WheelSpecCreate(BaseModel):
    formNumber: str
    submittedBy: str
    submittedDate: date
    fields: Dict

class LoginRequest(BaseModel):
    phone: str
    password: str

@asynccontextmanager
async def lifespan(app: FastAPI):
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    yield

app = FastAPI(lifespan=lifespan)

@app.post("/api/forms/wheel-specifications")
async def create_wheel_spec(data: WheelSpecCreate):
    async with async_session() as session:
        try:
            wheel = WheelSpecModel(
                form_number=data.formNumber,
                submitted_by=data.submittedBy,
                submitted_date=data.submittedDate,
                fields=data.fields
            )
            session.add(wheel)
            await session.commit()
            return {
                "success": True,
                "message": "Wheel specification submitted successfully.",
                "data": {
                    "formNumber": data.formNumber,
                    "submittedBy": data.submittedBy,
                    "submittedDate": data.submittedDate,
                    "status": "Saved"
                }
            }
        except Exception as e:
            await session.rollback()
            raise HTTPException(status_code=500, detail=f"Failed to submit wheel spec. Error: {str(e)}")

@app.get("/api/forms/wheel-specifications")
async def get_wheel_specs(
    formNumber: Optional[str] = Query(None),
    submittedBy: Optional[str] = Query(None),
    submittedDate: Optional[date] = Query(None)
):
    async with async_session() as session:
        try:
            query = select(WheelSpecModel)
            if formNumber:
                query = query.where(WheelSpecModel.form_number == formNumber)
            if submittedBy:
                query = query.where(WheelSpecModel.submitted_by == submittedBy)
            if submittedDate:
                query = query.where(WheelSpecModel.submitted_date == submittedDate)

            result = await session.execute(query)
            records = result.scalars().all()
            allowed_fields = ["treadDiameterNew", "lastShopIssueSize", "condemningDia", "wheelGauge"]

            data = [
                {
                    "formNumber": rec.form_number,
                    "submittedBy": rec.submitted_by,
                    "submittedDate": str(rec.submitted_date),
                    "fields": {key: value for key, value in rec.fields.items() if key in allowed_fields}
                } for rec in records
            ]

            return {
                "success": True,
                "message": "Filtered wheel specification forms fetched successfully.",
                "data": data
            }
        except Exception as e:
            raise HTTPException(status_code=500, detail=f"Failed to fetch wheel specs. Error: {str(e)}")

@app.post("/api/users/login")
async def login(data: LoginRequest):
    if data.phone == "7760873976" and data.password == "to_share@123":
        return {
            "success": True,
            "message": "Login successful.",
            "data": {
                "user_id": "user_id_123",
                "name": "Test User",
                "token": "fake-jwt-token"
            }
        }
    raise HTTPException(status_code=401, detail="Invalid credentials")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
