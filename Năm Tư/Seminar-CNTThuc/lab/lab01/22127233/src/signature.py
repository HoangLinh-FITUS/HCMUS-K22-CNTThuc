from Crypto.Signature import pkcs1_15
from Crypto.Hash import SHA256
from Crypto.PublicKey import RSA 

def sign(private_key: bytes, data: bytes) -> bytes:
    """
    Signs the given data using the RSA private key, applying the PKCS#1 v1.5 padding 
    scheme and SHA256 hashing algorithm.

    Args:
        private_key (bytes): The RSA private key in byte format (e.g., PEM or DER).
        data (bytes): The data (message) to be signed.
    
    Returns:
        bytes: The RSA digital signature in byte format.
  
    Raises:
        ValueError: If the private_key is not a valid or well-formed RSA key.
    """
    key = RSA.import_key(private_key)
    h = SHA256.new(data)
    return pkcs1_15.new(key).sign(h)


def verify(public_key: bytes, data: bytes, data_signed: bytes) -> bool:
    """
    Verifies an RSA digital signature against the original data using the public key.

    It uses the PKCS#1 v1.5 padding scheme and SHA256 hashing algorithm.

    Args:
        public_key (bytes): The corresponding RSA public key in byte format.
        data (bytes): The original data (message) that was signed.
        data_signed (bytes): The digital signature to be verified.
    
    Returns:
        bool: True if the signature is valid for the data and public key, False otherwise.

    Raises:
        ValueError: If the public_key is not a valid RSA key.
    """
    key = RSA.import_key(public_key)
    h = SHA256.new(data)
    
    try:
        pkcs1_15.new(key).verify(h, data_signed)
        return True
    except (ValueError, TypeError):
        print("The signature is not valid.")
        return False
