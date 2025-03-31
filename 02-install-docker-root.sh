#!/bin/bash
set -e

echo ">>> [2/6] Docker und Docker Compose werden installiert (als root)..."

# Docker GPG-Schlüssel hinzufügen
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# Docker Repository hinzufügen
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

# Docker Engine und Compose Plugin installieren
apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Docker-Dienst starten und aktivieren
systemctl start docker
systemctl enable docker

# Docker-Installation testen
docker --version
docker compose version

echo ">>> [2/6] Docker und Docker Compose Installation abgeschlossen."
