#!/usr/bin/env bash
set -euo pipefail

HIDDIFY_ROOT="/opt/hiddify-manager/nginx"
SRC_ROOT="/opt/cexfy/nginx"
SERVICE="hiddify-nginx"

# Pick nginx binary: prefer bundled one, fallback to system
NGINX_BIN=""
for candidate in "$HIDDIFY_ROOT/sbin/nginx" /usr/sbin/nginx /usr/local/sbin/nginx; do
    if [[ -x $candidate ]]; then
        NGINX_BIN=$candidate
        break
    fi
done

if [[ -z $NGINX_BIN ]]; then
    echo "Error: nginx binary not found in expected locations" >&2
    exit 1
fi

if [[ ! -d $HIDDIFY_ROOT ]]; then
    echo "Hiddify nginx directory not found, skipping restore."
    exit 0
fi

NGINX_CONF="$HIDDIFY_ROOT/nginx.conf"
if [[ ! -f $NGINX_CONF ]]; then
    echo "Error: nginx config not found: $NGINX_CONF" >&2
    exit 1
fi

mapfile -t FILES <<'EOF'
conf.d/xray-base.conf
conf.d/xray-base.conf.j2
EOF

copied_any=0
for rel in "${FILES[@]}"; do
    src="$SRC_ROOT/$rel"
    dst="$HIDDIFY_ROOT/$rel"
    if [[ ! -f $src ]]; then
        echo "Warning: source file missing, skipping: $src" >&2
        continue
    fi
    install -D "$src" "$dst"
    echo "Copied $src -> $dst"
    copied_any=1
done

if [[ $copied_any -eq 0 ]]; then
    echo "No files were copied; aborting reload" >&2
    exit 1
fi

echo "Using nginx binary: $NGINX_BIN"
echo "Testing nginx configuration..."
if "$NGINX_BIN" -t -c "$NGINX_CONF"; then
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
