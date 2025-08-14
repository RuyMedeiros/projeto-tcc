from pydantic import BaseModel
from datetime import date, datetime

class CycleBase(BaseModel):
    start_date: date
    end_date: date

class CycleCreate(CycleBase):
    pass

class CycleResponse(CycleBase):
    id: int
    created_at: datetime

    class Config:
        orm_mode = True
