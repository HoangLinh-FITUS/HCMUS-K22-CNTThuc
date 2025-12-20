# Secure File Encryption System - Installation & Usage Guide

This is a Python-based secure file encryption system that combines RSA (asymmetric encryption), AES (symmetric encryption), and digital signatures to enable secure file transfer between two parties.

## Table of Contents
1. [Installation](#installation)
2. [Project Overview](#project-overview)
3. [Usage Guide](#usage-guide)
4. [Command-Line Tools](#command-line-tools)
---

## Installation

### Prerequisites
- Python 3.7 or higher
- pip (Python package manager)

### Install Dependencies

Navigate to the project directory and install the required packages:

```bash
pip install -r requirements.txt
```

## Project Overview

### Components

| File | Purpose |
|------|---------|
| `keyGen.py` | Generate RSA key pairs (2048-bit or custom) |
| `encryptor.py` | Encrypt files and create digital signatures |
| `decryptor.py` | Decrypt files and verify digital signatures |
| `RSA.py` | RSA encryption/decryption implementation |
| `AES.py` | AES encryption/decryption implementation |
| `signature.py` | Digital signature creation and verification |
| `demo_CLI.ipynb` | Interactive Jupyter notebook demonstration |

### Workflow

1. **Generate Keys**: Create RSA key pairs for sender and receiver
2. **Encrypt File**: Sender encrypts file using receiver's public key and signs with private key
3. **Decrypt File**: Receiver decrypts file using their private key and verifies sender's signature

---

## Usage Guide

### Quick Start (Interactive Demo)

The easiest way to get started is using the Jupyter notebook:

```bash
jupyter notebook demo_CLI.ipynb
```

Then run each cell in sequence. The notebook handles all steps automatically.

---

## Command-Line Tools

### 1. Generate RSA Key Pairs

Generate a key pair for the sender:

```bash
python keyGen.py --output_public_key_file=keys/sender_pub_key.pub \
                  --output_private_key_file=keys/sender_private_key.key \
                  --bits=2048
```

Generate a key pair for the receiver:

```bash
python keyGen.py --output_public_key_file=keys/receiver_pub_key.pub \
                  --output_private_key_file=keys/receiver_private_key.key \
                  --bits=2048
```

**Parameters:**
- `--output_public_key_file`: Path to save the public key file
- `--output_private_key_file`: Path to save the private key file
- `--bits`: RSA key length in bits (default: 2048, options: 1024, 2048, 4096)


---

### 2. Encrypt and Sign a File

Encrypt a file using the receiver's public key and sign it with the sender's private key:

```bash
python encryptor.py --receiver_pub_key=keys/receiver_pub_key.pub \
                     --sender_private_key=keys/sender_private_key.key \
                    --input_file=sample/file2.txt \
                    --output_encrypted_file=payload/encrypted_file.bin \
                    --output_encrypted_symmetric_key=payload/encrypted_key.key \
                    --output_signature=payload/output_signature.sig
```

**Parameters:**
- `--receiver_pub_key`: Path to receiver's public key
- `--sender_private_key`: Path to sender's private key
- `--input_file`: Path to the file to encrypt
- `--output_encrypted_file`: Path to save encrypted data
- `--output_encrypted_symmetric_key`: Path to save encrypted AES key
- `--output_signature`: Path to save digital signature

**Output Files:**
- `encrypted_file.bin`: The encrypted file content
- `encrypted_key.key`: The encrypted AES symmetric key
- `output_signature.sig`: Digital signature for authentication

---

### 3. Decrypt and Verify a File

Decrypt a file using the receiver's private key and verify the sender's signature:

```bash
python decryptor.py --receiver_private_key=keys/receiver_private_key.key \
                    --sender_pub_key=keys/sender_pub_key.pub \
                    --encrypted_key=payload/encrypted_key.key \
                    --input_file=payload/encrypted_file.bin \
                    --output_decrypted_file=results/output_decrypted_file.txt \
                    --input_signature=payload/output_signature.sig
```

**Parameters:**
- `--receiver_private_key`: Path to receiver's private key
- `--sender_pub_key`: Path to sender's public key
- `--encrypted_key`: Path to encrypted AES key
- `--input_file`: Path to encrypted file
- `--output_decrypted_file`: Path to save decrypted file
- `--input_signature`: Path to digital signature

**Output:**
- `output_decrypted_file.txt`: The decrypted file
- Console message confirming signature verification success or failure
