import argparse 
import RSA
import os 



parse = argparse.ArgumentParser(description="Generating an RSA key pair (private key, public key).")

parse.add_argument('--output_public_key_file', help="public key file name")
parse.add_argument('--output_private_key_file', help="private key file name")
parse.add_argument('--bits', type=int, default=2048, help='Key length')

args = parse.parse_args()


# --- Key Generation ---
try:
    private_key, public_key = RSA.generate_key(args.bits)
    print('private_key vs public_key generated successfully')
except Exception as e:
    print('private_key vs public_key generation failed: ', e)
    exit(1)


try:

    # --- create dir ---
    dir_pub = os.path.dirname(args.output_public_key_file)
    if dir_pub:
        os.makedirs(dir_pub, exist_ok=True)

    dir_private = os.path.dirname(args.output_private_key_file)
    if dir_pub:
        os.makedirs(dir_private, exist_ok=True)
    
    
    # --- File Writing ---
    with open(args.output_public_key_file, 'wb') as f:
        f.write(public_key)

    with open(args.output_private_key_file, 'wb') as f:
        f.write(private_key)        

    print('Keys saved successfully')
    print(f'Public Key: {args.output_public_key_file}')
    print(f'Private Key: {args.output_private_key_file}')
except Exception as e:
    print(f'Error writing files: {e}')
    exit(1)