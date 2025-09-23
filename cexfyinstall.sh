#!/usr/bin/env bash
set -euo pipefail

# === cexfy installation script ===

echo "=== cexfy installation ==="

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

# 4. Create systemd service file
SERVICE_FILE="/etc/systemd/system/cexfy.service"
sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=cexfy service
After=network.target

[Service]
WorkingDirectory=$INSTALL_DIR
ExecStart=/usr/bin/python3 $INSTALL_DIR/app.py
Environment="CEXFY_DOMAIN=$CEXFY_DOMAIN"
Restart=always
User=cexfy

[Install]
WantedBy=multi-user.target
EOF

# 5. Reload systemd and enable service
sudo systemctl daemon-reload
sudo systemctl enable --now cexfy

echo "=== Installation complete ==="
echo "cexfy is running as a systemd service."
echo "Domain configured: $CEXFY_DOMAIN"
echo "Use: sudo systemctl status cexfy"
