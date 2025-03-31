# Vaultwarden Installation Scripts für Hetzner ARM64 Server

Dieses Repository enthält Shell-Skripte zur automatisierten Installation von [Vaultwarden](https://github.com/dani-garcia/vaultwarden) (einem alternativen Bitwarden-Server, geschrieben in Rust) auf einem Hetzner Cloud Server mit ARM64-Architektur (z.B. CAX11, CAX21 etc.).

Die Installation verwendet:

*   **Docker & Docker Compose:** Für die einfache Verwaltung des Vaultwarden-Containers.
*   **Nginx:** Als Reverse Proxy für HTTPS/SSL-Terminierung.
*   **Certbot:** Zur automatischen Beschaffung und Erneuerung von Let's Encrypt SSL-Zertifikaten.
*   **UFW:** Als einfache Firewall zur Absicherung des Servers.

**Die Skripte müssen vor der Ausführung an deine Umgebung angepasst werden (siehe Abschnitt "Konfiguration").**

---

## Voraussetzungen

1.  **Hetzner ARM64 Server:** Ein neu erstellter oder sauberer Hetzner Cloud Server (z.B. CAX11) mit installiertem Ubuntu 22.04 LTS oder Debian 11/12.
2.  **Domain Name:** Eine Domain (z.B. `example.com`), für die du die DNS-Einstellungen verwalten kannst.
3.  **DNS-Eintrag:** Ein `A`-Record für die gewünschte Subdomain (z.B. `vault.example.com`), der auf die öffentliche IPv4-Adresse deines Servers zeigt. Optional ein `AAAA`-Record für die IPv6-Adresse.
    *   *Beispiel A-Record:* `vault IN A <your-server-ipv4-address>`
    *   *Beispiel AAAA-Record:* `vault IN AAAA <your-server-ipv6-address>`
    *   **Wichtig:** Der DNS-Eintrag muss aktiv sein und auflösen, *bevor* du das Skript für Nginx/Certbot ausführst.
4.  **SSH-Zugang:** Zugriff auf deinen Server via SSH.
5.  **Benutzer:** Du benötigst entweder:
    *   Zugriff als `root`-Benutzer.
    *   Zugriff als normaler Benutzer mit `sudo`-Rechten.

---

## Konfiguration (Vor der Ausführung!)

Bevor du die Skripte ausführst, **musst** du sie an deine Domain anpassen. Bearbeite die folgenden Dateien:

1.  **`03-setup-vaultwarden.sh`** (oder `03-setup-vaultwarden-root.sh`):
    *   Passe den Wert der `DOMAIN`-Umgebungsvariable in der `docker-compose.yml`-Sektion an deine vollständige Vaultwarden-URL an (inkl. `https://`).
        ```yaml
        environment:
          # ...
          DOMAIN: 'https://vault.example.com' # <-- HIER DEINE DOMAIN EINTRAGEN
        ```
2.  **`04-setup-nginx-certbot.sh`** (oder `04-setup-nginx-certbot-root.sh`):
    *   Passe den Wert der `DOMAIN`-Variable am Anfang des Skripts an deine vollständige Vaultwarden-Domain an.
        ```bash
        DOMAIN="vault.example.com" # <-- HIER DEINE DOMAIN EINTRAGEN
        ```
    *   Überprüfe alle Vorkommen von `${DOMAIN}` in der Nginx-Konfigurations-Sektion (`tee /etc/nginx/sites-available/vaultwarden.conf ... EOF`), um sicherzustellen, dass sie korrekt ersetzt werden.
    *   Der `certbot`-Befehl am Ende des Skripts verwendet die Variable `${DOMAIN}` und sollte automatisch korrekt sein, wenn die Variable oben richtig gesetzt wurde.

---

## Installation

**WICHTIG:** Wähle **eine** der beiden folgenden Methoden, je nachdem, ob du die Skripte als `root` oder als Benutzer mit `sudo`-Rechten ausführen möchtest.

**1. Repository klonen oder Skripte herunterladen:**

```bash
# Ersetze <URL-dieses-Repositories> durch die tatsächliche URL
git clone <URL-dieses-Repositories>
cd <repository-verzeichnis>
# ODER: Lade die .sh Dateien manuell herunter
```

**2. Skripte ausführbar machen:**

```bash
chmod +x *.sh
```

**3. Skripte ausführen (Nachdem du die Konfiguration angepasst hast!):**

---

### Methode A: Ausführung als Benutzer mit `sudo`-Rechten (Empfohlen)

*   Die Vaultwarden-Daten werden standardmäßig in `~/vaultwarden` (Home-Verzeichnis des Benutzers) gespeichert.
*   Du wirst mehrmals nach deinem `sudo`-Passwort gefragt.

```bash
# 1. Server vorbereiten
sudo ./01-prepare-server.sh

# 2. Docker installieren (fügt deinen Benutzer zur docker-Gruppe hinzu)
sudo ./02-install-docker.sh
# WICHTIG: Nach diesem Skript ausloggen und wieder einloggen!
exit
# Erneut per SSH verbinden...

# 3. Vaultwarden Konfiguration erstellen (ohne sudo!)
# ACHTUNG: Notiere dir den angezeigten ADMIN_TOKEN sicher!
./03-setup-vaultwarden.sh

# 4. Nginx & Certbot einrichten (mit sudo)
# Folge den Anweisungen von Certbot (E-Mail angeben, AGB zustimmen, Redirect wählen)
sudo ./04-setup-nginx-certbot.sh

# 5. Firewall konfigurieren (mit sudo)
# Bestätige die Aktivierung von UFW mit 'y'
sudo ./05-configure-firewall.sh

# 6. Vaultwarden starten (ohne sudo, da du jetzt in der docker-Gruppe bist)
./06-start-vaultwarden.sh
```

---

### Methode B: Ausführung als `root`-Benutzer

*   Die Vaultwarden-Daten werden standardmäßig in `/root/vaultwarden` gespeichert.
*   Verwende die Skripte mit dem Suffix `-root`.

```bash
# Stelle sicher, dass du als root angemeldet bist

# 1. Server vorbereiten
./01-prepare-server-root.sh

# 2. Docker installieren
./02-install-docker-root.sh

# 3. Vaultwarden Konfiguration erstellen
# ACHTUNG: Notiere dir den angezeigten ADMIN_TOKEN sicher!
./03-setup-vaultwarden-root.sh

# 4. Nginx & Certbot einrichten
# Folge den Anweisungen von Certbot (E-Mail angeben, AGB zustimmen, Redirect wählen)
./04-setup-nginx-certbot-root.sh

# 5. Firewall konfigurieren
# Bestätige die Aktivierung von UFW mit 'y'
./05-configure-firewall-root.sh

# 6. Vaultwarden starten
./06-start-vaultwarden-root.sh
```

---

## Nach der Installation (WICHTIG!)

1.  **Zugriff:** Öffne `https://<deine-domain.com>` (die Domain, die du konfiguriert hast) im Browser.
2.  **Ersten Account erstellen:** Klicke auf "Konto erstellen" und registriere deinen Hauptbenutzer.
3.  **Admin-Panel:** Gehe zu `https://<deine-domain.com>/admin`.
4.  **Admin-Login:** Gib den `ADMIN_TOKEN` ein, der von Skript `03` ausgegeben und von dir gespeichert wurde.
5.  **!!! REGISTRIERUNGEN DEAKTIVIEREN !!!:** Gehe im Admin-Panel zu `Einstellungen` -> `Allgemein` und **entferne den Haken** bei "**Registrierungen erlauben**" (Allow new signups). Klicke auf "Speichern". Dies verhindert, dass sich Fremde auf deinem Server registrieren.
6.  **(Optional) SMTP konfigurieren:** Richte unter `Einstellungen` -> `SMTP Email Settings` einen E-Mail-Server ein, damit Vaultwarden E-Mails senden kann (z.B. für Einladungen).
7.  **Clients einrichten:** Verwende die offiziellen Bitwarden-Clients (Browser-Erweiterung, Desktop, Mobile) und trage bei der Server-URL deine eigene Domain ein (`https://<deine-domain.com>`).

---

## Wartung

### System-Updates

Halte dein Server-Betriebssystem aktuell:

```bash
sudo apt update && sudo apt upgrade -y
```

### Vaultwarden-Update

Aktualisiere den Vaultwarden Docker-Container:

```bash
# Wechsle in das Vaultwarden-Verzeichnis
# (Standard: cd ~/vaultwarden oder cd /root/vaultwarden)
cd <pfad-zum-vaultwarden-verzeichnis>

# Lade das neueste Image herunter
docker compose pull

# Starte den Container mit dem neuen Image neu
docker compose up -d

# (Optional) Entferne alte, ungenutzte Docker-Images
docker image prune -f
```

---

## Sicherheitshinweise

*   **ADMIN\_TOKEN:** Bewahre deinen Admin-Token sicher auf. Er gewährt vollen Zugriff auf die Vaultwarden-Admin-Einstellungen.
*   **Registrierungen:** Deaktiviere öffentliche Registrierungen nach der Erstellung deines ersten Accounts.
*   **Firewall:** Stelle sicher, dass die Firewall (UFW) aktiv ist und nur die notwendigen Ports (SSH, HTTP, HTTPS) offen sind.
*   **Backups:** **EXTREM WICHTIG!** Richte regelmäßige Backups des Vaultwarden-Datenverzeichnisses ein (Standard: `~/vaultwarden/vw-data` oder `/root/vaultwarden/vw-data`). Dieses Verzeichnis enthält alle deine verschlüsselten Tresordaten. Ohne Backup sind deine Daten bei einem Serverausfall oder Fehler verloren!
*   **System-Updates:** Halte den Server und alle Pakete regelmäßig aktuell.

---

## Troubleshooting

*   **`ERR_TOO_MANY_REDIRECTS`:** Oft ein Problem mit der Nginx-Konfiguration nach der Certbot-Einrichtung. Stelle sicher, dass der `server`-Block für Port 443 die `proxy_set_header X-Forwarded-Proto $scheme;`-Anweisung enthält und keine eigene Weiterleitung auf HTTPS mehr macht. Überprüfe `/etc/nginx/sites-enabled/vaultwarden.conf`.
*   **Seite nicht erreichbar:** Prüfe, ob die DNS-Einträge korrekt gesetzt sind und weltweit propagiert wurden. Überprüfe den Status von Nginx (`systemctl status nginx`) und Docker (`docker ps`). Prüfe die Firewall (`sudo ufw status`).
*   **Zertifikatsprobleme:** Stelle sicher, dass der DNS-Eintrag korrekt war, *bevor* Certbot ausgeführt wurde. Teste die Erneuerung mit `sudo certbot renew --dry-run`.

---

## Disclaimer

Diese Skripte werden ohne Gewähr bereitgestellt. Die Nutzung erfolgt auf eigene Gefahr. Überprüfe die Skripte vor der Ausführung und stelle sicher, dass du verstehst, was sie tun und dass du sie korrekt an deine Umgebung angepasst hast. Der Autor übernimmt keine Haftung für Datenverlust oder andere Probleme, die durch die Verwendung dieser Skripte entstehen könnten. Denke immer an Backups!
