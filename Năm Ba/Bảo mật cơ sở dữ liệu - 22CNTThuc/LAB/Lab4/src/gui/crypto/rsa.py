from Crypto.PublicKey import RSA 
from Crypto.Cipher import PKCS1_OAEP
from binascii import hexlify

class Cipher():

    def __init__(self, bits):
        self._bits = bits 

        self._key = RSA.generate(self._bits)
        
        self._private_key = self._key
        self._public_key = self._key.publickey()

    def get_private_key(self):
        return self._key
    
    def get_public_key(self):
        return self._key.publickey()

    def encrypted(self, public_key: bytes, data: str) -> bytes:
        data = data.encode()

        cipher_rsa = PKCS1_OAEP.new(public_key)
        bytes_encrypted = cipher_rsa.encrypt(data)

        return bytes_encrypted
    
    def decrypted(self, private_key: bytes, encrypted: bytes) -> str:
        cipher_rsa = PKCS1_OAEP.new(private_key)
        bytes_decrypted = cipher_rsa.decrypt(encrypted)

        return bytes_decrypted.decode('utf-8')
    
    def export_key(self, password: str = None) -> None: 
        data = self._key.export_key(passphrase=password,
                                    pkcs=8, 
                                    protection='PBKDF2WithHMAC-SHA512AndAES256-CBC', 
                                    prot_params={'iteration_count':131072}) 
        return data 

    def import_key(self, data_pem, password: str = None) -> None:
        self._key = RSA.import_key(data_pem, password)


        
if __name__ == '__main__':
    
    NV01 = Cipher(bits=2048)
    

