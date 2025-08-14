from fastapi import FastAPI
from app.api.v1.endpoints import auth, user, cycle

app = FastAPI(title="Calendário Feminino API")

app.include_router(auth.router)
app.include_router(user.router)
app.include_router(cycle.router)
