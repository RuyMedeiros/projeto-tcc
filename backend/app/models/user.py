from sqlalchemy import Column, Integer, String
from app.db.session import Base
from app.core.encryption import encrypt_data, decrypt_data, get_secret_key

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    cycle_data_encrypted = Column(String)  # Armazenar o dado criptografado do ciclo

    def set_cycle_data(self, cycle_data: str):
        """Método para criptografar o ciclo menstrual antes de salvar no banco de dados."""
        secret_key = get_secret_key()
        self.cycle_data_encrypted = encrypt_data(cycle_data, secret_key)

    def get_cycle_data(self):
        """Método para descriptografar o ciclo menstrual quando necessário."""
        secret_key = get_secret_key()
        return decrypt_data(self.cycle_data_encrypted.encode(), secret_key)
