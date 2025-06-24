# Crypto Airdrop Platform

A comprehensive cryptocurrency airdrop discovery and tracking platform.

## 🚀 One-Click VPS Deployment

Deploy to any Ubuntu/Debian VPS with one command:

```bash
# Basic deployment
curl -fsSL https://raw.githubusercontent.com/[your-repo]/main/deploy.sh | sudo bash

# With custom domain (includes SSL)
curl -fsSL https://raw.githubusercontent.com/[your-repo]/main/deploy.sh | sudo bash -s your-domain.com
```

## Requirements

- Ubuntu 20.04+ or Debian 11+
- 2GB RAM minimum
- Root access

## Management

After deployment, manage your platform:

```bash
manage start     # Start the platform
manage stop      # Stop the platform  
manage restart   # Restart the platform
manage status    # Check status
manage logs      # View logs
```

## Features

- 🔍 **Airdrop Discovery** - Find the latest crypto airdrops
- 💰 **Profit Tracking** - Track potential earnings
- 📊 **Analytics** - Detailed performance metrics
- 🔐 **Authentication** - Secure user accounts
- 💬 **Community** - Real-time chat and discussions
- 🌐 **Multi-platform** - Web3 wallet integration

## What Gets Installed

- Node.js 20 with npm
- PostgreSQL database
- Nginx web server
- PM2 process manager
- SSL certificates (with domain)
- UFW firewall

## Architecture

- **Frontend**: React 18 + TypeScript + Tailwind CSS
- **Backend**: Node.js + Express + PostgreSQL
- **Real-time**: WebSocket connections
- **Authentication**: Passport.js + Web3 (SIWE)
- **Database**: Drizzle ORM + PostgreSQL

## Development

To set up for development:

```bash
npm install
npm run dev
```

## Support

For issues or questions, check the platform logs:

```bash
manage logs
manage status
```

---

**Ready to launch your crypto airdrop platform? Run the deployment command above!**