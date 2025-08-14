from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.cycle import Cycle
from app.models.user import User
from app.schemas.cycle import CycleCreate, CycleResponse
from app.core.security import get_current_user
from typing import List
from datetime import timedelta

router = APIRouter(prefix="/cycles", tags=["cycles"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/", response_model=CycleResponse)
def create_cycle(cycle: CycleCreate, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    new_cycle = Cycle(
        user_id=current_user.id,
        start_date=cycle.start_date,
        end_date=cycle.end_date
    )
    db.add(new_cycle)
    db.commit()
    db.refresh(new_cycle)
    return new_cycle

@router.get("/", response_model=List[CycleResponse])
def list_cycles(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    return db.query(Cycle).filter(Cycle.user_id == current_user.id).order_by(Cycle.start_date.desc()).all()

@router.get("/next")
def get_next_cycle_prediction(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    last_cycle = db.query(Cycle).filter(Cycle.user_id == current_user.id).order_by(Cycle.start_date.desc()).first()
    
    if not last_cycle:
        return {"msg": "Nenhum ciclo registrado ainda."}

    cycle_length = (last_cycle.end_date - last_cycle.start_date).days
    next_start = last_cycle.start_date + timedelta(days=cycle_length + 28)  # ciclo médio de 28 dias
    ovulation_day = next_start + timedelta(days=14)
    
    return {
        "last_cycle": {
            "start": str(last_cycle.start_date),
            "end": str(last_cycle.end_date)
        },
        "next_cycle": {
            "predicted_start": str(next_start),
            "predicted_ovulation": str(ovulation_day)
        }
    }
