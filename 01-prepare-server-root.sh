#!/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

echo ">>> [1/6] Server wird vorbereitet und aktualisiert (als root)..."

# System aktualisieren
apt update
apt upgrade -y

# Notwendige Pakete installieren
apt install -y curl wget gnupg apt-transport-https ca-certificates software-properties-common

echo ">>> [1/6] Server-Vorbereitung abgeschlossen."
