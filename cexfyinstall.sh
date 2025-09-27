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

# 4. Create virtual environment
echo "Creating virtual environment..."
sudo -u cexfy python3 -m venv "$INSTALL_DIR/venv"

# 5. Install Python dependencies
echo "Installing Python dependencies..."
sudo -u cexfy "$INSTALL_DIR/venv/bin/pip" install --upgrade pip
sudo -u cexfy "$INSTALL_DIR/venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"

# 6. Create systemd service
SERVICE_FILE="/etc/systemd/system/cexfy.service"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=cexfy service
After=network.target

[Service]
WorkingDirectory=$INSTALL_DIR
ExecStart=$INSTALL_DIR/venv/bin/python $INSTALL_DIR/app.py
Environment="CEXFY_DOMAIN=$CEXFY_DOMAIN"
Restart=always
User=cexfy

[Install]
WantedBy=multi-user.target
EOF

# 7. Enable and start service
sudo systemctl daemon-reload
sudo systemctl enable --now cexfy

echo "=== Installation complete ==="
echo "cexfy is running as a systemd service."
echo "Domain configured: $CEXFY_DOMAIN"
echo "Use: sudo systemctl status cexfy"
