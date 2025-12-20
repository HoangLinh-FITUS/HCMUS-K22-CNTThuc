import RSA, AES 
import signature
import argparse
import os 



parser = argparse.ArgumentParser(
    description='Decrypt a file using RSA and AES, and verify its digital signature'
)

parser.add_argument("--receiver_private_key", required=True, 
                    help="Receiver's private key file.")
parser.add_argument("--sender_pub_key", required=True, 
                    help="Sender's public key file")
parser.add_argument("--encrypted_key", required=True,
                    help="the encrypted AES key file.")
parser.add_argument("--input_file", required=True, 
                    help='the encrypted input file.')
parser.add_argument("--output_decrypted_file", required=True, 
                    help='the decrypted output file.')
parser.add_argument("--input_signature", required=True, 
                    help='the digital signature file.')

args = parser.parse_args()


# --- Load Keys ---
with open(args.receiver_private_key, 'rb') as f:
    receiver_private_key = f.read()

with open(args.sender_pub_key, 'rb') as f:
    sender_public_key = f.read()


# --- Read the input file ---
with open(args.input_file, 'rb') as f:
    encrypted_file = f.read()


# --- Read AES Key ---
with open(args.encrypted_key, 'rb') as f:
    encrypted_aes_key = f.read()


# --- Read the signature file ---
with open(args.input_signature, 'rb') as f:
    signed_file = f.read()


# --- decrypt ---
decrypted_aes = RSA.decrypt(receiver_private_key, encrypted_aes_key)
decrypted_file = AES.decrypt(decrypted_aes, encrypted_file)

print('Payload decrypted successfully')


# --- verify signature ----
if not signature.verify(sender_public_key, decrypted_file, signed_file):
    print('FILE IS INVALID')
    exit(1)

print('FILE IS VALID')


# --- Write outputs ---
folder = os.path.dirname(args.output_decrypted_file)
if folder:
    os.makedirs(folder, exist_ok=True)
    
try:
    print('Saving outputs...')
    with open(args.output_decrypted_file, 'wb') as f:
        f.write(decrypted_file)
    print('File is saved in', args.output_decrypted_file)
    
except Exception as e:
    print('Payload decryption failure ', e)
