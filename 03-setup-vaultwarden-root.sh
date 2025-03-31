#!/bin/bash
set -e

echo ">>> [3/6] Vaultwarden Verzeichnis und Konfiguration werden erstellt (in /root/vaultwarden)..."

# Vaultwarden Verzeichnis im Home-Verzeichnis von root erstellen
mkdir -p /root/vaultwarden
cd /root/vaultwarden

# Starken Admin-Token generieren
ADMIN_TOKEN=$(openssl rand -base64 48)

# docker-compose.yml erstellen
cat << EOF > docker-compose.yml
version: '3'

services:
  vaultwarden:
    image: vaultwarden/server:latest
    container_name: vaultwarden
    restart: always
    environment:
      # WICHTIG: Dies ist dein Admin-Token! Sicher aufbewahren!
      ADMIN_TOKEN: '${ADMIN_TOKEN}'
      WEBSOCKET_ENABLED: 'true'
      SIGNUPS_ALLOWED: 'true'    # Später im Admin-Panel deaktivieren!
      DOMAIN: 'https://<DEINE_DOMAIN>'
    volumes:
      # Wird auf /root/vaultwarden/vw-data auf dem Host gemappt
      - ./vw-data:/data
    ports:
      # Nur auf localhost mappen
      - '127.0.0.1:8080:80'
      - '127.0.0.1:3012:3012'

volumes:
  vw-data:
EOF

echo ">>> [3/6] Vaultwarden Konfiguration erstellt in /root/vaultwarden."
echo ""
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!!! WICHTIG: Dein Vaultwarden Admin-Token ist:              !!!"
echo "!!! ${ADMIN_TOKEN}                                         !!!"
echo "!!!                                                         !!!"
echo "!!! Bitte kopiere diesen Token und bewahre ihn sicher auf!  !!!"
echo "!!! Du benötigst ihn für den Zugriff auf /admin.            !!!"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo ""

# Setze korrekte Berechtigungen für das Datenverzeichnis (optional, aber kann helfen)
# Docker sollte das meist selbst regeln, aber sicher ist sicher.
mkdir -p /root/vaultwarden/vw-data
# chown -R <container_user_id>:<container_group_id> /root/vaultwarden/vw-data
# Die IDs sind im Vaultwarden Image oft 33:33 (www-data) oder 1000:1000.
# Da es meist funktioniert, lassen wir es erstmal weg, um es einfach zu halten.
