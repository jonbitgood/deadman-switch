#!/bin/bash
# Decrypt the secret using the DEADMAN_KEY environment variable
# Usage: DEADMAN_KEY=<key> ./decrypt.sh

if [ -z "$DEADMAN_KEY" ]; then
  echo "Error: DEADMAN_KEY environment variable not set"
  echo "Usage: DEADMAN_KEY=<key> ./decrypt.sh"
  exit 1
fi

openssl enc -aes-256-cbc -d -salt -pbkdf2 -in secret.enc -pass pass:"$DEADMAN_KEY"
