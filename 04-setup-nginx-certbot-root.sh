#!/bin/bash
set -e

DOMAIN="<DEINE_DOMAIN>"

echo ">>> [4/6] Nginx und Certbot werden installiert und konfiguriert für ${DOMAIN} (als root)..."

# Nginx installieren
apt install -y nginx

# Nginx Konfigurationsdatei für Vaultwarden erstellen
tee /etc/nginx/sites-available/vaultwarden.conf > /dev/null <<EOF
server {
    listen 80;
    server_name ${DOMAIN};

    # Für Let's Encrypt ACME Challenge & initiale Weiterleitung (Certbot passt dies an)
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        allow all;
    }
    location / {
        return 301 https://\$host\$request_uri;
    }
}

server {
    # Platzhalter - Certbot wird dies konfigurieren
    # listen 443 ssl http2;
    # listen [::]:443 ssl http2;
    server_name ${DOMAIN};

    # SSL Konfiguration (Certbot fügt dies hinzu/passt es an)
    # ssl_certificate /etc/letsencrypt/live/${DOMAIN}/fullchain.pem;
    # ssl_certificate_key /etc/letsencrypt/live/${DOMAIN}/privkey.pem;
    # include /etc/letsencrypt/options-ssl-nginx.conf;
    # ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Sicherheitseinstellungen
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options nosniff;
    add_header X-Frame-Options DENY;
    add_header Referrer-Policy "strict-origin-when-cross-origin";

    client_max_body_size 525M; # Für Dateianhänge

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /notifications/hub {
        proxy_pass http://127.0.0.1:3012;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }

    location /admin {
        proxy_pass http://127.0.0.1:8080/admin;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

# Nginx Konfiguration aktivieren
ln -sf /etc/nginx/sites-available/vaultwarden.conf /etc/nginx/sites-enabled/
# Ggf. Default-Seite entfernen, falls sie Port 80 belegt
if [ -f /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
fi

# Nginx Konfiguration testen
nginx -t

# Nginx neu laden, um Änderungen anzuwenden (noch ohne SSL)
systemctl reload nginx

echo ">>> Nginx konfiguriert. Installiere Certbot..."

# Certbot und Nginx-Plugin installieren
apt install -y certbot python3-certbot-nginx

echo ">>> Certbot wird nun ausgeführt, um ein SSL-Zertifikat für ${DOMAIN} zu erhalten."
echo ">>> Bitte folge den Anweisungen von Certbot:"
echo ">>> 1. Gib deine E-Mail-Adresse ein."
echo ">>> 2. Stimme den Nutzungsbedingungen zu."
echo ">>> 3. Wähle Option '2: Redirect', um HTTP auf HTTPS umzuleiten."

# Certbot interaktiv ausführen
certbot --nginx -d ${DOMAIN}

echo ">>> Certbot-Konfiguration abgeschlossen. Nginx wird neu geladen."
systemctl reload nginx

# Teste die automatische Erneuerung
certbot renew --dry-run

echo ">>> [4/6] Nginx und Certbot Konfiguration abgeschlossen."
