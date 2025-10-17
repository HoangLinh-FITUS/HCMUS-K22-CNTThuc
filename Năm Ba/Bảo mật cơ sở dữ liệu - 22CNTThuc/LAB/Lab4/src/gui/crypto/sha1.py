import hashlib 


def cipher(data):
    return hashlib.sha1(data.encode()).hexdigest().upper()
