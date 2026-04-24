#!/usr/bin/env bash
set -euo pipefail

echo "=============================="
echo "Coder Self-Hosted Installation"
echo "=============================="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Please run as root (sudo bash install-coder.sh)"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &>/dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    exit 1
fi

echo "✅ Docker found"
echo ""

# Load or prompt for configuration
CONFIG_FILE="/root/.coder-install-config"

if [ -f "$CONFIG_FILE" ]; then
    echo "📋 Loading saved configuration..."
    source "$CONFIG_FILE"
    echo "   Domain: $DOMAIN"
    echo "   Email: $EMAIL"
    echo ""
else
    # Use command line arguments if provided
    if [ $# -eq 2 ]; then
        DOMAIN="$1"
        EMAIL="$2"
        echo "📋 Using provided configuration:"
        echo "   Domain: $DOMAIN"
        echo "   Email: $EMAIL"
        echo ""
    else
        read -p "Enter your domain (e.g., mycoder.dev): " DOMAIN
        read -p "Enter your email for Let's Encrypt SSL: " EMAIL

        echo ""
        echo "📋 Configuration:"
        echo "   Domain: $DOMAIN"
        echo "   Email: $EMAIL"
        echo ""
        read -p "Continue with installation? (y/n) " -n 1 -r
        echo ""
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Installation cancelled"
            exit 1
        fi
    fi

    # Save configuration
    cat > "$CONFIG_FILE" <<CONF
DOMAIN=$DOMAIN
EMAIL=$EMAIL
CONF
fi

# Create directory for Coder
CODER_DIR="/opt/coder"
mkdir -p "$CODER_DIR"
cd "$CODER_DIR"

# Install Coder if not already installed
if ! command -v coder &>/dev/null; then
    echo ""
    echo "📦 Installing Coder..."
    curl -fsSL https://coder.com/install.sh | sh

    if ! command -v coder &>/dev/null; then
        echo "❌ Failed to install Coder"
        exit 1
    fi
    echo "✅ Coder installed"
else
    echo "✅ Coder already installed"
fi

# Install Traefik for reverse proxy and SSL
if ! command -v traefik &>/dev/null; then
    echo ""
    echo "📦 Installing Traefik..."
    TRAEFIK_VERSION="v3.2.3"
    curl -fsSL "https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_linux_amd64.tar.gz" \
        -o /tmp/traefik.tar.gz
    tar -xzf /tmp/traefik.tar.gz -C /usr/local/bin traefik
    chmod +x /usr/local/bin/traefik
    rm /tmp/traefik.tar.gz
    echo "✅ Traefik installed"
else
    echo "✅ Traefik already installed"
fi

# Create Traefik configuration
echo ""
echo "📝 Creating Traefik configuration..."
mkdir -p /etc/traefik
cat > /etc/traefik/traefik.yml <<TRAEFIK_CONFIG
entryPoints:
  web:
    address: ":80"
    http:
      redirections:
        entryPoint:
          to: websecure
          scheme: https
  websecure:
    address: ":443"

certificatesResolvers:
  letsencrypt:
    acme:
      email: $EMAIL
      storage: /etc/traefik/acme.json
      httpChallenge:
        entryPoint: web

providers:
  file:
    filename: /etc/traefik/dynamic.yml
    watch: true

log:
  level: INFO

api:
  dashboard: false
TRAEFIK_CONFIG

# Create dynamic configuration for Coder
cat > /etc/traefik/dynamic.yml <<DYNAMIC_CONFIG
http:
  routers:
    # Routeur Coder
    coder:
      # Utilisation du Host simple pour le domaine racine
      # ET du HostRegexp pour le wildcard. C'est le compromis le plus courant.
      # L'échappement du point est crucial dans HostRegexp.
      rule: "Host(`$DOMAIN`) || HostRegexp(`^.+\\.domain\\.dev$`)"
      entryPoints:
        - websecure
      tls:
        certResolver: letsencrypt
        domains:
          - main: "$DOMAIN"
            # Les SAN (Subject Alternative Names) sont ajoutés dynamiquement

      middlewares:
        - coder-headers
      service: coder

  services:
    coder:
      loadBalancer:
        servers:
          - url: "http://127.0.0.1:3000"

  middlewares:
    coder-headers:
      headers:
        customRequestHeaders:
          X-Forwarded-Proto: https
DYNAMIC_CONFIG

touch /etc/traefik/acme.json
chmod 600 /etc/traefik/acme.json

# Create Traefik systemd service
cat > /etc/systemd/system/traefik.service <<TRAEFIK_SERVICE
[Unit]
Description=Traefik
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/traefik --configFile=/etc/traefik/traefik.yml
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
TRAEFIK_SERVICE

# Create Coder systemd service
cat > /etc/systemd/system/coder.service <<CODER_SERVICE
[Unit]
Description=Coder
After=network-online.target docker.service
Wants=network-online.target
Requires=docker.service

[Service]
Type=simple
User=root
WorkingDirectory=$CODER_DIR
Environment="CODER_ACCESS_URL=https://$DOMAIN"
Environment="CODER_HTTP_ADDRESS=127.0.0.1:3000"
Environment="CODER_PG_CONNECTION_URL=postgres://coder:coder@localhost/coder?sslmode=disable"
Environment="CODER_WILDCARD_ACCESS_URL=*.$DOMAIN"
ExecStart=/usr/local/bin/coder server
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
CODER_SERVICE

# Install PostgreSQL if not installed
if ! command -v psql &>/dev/null; then
    echo ""
    echo "📦 Installing PostgreSQL..."
    apt-get update -qq
    apt-get install -y -qq postgresql postgresql-contrib
    echo "✅ PostgreSQL installed"
else
    echo "✅ PostgreSQL already installed"
fi

# Configure PostgreSQL for Coder
echo ""
echo "📝 Configuring PostgreSQL..."
systemctl enable postgresql
systemctl start postgresql

# Create Coder database and user
sudo -u postgres psql -c "CREATE DATABASE coder;" 2>/dev/null || echo "   Database 'coder' already exists"
sudo -u postgres psql -c "CREATE USER coder WITH PASSWORD 'coder';" 2>/dev/null || echo "   User 'coder' already exists"
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE coder TO coder;" 2>/dev/null || true
sudo -u postgres psql -d coder -c "GRANT ALL ON SCHEMA public TO coder;" 2>/dev/null || true

echo ""
echo "🚀 Starting services..."
systemctl daemon-reload
systemctl enable traefik coder
systemctl restart traefik
systemctl restart coder

echo ""
echo "⏳ Waiting for Coder to be ready..."
sleep 10

# Wait for Coder to be accessible
timeout 60 bash -c 'until curl -sf http://localhost:3000 >/dev/null 2>&1; do sleep 2; done' || true

echo ""
echo "✅ Coder installation complete!"
echo ""
echo "================================"
echo "Next Steps:"
echo "================================"
echo ""
echo "1. Point your DNS records to this server:"
echo "   - $DOMAIN → $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP')"
echo "   - *.$DOMAIN → $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP') (wildcard)"
echo ""
echo "2. Wait for DNS to propagate (can take up to 30 minutes)"
echo ""
echo "3. Access Coder at: https://$DOMAIN"
echo ""
echo "4. Create your first admin user via the web UI"
echo ""
echo "5. Create templates and workspaces!"
echo ""
echo "Useful commands:"
echo "  - Check Coder status: systemctl status coder"
echo "  - View Coder logs: journalctl -u coder -f"
echo "  - Check Traefik status: systemctl status traefik"
echo "  - View Traefik logs: journalctl -u traefik -f"
echo "  - Restart Coder: systemctl restart coder"
echo ""
echo "Configuration files:"
echo "  - Coder data: $CODER_DIR"
echo "  - Traefik config: /etc/traefik/"
echo "  - Services: /etc/systemd/system/coder.service"
echo ""
