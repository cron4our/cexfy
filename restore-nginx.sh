#!/usr/bin/env bash
set -euo pipefail

HIDDIFY_ROOT="/opt/hiddify-manager/nginx"
SRC="/opt/cexfy/nginx/conf.d/xray-base.conf"
DST="$HIDDIFY_ROOT/conf.d/xray-base.conf"
NGINX_BIN="$HIDDIFY_ROOT/sbin/nginx"
SERVICE="hiddify-nginx"

if [[ ! -d "$HIDDIFY_ROOT" ]]; then
    echo "Hiddify nginx directory not found, skipping restore."
    exit 0
fi

if [[ ! -f "$SRC" ]]; then
    echo "Error: source config not found: $SRC" >&2
    exit 1
fi

if [[ ! -x "$NGINX_BIN" ]]; then
    echo "Error: nginx binary not found: $NGINX_BIN" >&2
    exit 1
fi

install -d "$(dirname "$DST")"

echo "Copying $SRC -> $DST"
cp "$SRC" "$DST"

echo "Testing nginx configuration..."
if "$NGINX_BIN" -t; then
    if systemctl list-unit-files "$SERVICE.service" >/dev/null 2>&1; then
        echo "Reloading $SERVICE"
        systemctl reload "$SERVICE"
    else
        echo "Warning: systemd service $SERVICE not found; skipping reload"
    fi
else
    echo "nginx -t failed, aborting reload" >&2
    exit 1
fi
