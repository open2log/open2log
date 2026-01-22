#!/usr/bin/env bash
# Extracts SSH host keys from SOPS and storage box credentials
# Called by nixos-anywhere during deployment
set -euo pipefail

SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# SSH host keys from SOPS
secret_file="$SCRIPT_DIR/../../secrets/hosts/$NIXOS_SYSTEM_NAME.yaml"

if [ -f "$secret_file" ]; then
  mkdir -p "./etc/ssh"

  # Decrypt once and extract both keys (reduces age key prompts)
  decrypted=$(sops -d "$secret_file")

  umask 0177
  echo "$decrypted" | yq -r '.ssh_host_ed25519_key' > "./etc/ssh/ssh_host_ed25519_key"

  umask 0133
  echo "$decrypted" | yq -r '.ssh_host_ed25519_key_pub // .["ssh_host_ed25519_key.pub"]' > "./etc/ssh/ssh_host_ed25519_key.pub"

  echo "Extracted SSH host keys"
else
  echo "Warning: No SSH host key file at $secret_file, will generate new keys"
fi

# Storage box credentials
if [ -n "${STORAGEBOX_SERVER:-}" ]; then
  umask 0022  # Reset umask for directory creation
  mkdir -p "./var/lib/secrets"
  umask 0177  # Restrictive for the secret file

  cat >./var/lib/secrets/storagebox.env <<EOF
STORAGEBOX_SERVER=${STORAGEBOX_SERVER}
STORAGEBOX_PASSWORD=${STORAGEBOX_PASSWORD}
STORAGEBOX_ID=${STORAGEBOX_ID}
STORAGEBOX_WEBDAV_URL=https://${STORAGEBOX_SERVER}
EOF

  chmod 600 ./var/lib/secrets/storagebox.env
  echo "Generated storage box credentials"
fi
