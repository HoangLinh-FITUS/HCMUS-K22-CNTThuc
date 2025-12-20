import RSA, AES 
import signature
import argparse 
import os

AES_KEY_BYTES = 32 

parser = argparse.ArgumentParser(description='Encrypt files using RSA and AES.')

parser.add_argument('--receiver_pub_key', required=True, 
                    help="Receiver's public key file.")
parser.add_argument('--sender_private_key', required=True, 
                    help="Sender's private key file")
parser.add_argument('--input_file', required=True, 
                    help='File to be encrypted.')
parser.add_argument('--output_encrypted_file', required=True, 
                    help='Output file for the encrypted data.')
parser.add_argument('--output_encrypted_symmetric_key', required=True, 
                    help='Output file for the encrypted symmetric (AES) key.')
parser.add_argument('--output_signature', required=True, 
                    help='Output file for the digital signature.')

args = parser.parse_args()


# --- Load keys ---
with open(args.receiver_pub_key, "rb") as f:
    receiver_public_key = f.read()

with open(args.sender_private_key, 'rb') as f:
    sender_private_key = f.read()


# --- Read the input file ---
with open(args.input_file, 'rb') as f:
    plaintext = f.read()


# --- Generate AES key ---
aes_key = AES.generate_key(AES_KEY_BYTES)


# --- Encrypt ---
encrypted_file = AES.encrypt(aes_key, plaintext)
encrypted_aes_key = RSA.encrypt(receiver_public_key, aes_key)
signed_file = signature.sign(sender_private_key, plaintext)

print('Payload created successfully')


# --- Write all outputs ---
for filepath in [args.output_encrypted_file, args.output_encrypted_symmetric_key, args.output_signature]:
    folder = os.path.dirname(filepath)
    if folder:
        os.makedirs(folder, exist_ok=True)

try:
    print('Saving outputs...')

    with open(args.output_encrypted_file, 'wb') as f:
        f.write(encrypted_file)
    print('Saved encrypted file in', args.output_encrypted_file)

    with open(args.output_encrypted_symmetric_key, 'wb') as f:
        f.write(encrypted_aes_key)
    print('Saved symmetric key in', args.output_encrypted_symmetric_key)

    with open(args.output_signature, 'wb') as f:
        f.write(signed_file)
    print('Saved signature in', args.output_signature)

except Exception as e:
    print('Failed to create payload ', e)
