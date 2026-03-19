#!/bin/bash
set -euxo pipefail

APP_DIR="/opt/strapi-app"
PG_DB="strapidb"
PG_USER="strapiuser"
PG_PASS="ChangeMe_StrongPassword"
PG_PORT="5432"

cat >/opt/healthz.py <<'EOF'
from http.server import BaseHTTPRequestHandler, HTTPServer

class H(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path in ("/", "/health", "/healthz"):
            self.send_response(200)
            self.end_headers()
            self.wfile.write(b"OK")
        else:
            self.send_response(404)
            self.end_headers()

HTTPServer(("0.0.0.0", 80), H).serve_forever()
EOF

nohup python3 /opt/healthz.py >/var/log/healthz.log 2>&1 &

log() { echo "[user-data] $*"; }

dnf -y update || yum -y update
dnf -y install git gcc-c++ make nodejs || yum -y install git gcc-c++ make nodejs

# Install pm2
npm i -g pm2

# App user
id -u strapi >/dev/null 2>&1 || useradd -m -s /bin/bash strapi

#install postgres

dnf -y install postgresql16-server || true
if command -v postgresql-setup >/dev/null 2>&1; then
  # AL2 / some builds
  postgresql-setup --initdb || true
elif [ -x /usr/bin/postgresql-setup ]; then
  /usr/bin/postgresql-setup --initdb || true
fi

systemctl enable postgresql || systemctl enable postgresql-16 || true
systemctl restart postgresql || systemctl restart postgresql-16 || true

if id -u postgres >/dev/null 2>&1; then
  # Create DB user if not exists
  sudo -u postgres psql -tc "SELECT 1 FROM pg_roles WHERE rolname='${PG_USER}'" | grep -q 1 || \
    sudo -u postgres psql -c "CREATE USER ${PG_USER} WITH PASSWORD '${PG_PASS}';"

  # Create DB if not exists
  sudo -u postgres psql -tc "SELECT 1 FROM pg_database WHERE datname='${PG_DB}'" | grep -q 1 || \
    sudo -u postgres psql -c "CREATE DATABASE ${PG_DB} OWNER ${PG_USER};"
else
  log "WARN: postgres OS user not found; skipping DB user/db creation."
fi


mkdir -p "$APP_DIR"
chown -R strapi:strapi "$APP_DIR"
touch "$APP_DIR/index.html"

# Build & start
sudo -u strapi bash -lc "cd $APP_DIR && npm install && npm run build"
sudo -u strapi bash -lc "pm2 start npm --name strapi -- start"
sudo -u strapi bash -lc "pm2 save"

# Start pm2 on boot
pm2 startup systemd -u strapi --hp /home/strapi | bash