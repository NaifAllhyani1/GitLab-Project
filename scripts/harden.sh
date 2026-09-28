#!/usr/bin/env bash
set -euo pipefail

[ "$(id -u)" -eq 0 ] || { echo "Run with sudo"; exit 1; }

apt-get update -y
apt-get install -y ufw fail2ban unattended-upgrades

ufw default deny incoming
ufw default allow outgoing
for port in 22 80 2222 8501; do
  ufw allow "$port"/tcp
done
ufw --force enable

printf 'APT::Periodic::Update-Package-Lists "1";\nAPT::Periodic::Unattended-Upgrade "1";\n' > /etc/apt/apt.conf.d/20auto-upgrades

user=${SUDO_USER:-azureuser}
if [ -s "/home/$user/.ssh/authorized_keys" ]; then
  printf 'PasswordAuthentication no\nPermitRootLogin no\n' > /etc/ssh/sshd_config.d/00-hardening.conf
  sshd -t
  systemctl reload ssh
else
  echo "No SSH key found for $user, skipping SSH password lockdown"
fi

systemctl enable --now fail2ban
ufw status verbose