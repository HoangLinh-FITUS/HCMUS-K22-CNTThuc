from Crypto.PublicKey import RSA 
from Crypto.Cipher import PKCS1_OAEP

def generate_key(bits: int) -> tuple[bytes, bytes]:
    """
    Generate an RSA key pair.

    Args:
        bits (int): The number of bits for the RSA key.

    Returns:
        Tuple[bytes, bytes]: A tuple containing the private key and public key in PEM format as bytes.
    """
    key = RSA.generate(bits)
    private_key = key
    public_key = key.publickey()
    return private_key.export_key(), public_key.export_key()


def encrypt(public_key: bytes, plaintext: bytes) -> bytes:
    """Encrypts plaintext using the RSA public key with OAEP padding.

    OAEP (Optimal Asymmetric Encryption Padding) is the recommended secure 
    padding scheme for RSA encryption.

    Args:
        public_key (bytes): The RSA public key in byte format (e.g., PEM).
        plaintext (bytes): The clear data to be encrypted.

    Returns:
        bytes: The resulting ciphertext.

    Raises:
        ValueError: If the public_key is invalid or if the plaintext is 
            too long for the given RSA key size.
    """
    public_key = RSA.import_key(public_key)

    cipher_rsa = PKCS1_OAEP.new(public_key)
    encrypted = cipher_rsa.encrypt(plaintext)
    return encrypted


def decrypt(private_key: bytes, ciphertext: bytes) -> bytes:
    """Decrypts ciphertext using the RSA private key with OAEP padding.

    Args:
        private_key (bytes): The RSA private key in byte format (e.g., PEM).
        ciphertext (bytes): The encrypted data to be decrypted.

    Returns:
        bytes: The recovered plaintext.

    Raises:
        ValueError: If the private_key is invalid.
        ValueError: If the ciphertext is not a valid OAEP encryption (e.g., 
            it was tampered with, corrupted, or the wrong key was used).
    """
    private_key = RSA.import_key(private_key)

    cipher_rsa = PKCS1_OAEP.new(private_key)
    decrypted = cipher_rsa.decrypt(ciphertext)
    return decrypted