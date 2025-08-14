from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.db.session import SessionLocal
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin
from app.core.security import hash_password, verify_password, create_access_token
from app.core.encryption import encrypt_data, decrypt_data, get_secret_key

router = APIRouter(prefix="/auth", tags=["auth"])

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    # Verifica se o email já está registrado
    db_user = db.query(User).filter(User.email == user.email).first()
    if db_user:
        raise HTTPException(status_code=400, detail="Email já registrado")
    
    # Criptografa os dados sensíveis antes de salvar no banco
    secret_key = get_secret_key()  # A chave secreta deve ser carregada das variáveis de ambiente
    encrypted_cycle_data = encrypt_data(user.cycle_data, secret_key)  # Criptografa os dados do ciclo

    # Criação de um novo usuário
    new_user = User(
        name=user.name,
        email=user.email,
        hashed_password=hash_password(user.password),
        cycle_data_encrypted=encrypted_cycle_data  # Salva o dado criptografado
    )

    # Adiciona o novo usuário ao banco de dados
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return {"msg": "Usuária registrada com sucesso"}

@router.post("/login")
def login(credentials: UserLogin, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.email == credentials.email).first()
    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(status_code=401, detail="Credenciais inválidas")
    
    # Cria o token de acesso
    token = create_access_token(data={"sub": str(user.id)})
    
    return {"access_token": token, "token_type": "bearer"}
