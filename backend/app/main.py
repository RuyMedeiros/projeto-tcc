from fastapi import FastAPI
from app.routers import auth, user, cycle  # Importando os roteadores de autenticação, usuário e ciclo

app = FastAPI(title="Calendário Feminino API")

# Registrando as rotas
app.include_router(auth.router, prefix="/auth", tags=["auth"])  # Roteiro de autenticação
app.include_router(user.router, prefix="/users", tags=["users"])  # Roteiro de usuários
app.include_router(cycle.router, prefix="/cycles", tags=["cycles"])  # Roteiro de ciclos menstruais

