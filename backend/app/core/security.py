from fastapi import Depends, HTTPException
from fastapi.security import OAuth2PasswordBearer
from jose import JWTError, jwt
from app.db.session import SessionLocal
from app.models.user import User
from app.core.encryption import get_secret_key
from app.models.user import User

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")

SECRET_KEY = get_secret_key()  # Pega a chave secreta das variáveis de ambiente
ALGORITHM = "HS256"  # Algoritmo utilizado para assinar o JWT

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)) -> User:
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Token inválido")
        
        user = db.query(User).filter(User.id == user_id).first()
        if user is None:
            raise HTTPException(status_code=401, detail="Usuária não encontrada")
        
        return user
    except JWTError:
        raise HTTPException(status_code=401, detail="Token inválido")
