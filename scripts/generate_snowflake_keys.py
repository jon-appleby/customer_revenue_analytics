from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import rsa

from src.paths import KEY_DIR

KEY_DIR.mkdir(exist_ok=True)

private_key_file = KEY_DIR / 'snowflake_rsa_key.p8'
public_key_file = KEY_DIR / 'snowflake_rsa_key.pub'

private_key = rsa.generate_private_key(
    public_exponent=65537,
    key_size=2048,
)

private_pem = private_key.private_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PrivateFormat.PKCS8,
    encryption_algorithm=serialization.NoEncryption()
)

private_key_file.write_bytes(private_pem)

public_pem = private_key.public_key().public_bytes(
    encoding=serialization.Encoding.PEM,
    format=serialization.PublicFormat.SubjectPublicKeyInfo
)

public_key_file.write_bytes(public_pem)

print('Use when running "ALTER USER" statement in Snowflake:')
print(''.join(public_pem.decode().splitlines()[1:-1]))


