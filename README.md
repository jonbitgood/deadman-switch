# Dead Man's Switch

A GitHub Actions-powered dead man's switch. If no real activity is detected on this
repo for over a year, a designated successor is granted admin access and pointed to
an encrypted secret or a set of encrypted files but less than 1GB per github rules.

## How it works

A Weekly cron job checks the last non-bot commit across all branches. Then pushes a
keepalive commit to the `heartbeat` branch hopefully prevents GitHub from disabling
the scheduled workflow. If 365+ days since last real activity, automatically grants
admin access to SUCCESSOR_USERNAME and opens an issue with decryption instructions.

## Encryption

Only someone with admin access to this repo can view the secret within this project
and `secret.enc` is encrypted securely with AES-256-CBC PBKDF2 key derivation. Only 
the plaintext `secret.txt` is .gitignored but needed as a backup copy for recovery.
The encryption key resides in GitHub Actions under secret `DEADMAN_KEY` for builds.


To decrypt manually:

```bash
DEADMAN_KEY=<key> ./decrypt.sh
```

## Setup

### 1. GitHub Secrets & Variables

| Name                 | Description                                              |
|----------------------|----------------------------------------------------------|
| `DEADMAN_PAT`        | Classic PAT with `repo` and `admin:org` scopes           |
| `DEADMAN_KEY`        | The AES-256 encryption key used to encrypt `secret.enc`  |
| `SUCCESSOR_USERNAME` | GitHub username of the person who inherits access        |

### 3. Workflow permissions

Go to **Settings → Actions → General → Workflow permissions** and enable
**Read and write permissions** so the heartbeat branch can be pushed.

## Re-encrypting with a new secret

```bash
# Generate a new key and encrypt
KEY=$(openssl rand -hex 32)
openssl enc -aes-256-cbc -salt -pbkdf2 -in secret.txt -out secret.enc -pass pass:"$KEY"

# Then update the DEADMAN_KEY secret in GitHub with the new $KEY value
```
