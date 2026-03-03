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

### 1. Create a Personal Access Token (PAT)

The workflow needs a classic PAT (not fine-grained) because it requires permissions
that fine-grained tokens don't support (collaborator management, repo transfers).

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. Click **Generate new token** → **Generate new token (classic)**
3. Give it a descriptive name like `dead-mans-switch`
4. Set expiration to **No expiration** (critical — if the token expires before the
   switch triggers, it fails silently and your successor gets nothing)
5. Select these scopes:
   - `repo` (full control of private repositories)
   - `admin:org` → `write:org` (only needed if transferring to an org)
6. Click **Generate token** and copy it immediately — you won't see it again

### 2. GitHub Secrets & Variables

Go to your repo's **Settings → Secrets and variables → Actions**.

Under the **Secrets** tab, add:

| Name          | Value                                                     |
|---------------|-----------------------------------------------------------|
| `DEADMAN_PAT` | The classic PAT you just created                          |
| `DEADMAN_KEY` | The AES-256 encryption key used to encrypt `secret.enc`   |

Under the **Variables** tab, add:

| Name                 | Value                                              |
|----------------------|----------------------------------------------------|
| `SUCCESSOR_USERNAME` | GitHub username of the person who inherits access  |

### 3. Workflow Permissions

Go to **Settings → Actions → General → Workflow permissions** and enable
**Read and write permissions** so the heartbeat branch can be pushed.

## Re-encrypting with a new secret

```bash
# Generate a new key and encrypt
KEY=$(openssl rand -hex 32)
openssl enc -aes-256-cbc -salt -pbkdf2 -in secret.txt -out secret.enc -pass pass:"$KEY"
echo $KEY
# Then update the DEADMAN_KEY secret in GitHub with the new $KEY value
```
