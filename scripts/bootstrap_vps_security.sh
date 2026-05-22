#!/usr/bin/env bash
set -euo pipefail

HOST="${VPS_ROOT_HOST:-root@186.246.45.66}"
PUBLIC_KEY="${PUBLIC_KEY:-$HOME/.ssh/pqh8temc_vps_ed25519.pub}"
DEPLOY_USER="${DEPLOY_USER:-deploy}"
REMOTE_KEY="/tmp/pqh8temc_vps_key.pub"

if [ ! -f "$PUBLIC_KEY" ]; then
    echo "Missing SSH public key: $PUBLIC_KEY" >&2
    exit 1
fi

scp "$PUBLIC_KEY" "$HOST:$REMOTE_KEY"

ssh "$HOST" "DEPLOY_USER='$DEPLOY_USER' REMOTE_KEY='$REMOTE_KEY' bash -s" <<'REMOTE'
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y fail2ban ufw

if ! id "$DEPLOY_USER" >/dev/null 2>&1; then
    useradd --create-home --shell /bin/bash --groups sudo "$DEPLOY_USER"
fi

install -d -m 700 -o "$DEPLOY_USER" -g "$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh"
touch "/home/$DEPLOY_USER/.ssh/authorized_keys"
chown "$DEPLOY_USER:$DEPLOY_USER" "/home/$DEPLOY_USER/.ssh/authorized_keys"
chmod 600 "/home/$DEPLOY_USER/.ssh/authorized_keys"

if ! grep -qxFf "$REMOTE_KEY" "/home/$DEPLOY_USER/.ssh/authorized_keys"; then
    cat "$REMOTE_KEY" >>"/home/$DEPLOY_USER/.ssh/authorized_keys"
fi

install -m 440 /dev/null "/etc/sudoers.d/90-$DEPLOY_USER-nopasswd"
printf '%s ALL=(ALL) NOPASSWD:ALL\n' "$DEPLOY_USER" >"/etc/sudoers.d/90-$DEPLOY_USER-nopasswd"
visudo -cf "/etc/sudoers.d/90-$DEPLOY_USER-nopasswd"

install -d -m 755 /etc/ssh/sshd_config.d
cat >/etc/ssh/sshd_config.d/01-pqh8temc-hardening.conf <<'SSHDCONFIG'
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
ChallengeResponseAuthentication no
PermitRootLogin no
SSHDCONFIG
rm -f /etc/ssh/sshd_config.d/99-pqh8temc-hardening.conf

sshd -t
ufw allow OpenSSH
ufw --force enable

systemctl enable --now fail2ban
systemctl reload ssh || systemctl reload sshd

rm -f "$REMOTE_KEY"
REMOTE

ssh -o BatchMode=yes -i "${PUBLIC_KEY%.pub}" "${DEPLOY_USER}@186.246.45.66" "echo 'deploy SSH key login ok'"
