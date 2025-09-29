#!/usr/bin/env bash
set -euo pipefail

# === cexfy installation script ===

echo "=== cexfy installation ==="

# 0. Check for python3-venv
if ! python3 -m venv --help >/dev/null 2>&1; then
    echo "python3-venv is missing, installing..."
    sudo apt update
    sudo apt install -y python3-venv
fi

# 1. Ask for domain
read -rp "Enter your Hiddify panel domain (e.g. panel.example.com): " CEXFY_DOMAIN
if [[ -z "$CEXFY_DOMAIN" ]]; then
    echo "Error: domain cannot be empty"
    exit 1
fi

# 2. Create dedicated system user (if not exists)
if ! id "cexfy" &>/dev/null; then
    echo "Creating system user 'cexfy'..."
    sudo adduser --system --no-create-home --group cexfy
fi

# 3. Install project files
INSTALL_DIR="/opt/cexfy"
sudo mkdir -p "$INSTALL_DIR"
sudo cp -r ./* "$INSTALL_DIR/"
sudo chown -R cexfy:cexfy "$INSTALL_DIR"

# 4. Deploy nginx helpers (if Hiddify is installed)
sudo chmod +x "$INSTALL_DIR/restore-nginx.sh"
if [[ -d "/opt/hiddify-manager/nginx" ]]; then
    echo "Deploying nginx overrides..."
    if ! sudo "$INSTALL_DIR/restore-nginx.sh"; then
        echo "Warning: restore-nginx.sh failed; nginx config was not updated" >&2
    fi
else
    echo "Warning: /opt/hiddify-manager/nginx not found, skipping nginx restore"
fi

# 5. Create virtual environment
echo "Creating virtual environment..."
sudo -u cexfy python3 -m venv "$INSTALL_DIR/venv"

# 6. Install Python dependencies
echo "Installing Python dependencies..."
sudo -u cexfy HOME=$INSTALL_DIR "$INSTALL_DIR/venv/bin/pip" install --upgrade pip
sudo -u cexfy HOME=$INSTALL_DIR "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"

# 7. Create systemd service for the API
SERVICE_FILE="/etc/systemd/system/cexfy.service"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=cexfy service
After=network.target

[Service]
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/gunicorn --bind 127.0.0.1:9100 --workers 3 --timeout 60 --forwarded-allow-ips=127.0.0.1 app:app
ExecReload=/bin/kill -s HUP \$MAINPID
Environment="CEXFY_DOMAIN=$CEXFY_DOMAIN"
Restart=always
User=cexfy

[Install]
WantedBy=multi-user.target
EOF

# 8. Install restore helper service
RESTORE_SERVICE_SOURCE="$INSTALL_DIR/cexfy-restore.service"
RESTORE_SERVICE_FILE="/etc/systemd/system/cexfy-restore.service"
RESTORE_SERVICE_INSTALLED=0
if [[ -f "$RESTORE_SERVICE_SOURCE" ]]; then
    echo "Installing cexfy-restore.service..."
    sudo cp "$RESTORE_SERVICE_SOURCE" "$RESTORE_SERVICE_FILE"
    RESTORE_SERVICE_INSTALLED=1
else
    echo "Warning: $RESTORE_SERVICE_SOURCE not found; restore service not installed" >&2
fi

# 9. Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable --now cexfy
if [[ $RESTORE_SERVICE_INSTALLED -eq 1 ]]; then
    sudo systemctl enable --now cexfy-restore
else
    echo "Reminder: install cexfy-restore.service manually if needed." >&2
fi

echo "=== Installation complete ==="
echo "cexfy is running as a systemd service."
echo "Domain configured: $CEXFY_DOMAIN"
echo "Use: sudo systemctl status cexfy"



