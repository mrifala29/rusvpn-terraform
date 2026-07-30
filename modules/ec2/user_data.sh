#!/bin/bash
set -e

# --- Install Docker ---
apt-get update -y
apt-get install -y apt-transport-https ca-certificates curl software-properties-common git

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

systemctl enable docker
systemctl start docker
usermod -aG docker ubuntu

# --- Persiapan direktori ---
mkdir -p /opt/rusvpn
chown -R ubuntu:ubuntu /opt/rusvpn

# --- Deteksi IP Publik dari AWS Metadata API ---
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

# --- Tulis .env (IP otomatis dari metadata) ---
cat > /opt/rusvpn/.env << EOF
OVPN_CLIENT_REMOTE_HOST=${PUBLIC_IP}
OVPN_PORT=1194
OVPN_PROTO=udp
OVPN_CLIENT_NAMES=demo-client
OVPN_SERVER_NET=10.8.0.0
OVPN_SERVER_MASK=255.255.255.0
OVPN_ENABLE_NAT=false
OVPN_PUSH_DNS=1.1.1.1
OVPN_PUSH_ROUTES=
OVPN_ENABLE_REQUEST_WATCHER=true
OVPN_REQUEST_POLL_SECONDS=5
OVPN_PROFILE_MODE=0640
OVPN_PROFILE_GID=
EOF

# --- Tulis docker-compose.yml ---
cat > /opt/rusvpn/docker-compose.yml << 'COMPOSE'
services:
  openvpn-server:
    image: ${IMAGE_NAME:-registry.gitlab.com/CHANGE_ME/openvpn-service:latest}
    container_name: openvpn-server
    restart: unless-stopped
    cap_add:
      - NET_ADMIN
    devices:
      - /dev/net/tun:/dev/net/tun
    sysctls:
      - net.ipv4.ip_forward=1
    ports:
      - "${OVPN_PORT:-1194}:${OVPN_PORT:-1194}/udp"
    environment:
      OVPN_CLIENT_REMOTE_HOST: "${OVPN_CLIENT_REMOTE_HOST}"
      OVPN_PORT: "${OVPN_PORT:-1194}"
      OVPN_PROTO: "${OVPN_PROTO:-udp}"
      OVPN_CLIENT_NAMES: "${OVPN_CLIENT_NAMES:-demo-client}"
      OVPN_SERVER_NET: "${OVPN_SERVER_NET:-10.8.0.0}"
      OVPN_SERVER_MASK: "${OVPN_SERVER_MASK:-255.255.255.0}"
      OVPN_ENABLE_NAT: "${OVPN_ENABLE_NAT:-false}"
      OVPN_PUSH_DNS: "${OVPN_PUSH_DNS:-1.1.1.1}"
      OVPN_PUSH_ROUTES: "${OVPN_PUSH_ROUTES:-}"
      OVPN_ENABLE_REQUEST_WATCHER: "${OVPN_ENABLE_REQUEST_WATCHER:-true}"
      OVPN_REQUEST_POLL_SECONDS: "${OVPN_REQUEST_POLL_SECONDS:-5}"
      OVPN_PROFILE_MODE: "${OVPN_PROFILE_MODE:-0640}"
      OVPN_PROFILE_GID: "${OVPN_PROFILE_GID:-}"
    volumes:
      - openvpn-pki:/etc/openvpn/easy-rsa/pki-volume
      - vpn-profile-shared:/shared
      - vpn-requests:/requests
    healthcheck:
      test: ["CMD", "ss", "-ulnp"]
      interval: 10s
      timeout: 5s
      retries: 5

volumes:
  openvpn-pki:
  vpn-profile-shared:
  vpn-requests:
COMPOSE

chown -R ubuntu:ubuntu /opt/rusvpn
echo "Server ready. Run 'docker compose up -d' from /opt/rusvpn to start OpenVPN."
