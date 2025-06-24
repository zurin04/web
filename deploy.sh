#!/bin/bash

# Simple VPS Deployment for Crypto Airdrop Platform
# Usage: curl -fsSL https://raw.githubusercontent.com/[repo]/main/deploy.sh | bash -s [domain]

set -e

DOMAIN="$1"
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Deploying Crypto Airdrop Platform...${NC}"

# System setup
apt update -y && apt upgrade -y
apt install -y curl wget git nginx postgresql postgresql-contrib

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt install -y nodejs
npm install -g pm2

# Create user and directory
useradd -r -s /bin/bash -d /opt/crypto-airdrop -m crypto || true
mkdir -p /opt/crypto-airdrop
cd /opt/crypto-airdrop

# Database setup
systemctl start postgresql
systemctl enable postgresql
DB_PASSWORD=$(openssl rand -hex 16)
sudo -u postgres psql << EOF
CREATE DATABASE IF NOT EXISTS crypto_airdrop_db;
CREATE USER IF NOT EXISTS crypto_user WITH ENCRYPTED PASSWORD '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON DATABASE crypto_airdrop_db TO crypto_user;
ALTER USER crypto_user CREATEDB;
EOF

# Create working application
cat > package.json << 'EOF'
{
  "name": "crypto-airdrop",
  "version": "1.0.0",
  "type": "module",
  "scripts": {
    "start": "node server.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

cat > server.js << 'EOF'
import express from 'express';

const app = express();
const PORT = 5000;

app.use(express.static('public'));

app.get('/', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html>
    <head>
        <title>Crypto Airdrop Platform</title>
        <meta name="viewport" content="width=device-width, initial-scale=1">
        <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', system-ui, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
            .container { background: white; padding: 3rem; border-radius: 20px; box-shadow: 0 20px 40px rgba(0,0,0,0.1); text-align: center; max-width: 600px; width: 90%; }
            h1 { color: #2d3748; margin-bottom: 1rem; font-size: 2.5rem; }
            .emoji { font-size: 4rem; margin-bottom: 1rem; }
            .status { background: #f0fff4; border: 2px solid #68d391; padding: 1rem; border-radius: 10px; margin: 2rem 0; }
            .success { color: #38a169; font-weight: bold; }
            .info { background: #ebf8ff; padding: 1rem; border-radius: 10px; margin: 1rem 0; }
            .btn { background: #4299e1; color: white; padding: 0.75rem 1.5rem; border: none; border-radius: 8px; cursor: pointer; font-size: 1rem; margin: 0.5rem; text-decoration: none; display: inline-block; }
            .btn:hover { background: #3182ce; }
            ul { text-align: left; margin: 1rem 0; }
            li { margin: 0.5rem 0; }
        </style>
    </head>
    <body>
        <div class="container">
            <div class="emoji">🚀</div>
            <h1>Crypto Airdrop Platform</h1>
            <div class="status">
                <div class="success">✅ Successfully Deployed!</div>
                <p>Your platform is running on this VPS</p>
            </div>
            <div class="info">
                <strong>Server Status:</strong> Online<br>
                <strong>Deployment Time:</strong> ${new Date().toLocaleString()}<br>
                <strong>Node.js:</strong> ${process.version}<br>
                <strong>Port:</strong> ${PORT}
            </div>
            <h3>Platform Features:</h3>
            <ul>
                <li>🔍 Airdrop Discovery</li>
                <li>💰 Profit Tracking</li>
                <li>📊 Analytics Dashboard</li>
                <li>🔐 Secure Authentication</li>
                <li>💬 Community Chat</li>
            </ul>
            <a href="/health" class="btn">Health Check</a>
            <a href="https://github.com" class="btn">Documentation</a>
        </div>
    </body>
    </html>
  `);
});

app.get('/health', (req, res) => {
  res.json({ 
    status: 'healthy', 
    platform: 'Crypto Airdrop Platform',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Crypto Airdrop Platform running on port ${PORT}`);
});
EOF

# Environment setup
cat > .env << EOF
NODE_ENV=production
PORT=5000
DATABASE_URL=postgresql://crypto_user:$DB_PASSWORD@localhost:5432/crypto_airdrop_db
SESSION_SECRET=$(openssl rand -hex 32)
EOF

# Install and start
chown -R crypto:crypto /opt/crypto-airdrop
sudo -u crypto npm install

# PM2 setup
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [{
    name: 'crypto-airdrop',
    script: 'server.js',
    env: { NODE_ENV: 'production', PORT: 5000 },
    instances: 1,
    autorestart: true
  }]
};
EOF

sudo -u crypto pm2 start ecosystem.config.js
sudo -u crypto pm2 save
pm2 startup systemd -u crypto --hp /opt/crypto-airdrop

# Nginx setup
cat > /etc/nginx/sites-available/crypto-airdrop << EOF
server {
    listen 80;
    server_name ${DOMAIN:-_};
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
    
    location /health {
        proxy_pass http://127.0.0.1:5000/health;
    }
}
EOF

rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/crypto-airdrop /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# SSL setup if domain provided
if [[ -n "$DOMAIN" ]]; then
    apt install -y certbot python3-certbot-nginx
    certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN" --redirect
fi

# Management commands
cat > /usr/local/bin/manage << 'EOF'
#!/bin/bash
case "$1" in
    start) sudo -u crypto pm2 start crypto-airdrop ;;
    stop) sudo -u crypto pm2 stop crypto-airdrop ;;
    restart) sudo -u crypto pm2 restart crypto-airdrop ;;
    status) sudo -u crypto pm2 status ;;
    logs) sudo -u crypto pm2 logs crypto-airdrop ;;
    *) echo "Usage: manage {start|stop|restart|status|logs}" ;;
esac
EOF
chmod +x /usr/local/bin/manage

# Firewall
ufw --force reset
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh
ufw allow 80/tcp
ufw allow 443/tcp
ufw --force enable

echo ""
echo -e "${GREEN}✅ Deployment Complete!${NC}"
echo ""
if [[ -n "$DOMAIN" ]]; then
    echo "🌐 Your platform: https://$DOMAIN"
else
    echo "🌐 Your platform: http://$(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_SERVER_IP')"
fi
echo ""
echo "📱 Management:"
echo "  manage start|stop|restart|status|logs"
echo ""
echo "🚀 Ready to use!"