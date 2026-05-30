# mktgogo

A multi-tenant SaaS platform backend providing a master product catalog, vendor store engine, payment & commission processing, and authentication with RBAC.

## Tech Stack

- **Runtime**: Node.js with TypeScript
- **Framework**: Express
- **Database**: PostgreSQL
- **Auth**: JWT (access + refresh tokens) with Argon2 password hashing
- **Payments**: Stripe & Paystack
- **Testing**: Vitest + fast-check (property-based testing)

---

## Prerequisites

- Node.js >= 18
- PostgreSQL >= 14
- npm

---

## Installation

```bash
# Clone the repo
git clone <repo-url>
cd mktgogo

# Install dependencies
npm install
```

---

## Environment Setup

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

Key variables to configure:

| Variable | Description |
|---|---|
| `DATABASE_URL` | Full PostgreSQL connection string |
| `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` | Individual DB connection params |
| `JWT_SECRET` | Secret key for signing JWTs — change in production |
| `STRIPE_API_KEY` | Stripe secret key |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signing secret |
| `PAYSTACK_API_KEY` | Paystack secret key |
| `PAYSTACK_WEBHOOK_SECRET` | Paystack webhook secret |
| `ENCRYPTION_MASTER_KEY` | Master key for credential encryption — change in production |
| `PORT` | Server port (default: `3000`) |
| `NODE_ENV` | `development` or `production` |

---

## Database Setup

### 1. Create the database

```bash
node migrations/create-database.js
```

### 2. Run all migrations

```bash
node migrations/run-migrations.js
```

Or run a single migration:

```bash
node migrations/run-single-migration.js migrations/001_create_master_products_table.sql
```

### Rollback a migration

Each migration has a corresponding `.down.sql` file:

```bash
psql -U $DB_USER -d $DB_NAME -f migrations/001_create_master_products_table.down.sql
```

---

## Running the Server

```bash
# Build TypeScript
npm run build

# Start production server
npm start

# Build and start (dev shortcut)
npm run dev
```

---

## Testing

```bash
# Run all tests once
npm test

# Run tests in watch mode
npm run test:watch
```

The test suite includes:
- Unit tests for services, repositories, and utilities
- Integration tests for API endpoints and auth flows
- Property-based tests (fast-check) validating correctness properties across randomized inputs

---

## Project Structure

```
src/
├── adapters/        # Payment gateway adapters (Stripe, Paystack)
├── config/          # Environment config
├── controllers/     # Route handlers
├── errors/          # Custom error classes
├── middleware/      # Auth, rate limiting, error handling
├── repositories/    # Database access layer
├── routes/          # Express route definitions
├── services/        # Business logic
├── types/           # TypeScript interfaces and types
├── utils/           # Shared utilities
├── app.ts           # Express app setup
└── index.ts         # Entry point

migrations/          # SQL migration files (up + down)
.kiro/specs/         # Feature specs (requirements, design, tasks)
```

---

## API Overview

### Auth
| Method | Path | Description |
|---|---|---|
| POST | `/api/auth/register` | Register a new user |
| POST | `/api/auth/login` | Login and receive tokens |
| POST | `/api/auth/refresh` | Refresh access token |
| POST | `/api/auth/logout` | Logout current session |
| POST | `/api/auth/logout-all` | Logout all sessions |
| POST | `/api/auth/verify-email` | Verify email address |
| POST | `/api/auth/password-reset` | Request password reset |

### Vendor Onboarding
| Method | Path | Description |
|---|---|---|
| POST | `/api/vendor/onboarding/start` | Start onboarding flow |
| GET | `/api/vendor/onboarding/templates` | List available store templates |
| POST | `/api/vendor/onboarding/template` | Select a template |
| POST | `/api/vendor/onboarding/subdomain` | Configure subdomain |
| POST | `/api/vendor/onboarding/branding` | Upload branding assets |
| POST | `/api/vendor/onboarding/complete` | Complete onboarding |

### Vendor Dashboard
| Method | Path | Description |
|---|---|---|
| GET | `/api/vendor/store` | Get store configuration |
| PUT | `/api/vendor/store/branding` | Update branding |
| PUT | `/api/vendor/store/custom-domain` | Update custom domain |

### Payments
| Method | Path | Description |
|---|---|---|
| POST | `/api/payments` | Initiate a payment |
| GET | `/api/payments/:id` | Get payment details |
| POST | `/api/refunds` | Process a refund |
| GET | `/api/wallet` | Get wallet balance |
| POST | `/api/payouts` | Request a payout |
| POST | `/api/webhooks/stripe` | Stripe webhook handler |
| POST | `/api/webhooks/paystack` | Paystack webhook handler |

### Admin
| Method | Path | Description |
|---|---|---|
| GET | `/api/admin/templates` | List all store templates |
| POST | `/api/admin/templates` | Create a template |
| PUT | `/api/admin/templates/:id` | Update a template |
| DELETE | `/api/admin/templates/:id` | Delete a template |
| GET | `/api/admin/stores` | List all vendor stores |
| PUT | `/api/admin/stores/:id/status` | Update store status |

---

## Security Notes

- All endpoints (except auth) require a valid JWT in the `Authorization: Bearer <token>` header
- Passwords are hashed with Argon2
- Refresh tokens are hashed before storage
- Payment credentials are encrypted at rest
- Rate limiting is applied to auth and payment endpoints
- HTTPS enforcement is enabled in production (`HTTPS_ONLY=true`)
- CORS is restricted to `CORS_ORIGIN`

---

## License

MIT
