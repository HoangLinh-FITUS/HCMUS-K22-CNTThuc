from Crypto.Cipher import AES
from Crypto.Random import get_random_bytes

def generate_key(size: int) -> bytes:
    """Generates a cryptographically secure random symmetric key.

    Args:
        size (int): The required key length in bytes (e.g., 16 for AES-128, 
                    24 for AES-192, or 32 for AES-256).

    Returns:
        bytes: The randomly generated key.
    """
    return get_random_bytes(size)


def encrypt(key_AES: bytes, plaintext: bytes) -> bytes:
    """Encrypts data using AES-GCM (Galois/Counter Mode) for confidentiality and integrity.

    AES-GCM is an A.E.A.D (Authenticated Encryption with Associated Data) mode. 
    The function returns the ciphertext, authentication tag, and nonce, concatenated
    with a colon (:) and encoded in hexadecimal.

    Args:
        key_AES (bytes): The symmetric AES key (16, 24, or 32 bytes).
        plaintext (bytes): The clear data to be encrypted.

    Returns:
        bytes: The concatenated ciphertext, tag, and nonce, in the format 
                b'ciphertext_hex:tag_hex:nonce_hex'.
    """
    cipher  = AES.new(key_AES, AES.MODE_GCM)
    nonce = cipher.nonce 
    ciphertext, tag = cipher.encrypt_and_digest(plaintext)

    return bytes(ciphertext.hex() + ":" + tag.hex() + ":" + nonce.hex(), 'utf-8')


def decrypt(key_AES: bytes, ciphertext: bytes) -> bytes:
    """Decrypts data using AES-GCM and verifies its authenticity and integrity.

    The function splits the input string to retrieve the ciphertext, 
    authentication tag, and nonce before attempting decryption and verification.

    Args:
        key_AES (bytes): The symmetric AES key (16, 24, or 32 bytes).
        ciphertext (bytes): The input bytes in the format 
                            b'ciphertext_hex:tag_hex:nonce_hex'.

    Returns:
        bytes: The recovered plaintext.

    Raises:
        Exception: If 'Key incorrect or message corrupted' after the tag 
                   verification process fails.
    """
    ciphertext = ciphertext.decode("utf-8")
    ciphertext, tag, nonce = map(bytes.fromhex, ciphertext.split(':'))
    cipher_key = AES.new(key_AES, AES.MODE_GCM, nonce=nonce)
    plaintext = cipher_key.decrypt(ciphertext)

    try:
        cipher_key.verify(tag)
        return plaintext
    
    except ValueError:
        raise Exception('Key incorrect or message corrupted')
    