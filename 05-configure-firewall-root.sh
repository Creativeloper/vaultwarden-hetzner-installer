#!/bin/bash
set -e

echo ">>> [5/6] Firewall (UFW) wird konfiguriert (als root)..."

# UFW installieren (falls noch nicht geschehen)
if ! command -v ufw &> /dev/null
then
    echo ">>> UFW wird installiert..."
    apt update
    apt install -y ufw
fi

# Standardregeln setzen (optional, aber gut)
ufw default deny incoming
ufw default allow outgoing

# Notwendige Ports öffnen
ufw allow OpenSSH  # Oder 'ufw allow 22/tcp'
ufw allow 'Nginx Full' # Erlaubt HTTP (80) und HTTPS (443)

# Firewall aktivieren (BENÖTIGT BESTÄTIGUNG 'y')
echo ">>> Firewall wird aktiviert. ACHTUNG: Bestätige die nächste Abfrage mit 'y'!"
ufw enable

# Status anzeigen
echo ">>> Aktueller Firewall-Status:"
ufw status verbose

echo ">>> [5/6] Firewall-Konfiguration abgeschlossen."
