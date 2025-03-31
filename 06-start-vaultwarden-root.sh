#!/bin/bash
set -e

echo ">>> [6/6] Vaultwarden Container wird gestartet (als root)..."

VAULTWARDEN_DIR="/root/vaultwarden"

# Ins Vaultwarden-Verzeichnis wechseln
if [ -d "$VAULTWARDEN_DIR" ]; then
    cd "$VAULTWARDEN_DIR"
else
    echo "FEHLER: Verzeichnis '$VAULTWARDEN_DIR' nicht gefunden. Stelle sicher, dass Skript 03 erfolgreich war."
    exit 1
fi

# Prüfen, ob docker compose verfügbar ist
if ! command -v docker compose &> /dev/null
then
    echo "FEHLER: 'docker compose' Befehl nicht gefunden. Ist Docker korrekt installiert (Skript 02)?"
    exit 1
fi

# Container starten
docker compose up -d

echo ">>> Vaultwarden Container gestartet."
echo ">>> Überprüfe den Status mit: docker compose ps"
echo ">>> Überprüfe die Logs mit: docker compose logs -f"
echo ""
echo ">>> [6/6] Vaultwarden Start abgeschlossen."
echo ""
echo ">>> NÄCHSTE SCHRITTE:"
echo "1. Öffne https://<DEINE_DOMAIN> in deinem Browser."
echo "2. Erstelle deinen ersten Benutzeraccount."
echo "3. Gehe zu https://<DEINE_DOMAIN>/admin"
echo "4. Logge dich mit dem ADMIN_TOKEN ein, der von Skript 03 angezeigt wurde."
echo "5. SEHR WICHTIG: Deaktiviere sofort die Option 'Registrierungen erlauben' unter Einstellungen -> Allgemein!"
echo "6. Konfiguriere optional SMTP für E-Mail-Funktionen."
echo "7. Richte deine Bitwarden-Clients ein (Server-URL: https://<DEINE_DOMAIN>)."
echo "8. Denke an regelmäßige Backups des Verzeichnisses '$VAULTWARDEN_DIR/vw-data'!"
