from cryptography.fernet import Fernet
import os

# Função para gerar uma chave secreta
def generate_key():
    return Fernet.generate_key()

# Função para criptografar os dados
def encrypt_data(data: str, key: bytes) -> bytes:
    cipher_suite = Fernet(key)
    return cipher_suite.encrypt(data.encode())

# Função para descriptografar os dados
def decrypt_data(encrypted_data: bytes, key: bytes) -> str:
    cipher_suite = Fernet(key)
    return cipher_suite.decrypt(encrypted_data).decode()

# Salvar e recuperar a chave de forma segura (exemplo: usando variáveis de ambiente)
def get_secret_key():
    secret_key = os.getenv("SECRET_KEY")  # A chave deve ser armazenada de forma segura
    if not secret_key:
        raise ValueError("SECRET_KEY não definida nas variáveis de ambiente")
    return secret_key.encode()
