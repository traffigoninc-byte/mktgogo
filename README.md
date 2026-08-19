# mktgogo

A multi-tenant SaaS marketplace platform. The backend runs as Netlify serverless functions (Express + PostgreSQL). The frontend is a React 18 + TypeScript SPA served as a static Netlify site. Three user roles are supported: `PLATFORM_ADMIN`, `VENDOR`, and `CUSTOMER`.

## Tech Stack

| Layer | Technology |
|---|---|
| Backend runtime | Node.js 18+ with TypeScript |
| Backend framework | Express via `serverless-http` (Netlify Functions) |
| Database | PostgreSQL 14+ (Neon / Supabase / Railway recommended) |
| Auth | JWT access + refresh tokens, Argon2 password hashing |
| Payments | Stripe & Paystack |
| Frontend | React 18, Vite, TypeScript, Tailwind CSS |
| State management | Zustand (auth), TanStack Query v5 (server state) |
| Forms | React Hook Form + Zod |
| Charts | Recharts |
| Testing | Vitest + fast-check (property-based testing), Testing Library |

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Project Structure](#project-structure)
3. [Local Development — Backend](#local-development--backend)
4. [Local Development — Frontend](#local-development--frontend)
5. [Running Both Together with Netlify Dev](#running-both-together-with-netlify-dev)
6. [Environment Variables Reference](#environment-variables-reference)
7. [Database Migrations](#database-migrations)
8. [Testing](#testing)
9. [Deploying to Netlify](#deploying-to-netlify)
10. [API Overview](#api-overview)
11. [Security Notes](#security-notes)

---

## Prerequisites

Before you start, make sure you have the following installed:

| Tool | Version | Notes |
|---|---|---|
| Node.js | >= 18 | [nodejs.org](https://nodejs.org) |
| npm | >= 9 | Bundled with Node.js |
| PostgreSQL | >= 14 | Only needed for local DB; skip if using a hosted provider |
| Netlify CLI | latest | `npm install -g netlify-cli` |

You also need accounts at:
- [Netlify](https://app.netlify.com/signup) — for deployment
- A PostgreSQL provider (pick one):
  - [Neon](https://neon.tech) — serverless Postgres, free tier, recommended
  - [Supabase](https://supabase.com) — free tier
  - [Railway](https://railway.app) — free tier

---

## Project Structure

```
mktgogo/
├── frontend/                  # React SPA (Vite)
│   ├── src/
│   │   ├── api/               # Axios client + endpoint modules
│   │   ├── components/        # Shared UI components and forms
│   │   ├── hooks/             # Custom React hooks
│   │   ├── pages/             # Route-level page components
│   │   │   ├── admin/         # Platform admin pages
│   │   │   ├── auth/          # Login, register, password reset
│   │   │   ├── customer/      # Customer placeholder
│   │   │   └── vendor/        # Vendor dashboard + onboarding
│   │   ├── routes/            # Route guard components
│   │   ├── stores/            # Zustand auth store
│   │   ├── types/             # TypeScript interfaces + Zod schemas
│   │   └── utils/             # CSV export, date formatting, role utils
│   ├── .env.example
│   ├── package.json
│   ├── vite.config.ts
│   └── tailwind.config.ts
├── src/                       # Backend source
│   ├── adapters/              # Stripe & Paystack gateway adapters
│   ├── config/                # Environment config loader
│   ├── controllers/           # Express route handlers
│   ├── errors/                # Custom error classes
│   ├── middleware/            # Auth, rate limiting, error handling
│   ├── repositories/          # Database access layer (pg)
│   ├── routes/                # Express router definitions
│   ├── services/              # Business logic
│   ├── types/                 # TypeScript interfaces
│   ├── utils/                 # Shared utilities
│   ├── app.ts                 # Express app factory
│   └── index.ts               # Local server entry point
├── netlify/
│   └── functions/
│       └── api.ts             # Serverless function entry (wraps Express)
├── migrations/                # SQL migration files (.sql + .down.sql)
├── public/                    # Static publish directory (Netlify requirement)
├── .env.example               # Backend environment variable template
├── netlify.toml               # Netlify build + redirect config
├── package.json               # Backend dependencies
└── tsconfig.json
```

---

## Local Development — Backend

### 1. Clone the repository

```bash
git clone <repo-url>
cd mktgogo
```

### 2. Install backend dependencies

```bash
npm install
```

### 3. Create and configure the environment file

```bash
cp .env.example .env
```

Open `.env` and fill in the required values. The minimum required to start:

```env
# PostgreSQL — use a local or hosted connection string
DATABASE_URL=postgresql://postgres:password@localhost:5432/mktgogo

# JWT — generate a long random string (32+ chars)
JWT_SECRET=change-this-to-a-long-random-secret

# Encryption — 32-byte hex string (openssl rand -hex 32)
ENCRYPTION_MASTER_KEY=change-this-to-a-32-byte-hex-key

# Only required if you need payment flows
STRIPE_API_KEY=sk_test_...
PAYSTACK_API_KEY=sk_test_...
```

See [Environment Variables Reference](#environment-variables-reference) for the full list.

### 4. Set up the database

**Option A — hosted provider (recommended)**

Create a free database on [Neon](https://neon.tech), [Supabase](https://supabase.com), or [Railway](https://railway.app), copy the connection string into `DATABASE_URL`, then run migrations:

```bash
node migrations/run-migrations.js
```

**Option B — local PostgreSQL**

```bash
# Create the local database
node migrations/create-database.js

# Run all migrations in order
node migrations/run-migrations.js
```

### 5. Build and start the backend server

```bash
npm run build
npm start
```

The server listens on `http://localhost:3000` by default. Health check:

```
GET http://localhost:3000/health
```

Alternatively, use `netlify dev` (see [Running Both Together](#running-both-together-with-netlify-dev)) to emulate the serverless environment locally.

---

## Local Development — Frontend

### 1. Install frontend dependencies

```bash
cd frontend
npm install
```

### 2. Create and configure the frontend environment file

```bash
cp .env.example .env
```

For local development pointing at `netlify dev` (default port 8888):

```env
VITE_API_BASE_URL=http://localhost:8888
```

For local development pointing at the Express server directly (port 3000):

```env
VITE_API_BASE_URL=http://localhost:3000
```

### 3. Start the frontend dev server

```bash
npm run dev
```

The Vite dev server starts at `http://localhost:5173` by default.

> **Note:** The frontend expects the backend to be running separately. The Vite dev server proxies no requests by default — `VITE_API_BASE_URL` must point to a running backend instance.

---

## Running Both Together with Netlify Dev

`netlify dev` is the recommended local setup. It starts both the backend function and serves the frontend through a single port (8888), matching the production environment exactly.

### 1. Make sure the Netlify CLI is installed and you are linked to a site

```bash
npm install -g netlify-cli
netlify login
netlify link    # or: netlify init (for a new site)
```

### 2. Set the frontend API URL to the Netlify Dev port

In `frontend/.env`:

```env
VITE_API_BASE_URL=http://localhost:8888
```

### 3. Start Netlify Dev from the project root

```bash
netlify dev
```

This starts:
- The backend Netlify Function at `http://localhost:8888/.netlify/functions/api`
- The frontend Vite dev server proxied through `http://localhost:8888`

Everything is accessible at `http://localhost:8888`. The health check is at:

```
GET http://localhost:8888/health
```

---

## Environment Variables Reference

### Backend (root `.env`)

| Variable | Required | Default | Description |
|---|---|---|---|
| `DATABASE_URL` | ✅ | — | Full PostgreSQL connection string |
| `DB_HOST` | — | `localhost` | DB host (used if `DATABASE_URL` is not set) |
| `DB_PORT` | — | `5432` | DB port |
| `DB_NAME` | — | `mktgogo` | Database name |
| `DB_USER` | — | `user` | Database user |
| `DB_PASSWORD` | — | — | Database password |
| `DB_POOL_MIN` | — | `2` | Minimum pool connections |
| `DB_POOL_MAX` | — | `10` | Maximum pool connections |
| `JWT_SECRET` | ✅ | — | JWT signing secret (32+ chars) |
| `JWT_EXPIRATION` | — | `30m` | Access token lifetime |
| `JWT_ALGORITHM` | — | `HS256` | JWT signing algorithm |
| `REFRESH_TOKEN_EXPIRATION_DAYS` | — | `30` | Refresh token lifetime in days |
| `EMAIL_VERIFICATION_TOKEN_EXPIRATION_HOURS` | — | `24` | Email verification token lifetime |
| `PASSWORD_RESET_TOKEN_EXPIRATION_HOURS` | — | `1` | Password reset token lifetime |
| `SMTP_HOST` | — | — | SMTP server hostname |
| `SMTP_PORT` | — | `587` | SMTP port |
| `SMTP_SECURE` | — | `false` | Use TLS |
| `SMTP_USER` | — | — | SMTP username |
| `SMTP_PASSWORD` | — | — | SMTP password |
| `EMAIL_FROM` | — | — | From address for system emails |
| `PORT` | — | `3000` | Local Express server port |
| `NODE_ENV` | — | `development` | `development` or `production` |
| `HTTPS_ONLY` | — | `true` | Reject non-HTTPS requests in production |
| `CORS_ORIGIN` | ✅ | — | Allowed CORS origin (your frontend URL) |
| `ENCRYPTION_MASTER_KEY` | ✅ | — | 32-byte hex key for credential encryption |
| `STRIPE_API_KEY` | — | — | Stripe secret key (`sk_test_...` or `sk_live_...`) |
| `STRIPE_WEBHOOK_SECRET` | — | — | Stripe webhook signing secret (`whsec_...`) |
| `PAYSTACK_API_KEY` | — | — | Paystack secret key |
| `PAYSTACK_WEBHOOK_SECRET` | — | — | Paystack webhook secret |
| `PLATFORM_DOMAIN` | — | — | Your platform domain (e.g. `myapp.com`) |
| `RATE_LIMIT_LOGIN_MAX` | — | `5` | Max login attempts per window |
| `RATE_LIMIT_LOGIN_WINDOW_MS` | — | `900000` | Login rate limit window (ms) |
| `RATE_LIMIT_PAYMENT_INITIATION_MAX` | — | `10` | Max payment initiations per window |
| `LOG_LEVEL` | — | `info` | Logging verbosity |

### Frontend (`frontend/.env`)

| Variable | Required | Description |
|---|---|---|
| `VITE_API_BASE_URL` | ✅ | Backend base URL (e.g. `http://localhost:8888` or `https://your-site.netlify.app`) |

> Vite only exposes variables prefixed with `VITE_` to the browser bundle.

---

## Database Migrations

All migrations live in the `migrations/` directory. Files are numbered sequentially (`001_`, `002_`, ...) and each has a corresponding `.down.sql` rollback file.

### Run all migrations

```bash
node migrations/run-migrations.js
```

### Run a single migration

```bash
node migrations/run-single-migration.js migrations/001_create_master_products_table.sql
```

### Roll back all migrations

Roll back in reverse order using the `.down.sql` files:

```bash
psql "$DATABASE_URL" -f migrations/026_create_payment_audit_logs_table.down.sql
# ... continue in reverse order down to 001
```

### Using psql directly

```bash
# Run a specific migration
psql "$DATABASE_URL" -f migrations/001_create_master_products_table.sql

# Verify schema
psql "$DATABASE_URL" -f migrations/verify-schema.sql
```

### Migration overview

| Range | Module |
|---|---|
| 001–004 | Master products + vendor products catalog tables |
| 005–013 | Payment, wallet, payout, commission, webhook tables |
| 014–020 | Users, tenants, auth tokens, audit logs |
| 022–025 | Vendor store engine (templates, store configs, onboarding) |
| 026 | Payment audit logs |

---

## Testing

### Backend tests

```bash
# Run all backend tests once (unit + integration + property-based)
npm test

# Watch mode
npm run test:watch
```

### Frontend tests

```bash
cd frontend

# Run all frontend tests once
npm test

# Watch mode
npm run test:watch
```

The frontend test suite uses Vitest + Testing Library for component/hook tests and fast-check for property-based tests where implemented.

### Test types

| Type | Location | Tool |
|---|---|---|
| Unit | `src/**/*.test.ts` | Vitest |
| Integration | `src/**/*.integration.test.ts` | Vitest + Supertest |
| Property-based | `src/**/*.property.test.ts` | Vitest + fast-check |
| E2E (backend) | `src/**/*.e2e.test.ts` | Vitest + Supertest |
| Component | `frontend/src/**/*.test.tsx` | Vitest + Testing Library |

---

## Deploying to Netlify

### 1. Push the repository to GitHub / GitLab / Bitbucket

```bash
git add .
git commit -m "initial commit"
git push origin main
```

### 2. Create a new Netlify site

**Option A — via the Netlify dashboard (recommended):**

1. Go to [app.netlify.com](https://app.netlify.com) → **Add new site** → **Import an existing project**
2. Connect your Git provider and select the repository
3. Netlify auto-detects `netlify.toml` — build settings are pre-configured. No changes needed.
4. Click **Deploy site**

**Option B — via the Netlify CLI:**

```bash
npm install -g netlify-cli
netlify login
netlify init       # link to a new or existing site
netlify deploy     # deploy a preview build
netlify deploy --prod   # deploy to production
```

### 3. Set environment variables on Netlify

Go to **Site configuration → Environment variables** and add the following. At minimum:

| Variable | Value |
|---|---|
| `DATABASE_URL` | Your PostgreSQL connection string |
| `JWT_SECRET` | A long random secret (32+ chars) |
| `ENCRYPTION_MASTER_KEY` | A 32-byte hex string |
| `CORS_ORIGIN` | Your Netlify site URL (e.g. `https://your-site.netlify.app`) |
| `NODE_ENV` | `production` |
| `HTTPS_ONLY` | `true` |
| `VITE_API_BASE_URL` | Your Netlify site URL (e.g. `https://your-site.netlify.app`) |

Add payment variables if you are enabling payment flows:

| Variable | Value |
|---|---|
| `STRIPE_API_KEY` | `sk_live_...` |
| `STRIPE_WEBHOOK_SECRET` | `whsec_...` |
| `PAYSTACK_API_KEY` | Your Paystack secret key |
| `PAYSTACK_WEBHOOK_SECRET` | Your Paystack webhook secret |

### 4. Run database migrations against the production database

```bash
DATABASE_URL=postgresql://<user>:<password>@<host>/<dbname> node migrations/run-migrations.js
```

Or run this locally before deploying, pointing `DATABASE_URL` at your hosted Postgres instance.

### 5. Register webhook endpoints with payment providers

After the site is live, register these URLs in your Stripe and Paystack dashboards:

| Provider | Webhook URL |
|---|---|
| Stripe | `https://your-site.netlify.app/api/webhooks/stripe` |
| Paystack | `https://your-site.netlify.app/api/webhooks/paystack` |

### 6. Verify the deployment

```bash
# Health check
curl https://your-site.netlify.app/health

# Expected response
{"status":"ok"}
```

---

## API Overview

All API endpoints are available at `/api/*` (redirected from `/.netlify/functions/api/*` internally via `netlify.toml`).

### Auth

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/auth/register` | — | Register a new user |
| POST | `/auth/login` | — | Login and receive tokens |
| POST | `/auth/refresh` | — | Exchange refresh token for new access token |
| POST | `/auth/logout` | Bearer | Logout current session |
| POST | `/auth/logout-all` | Bearer | Logout all sessions |
| POST | `/auth/verify-email` | — | Verify email with token |
| POST | `/auth/password-reset` | — | Request or confirm password reset |

### Vendor Onboarding

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/vendor/onboarding/templates` | VENDOR | List available store templates |
| POST | `/api/vendor/onboarding/template` | VENDOR | Select a template |
| POST | `/api/vendor/onboarding/subdomain` | VENDOR | Configure subdomain |
| POST | `/api/vendor/onboarding/branding` | VENDOR | Upload branding assets |
| POST | `/api/vendor/onboarding/complete` | VENDOR | Complete onboarding |

### Vendor Dashboard

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/vendor/store` | VENDOR | Get store configuration |
| PUT | `/api/vendor/store/branding` | VENDOR | Update branding |
| PUT | `/api/vendor/store/custom-domain` | VENDOR | Update custom domain |
| GET | `/api/vendor/catalog/products` | VENDOR | Browse master catalog |
| POST | `/api/vendor/products/clone` | VENDOR | Clone a product to store |
| GET | `/api/vendor/products` | VENDOR | List cloned products |
| PUT | `/api/vendor/products/:id/markup-price` | VENDOR | Set markup price |
| DELETE | `/api/vendor/products/:id` | VENDOR | Remove product from store |

### Payments & Wallet

| Method | Path | Auth | Description |
|---|---|---|---|
| POST | `/api/payments` | Bearer | Initiate a payment |
| GET | `/api/payments/:id` | Bearer | Get payment details |
| POST | `/api/refunds` | Bearer | Process a refund |
| GET | `/api/wallets` | VENDOR | Get wallet balance and transactions |
| POST | `/api/payouts` | VENDOR | Request a payout |
| GET | `/api/payouts` | VENDOR | List payout history |
| POST | `/api/webhooks/stripe` | — | Stripe webhook handler |
| POST | `/api/webhooks/paystack` | — | Paystack webhook handler |

### Admin

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/admin/templates` | ADMIN | List all store templates |
| POST | `/api/admin/templates` | ADMIN | Create a template |
| PUT | `/api/admin/templates/:id` | ADMIN | Update a template |
| DELETE | `/api/admin/templates/:id` | ADMIN | Delete a template |
| GET | `/api/admin/stores` | ADMIN | List all vendor stores |
| PUT | `/api/admin/stores/:id/status` | ADMIN | Change store status |
| GET | `/api/admin/catalog/products` | ADMIN | List master catalog products |
| POST | `/api/admin/catalog/products` | ADMIN | Create a master product |
| PUT | `/api/admin/catalog/products/:id` | ADMIN | Update a master product |
| DELETE | `/api/admin/catalog/products/:id` | ADMIN | Delete a master product |
| POST | `/api/admin/catalog/import` | ADMIN | Bulk import products |

### Reports

| Method | Path | Auth | Description |
|---|---|---|---|
| GET | `/api/reports/platform/revenue` | ADMIN | Platform revenue report |
| GET | `/api/reports/commissions` | ADMIN | Commission report |
| GET | `/api/reports/payouts` | ADMIN | Payout report |

---

## Security Notes

- All protected endpoints require `Authorization: Bearer <access_token>`
- Passwords are hashed with Argon2 (memory-hard, resistant to brute force)
- Refresh tokens are hashed before database storage
- Payment provider credentials are encrypted at rest using AES-256
- Rate limiting is applied to auth, payment, and payout endpoints
- HTTPS is enforced in production via the `HTTPS_ONLY` environment variable
- CORS is restricted to `CORS_ORIGIN`
- All JWT tokens carry a short expiry (default 30 minutes); silent refresh handles renewal

---

## License

MIT


---

## Deploying to a VPS (Ubuntu / Debian)

This section covers a full production deployment on any Linux VPS — DigitalOcean, Linode, Hetzner, AWS EC2, etc. The stack is:

- **nginx** — reverse proxy + TLS termination + static frontend serving
- **PM2** — process manager that keeps the Node.js backend running and restarts it on crash/reboot
- **PostgreSQL** — either installed locally on the server or a hosted provider
- **Certbot** — free TLS certificates via Let's Encrypt

### Prerequisites

- A VPS running Ubuntu 22.04 (or 20.04 / Debian 11+)
- A domain name with an A record pointing to your server's IP
- SSH access to the server as a non-root user with `sudo` privileges

---

### 1. Server setup

SSH into your server and update the system:

```bash
sudo apt update && sudo apt upgrade -y
```

#### Install Node.js 18

```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs
node --version   # should print v18.x.x
```

#### Install PM2 globally

```bash
sudo npm install -g pm2
```

#### Install nginx

```bash
sudo apt install -y nginx
sudo systemctl enable nginx
sudo systemctl start nginx
```

#### Install PostgreSQL (skip if using a hosted database)

```bash
sudo apt install -y postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
```

Create a database and user:

```bash
sudo -u postgres psql <<EOF
CREATE USER mktgogo WITH PASSWORD 'a-strong-password-here';
CREATE DATABASE mktgogo OWNER mktgogo;
GRANT ALL PRIVILEGES ON DATABASE mktgogo TO mktgogo;
EOF
```

Your local `DATABASE_URL` will be:
```
postgresql://mktgogo:a-strong-password-here@localhost:5432/mktgogo
```

---

### 2. Deploy the application

#### Clone the repository

```bash
cd /var/www
sudo git clone <repo-url> mktgogo
sudo chown -R $USER:$USER /var/www/mktgogo
cd /var/www/mktgogo
```

#### Install backend dependencies

```bash
npm ci --omit=dev
```

#### Install and build the frontend

```bash
cd frontend
npm ci
npm run build       # outputs to frontend/dist/
cd ..
```

#### Build the backend

```bash
npm run build       # compiles TypeScript to dist/
```

---

### 3. Configure environment variables

```bash
cp .env.example .env
nano .env
```

Fill in all required values. Key ones for VPS:

```env
DATABASE_URL=postgresql://mktgogo:a-strong-password-here@localhost:5432/mktgogo
JWT_SECRET=<generate with: node -e "console.log(require('crypto').randomBytes(48).toString('hex'))">
ENCRYPTION_MASTER_KEY=<generate with: node -e "console.log(require('crypto').randomBytes(32).toString('hex'))">
NODE_ENV=production
HTTPS_ONLY=true
CORS_ORIGIN=https://yourdomain.com
PORT=3000
STRIPE_API_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...
PAYSTACK_API_KEY=<your paystack key>
PAYSTACK_WEBHOOK_SECRET=<your paystack webhook secret>
```

Restrict the file so only your user can read it:

```bash
chmod 600 .env
```

---

### 4. Run database migrations

```bash
node migrations/run-migrations.js
```

---

### 5. Start the backend with PM2

```bash
pm2 start dist/index.js --name mktgogo-api --env production

# Save the PM2 process list so it restarts after a server reboot
pm2 save

# Set PM2 to start on boot
pm2 startup
# Copy and run the command that PM2 prints
```

Verify it is running:

```bash
pm2 status
pm2 logs mktgogo-api --lines 50
```

The backend is now listening on `http://localhost:3000`.

---

### 6. Configure nginx

Create a new nginx site config:

```bash
sudo nano /etc/nginx/sites-available/mktgogo
```

Paste the following (replace `yourdomain.com` throughout):

```nginx
# Redirect HTTP → HTTPS
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name yourdomain.com www.yourdomain.com;

    # TLS — certificates will be placed here by Certbot in step 7
    ssl_certificate     /etc/letsencrypt/live/yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/yourdomain.com/privkey.pem;
    include             /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam         /etc/letsencrypt/ssl-dhparams.pem;

    # Security headers
    add_header X-Frame-Options           "SAMEORIGIN"  always;
    add_header X-Content-Type-Options    "nosniff"     always;
    add_header Referrer-Policy           "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;

    # API and auth routes → Node.js backend
    location ~ ^/(api|auth|health)/ {
        proxy_pass         http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header   Upgrade          $http_upgrade;
        proxy_set_header   Connection       'upgrade';
        proxy_set_header   Host             $host;
        proxy_set_header   X-Real-IP        $remote_addr;
        proxy_set_header   X-Forwarded-For  $proxy_add_x_forwarded_for;
        proxy_set_header   X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
        proxy_read_timeout 60s;

        # Required for multipart/form-data (logo uploads)
        client_max_body_size 10M;
    }

    # Frontend SPA — serve static files, fall back to index.html
    root /var/www/mktgogo/frontend/dist;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|svg|ico|woff2?)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

Enable the site and test the config:

```bash
sudo ln -s /etc/nginx/sites-available/mktgogo /etc/nginx/sites-enabled/
sudo nginx -t
```

---

### 7. Obtain a TLS certificate with Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx

# Issue a certificate (nginx plugin handles config automatically)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

Follow the prompts. Certbot will modify your nginx config with the certificate paths and set up automatic renewal.

Verify automatic renewal:

```bash
sudo certbot renew --dry-run
```

Reload nginx:

```bash
sudo systemctl reload nginx
```

---

### 8. Open firewall ports

If you have `ufw` enabled:

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'    # opens ports 80 and 443
sudo ufw enable
sudo ufw status
```

---

### 9. Verify the deployment

```bash
# Health check
curl https://yourdomain.com/health
# Expected: {"status":"ok"}

# Frontend
curl -I https://yourdomain.com
# Expected: HTTP/2 200
```

---

### 10. Register webhook endpoints

Update your payment provider dashboards to point to your domain:

| Provider | Webhook URL |
|---|---|
| Stripe | `https://yourdomain.com/api/webhooks/stripe` |
| Paystack | `https://yourdomain.com/api/webhooks/paystack` |

---

### Updating the application

To deploy new code:

```bash
cd /var/www/mktgogo

# Pull latest code
git pull origin main

# Rebuild backend
npm ci --omit=dev
npm run build

# Rebuild frontend
cd frontend && npm ci && npm run build && cd ..

# Run any new migrations
node migrations/run-migrations.js

# Reload the backend with zero downtime
pm2 reload mktgogo-api
```

---

### PM2 cheat sheet

```bash
pm2 status                    # show all processes
pm2 logs mktgogo-api          # stream logs
pm2 logs mktgogo-api --lines 200   # last 200 lines
pm2 restart mktgogo-api       # restart the process
pm2 reload mktgogo-api        # graceful reload (zero downtime)
pm2 stop mktgogo-api          # stop without removing
pm2 delete mktgogo-api        # remove from PM2
pm2 monit                     # live dashboard
```

---

### Troubleshooting

**502 Bad Gateway from nginx**
The backend is not running or is listening on a different port. Check:
```bash
pm2 status
pm2 logs mktgogo-api
curl http://localhost:3000/health
```

**Database connection refused**
Verify PostgreSQL is running and the `DATABASE_URL` in `.env` is correct:
```bash
sudo systemctl status postgresql
psql "$DATABASE_URL" -c "SELECT 1"
```

**Certbot fails — "could not connect to nginx"**
Make sure port 80 is open and nginx is running:
```bash
sudo ufw allow 80
sudo systemctl status nginx
```

**Frontend shows blank page or 404 on refresh**
The `try_files $uri $uri/ /index.html` line in nginx is what handles client-side routing. Confirm the nginx config matches what is in step 6 and reload nginx.

**Large file upload returns 413**
The `client_max_body_size 10M` directive in the nginx config covers the 5 MB logo limit with headroom. If you need more, increase it.
