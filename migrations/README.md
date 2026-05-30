# Database Migrations - Master Catalog Cloning System

This directory contains PostgreSQL migration files for the Master Product Catalog, Vendor Product Cloning System, and Payment & Commission Engine.

## Migration Files

### Forward Migrations (Up)

#### Catalog System (001-004)

1. **001_create_master_products_table.sql**
   - Creates the `master_products` table
   - Adds indexes for performance optimization
   - Implements constraints for data validation
   - Requirements: 11.1, 11.2, 11.3, 7.1, 7.4

2. **002_create_vendor_products_table.sql**
   - Creates the `vendor_products` table
   - Establishes foreign key relationship to `master_products`
   - Implements unique constraint to prevent duplicate clones
   - Adds indexes for performance optimization
   - Requirements: 11.1, 11.2, 11.3, 7.1, 7.4

3. **003_create_updated_at_triggers.sql**
   - Creates trigger function for automatic timestamp updates
   - Adds triggers to both tables for `updated_at` management
   - Requirements: 11.1, 11.2, 11.3

4. **004_add_external_id_to_master_products.sql**
   - Adds external_id column to master_products table

#### Payment & Commission Engine (005-013)

5. **005_create_payments_table.sql**
   - Creates the `payments` table for payment records
   - Stores gateway integration details and commission calculations
   - Implements idempotency key for duplicate prevention

6. **006_create_wallets_table.sql**
   - Creates the `wallets` table for vendor balances
   - Supports multi-currency wallet management
   - Tracks reserved balance for pending payouts

7. **007_create_wallet_transactions_table.sql**
   - Creates the `wallet_transactions` table for transaction history
   - Records all credits and debits with full audit trail
   - Implements idempotency for transaction safety

8. **008_create_payout_requests_table.sql**
   - Creates the `payout_requests` table for vendor payouts
   - Tracks payout lifecycle from request to completion
   - Stores bank account details as JSONB

9. **009_create_commission_records_table.sql**
   - Creates the `commission_records` table for commission tracking
   - Links to payments for full commission audit trail

10. **010_create_refunds_table.sql**
    - Creates the `refunds` table for refund processing
    - Tracks commission reversal and vendor debits

11. **011_create_webhook_events_table.sql**
    - Creates the `webhook_events` table for gateway webhooks
    - Implements event idempotency and retry tracking

12. **012_create_vendor_commission_rates_table.sql**
    - Creates the `vendor_commission_rates` table for custom rates
    - Allows per-vendor commission rate overrides

13. **013_create_platform_settings_table.sql**
    - Creates the `platform_settings` table for configuration
    - Stores default commission rate and payout thresholds

### Rollback Migrations (Down)

Each migration has a corresponding `.down.sql` file for rollback.

## Schema Overview

### master_products Table

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| name | VARCHAR(255) | NOT NULL | Product name |
| description | TEXT | NOT NULL | Product description |
| base_price | INTEGER | NOT NULL, >= 0 | Base price in cents |
| product_type | VARCHAR(20) | NOT NULL, IN ('PHYSICAL', 'DIGITAL', 'DROPSHIP') | Product type |
| stock_quantity | INTEGER | NOT NULL, >= 0 | Available stock |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |
| created_by | UUID | NOT NULL | Admin user ID |

**Indexes:**
- `idx_master_products_type` on `product_type`
- `idx_master_products_created_at` on `created_at DESC`
- `idx_master_products_created_by` on `created_by`

### vendor_products Table

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | UUID | PRIMARY KEY | Unique identifier |
| vendor_id | UUID | NOT NULL | Vendor user ID |
| master_product_id | UUID | NOT NULL, FK to master_products | Master product reference |
| markup_price | INTEGER | NOT NULL, >= 0 | Vendor price in cents |
| description_override | TEXT | NULL | Custom description |
| stock_sync_enabled | BOOLEAN | NOT NULL, DEFAULT TRUE | Stock sync flag |
| stock_quantity | INTEGER | NOT NULL, DEFAULT 0, >= 0 | Vendor-managed stock |
| created_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |
| updated_at | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Constraints:**
- `fk_master_product`: Foreign key to `master_products(id)` with ON DELETE RESTRICT
- `unique_vendor_master`: Unique constraint on `(vendor_id, master_product_id)`

**Indexes:**
- `idx_vendor_products_vendor` on `vendor_id`
- `idx_vendor_products_master` on `master_product_id`
- `idx_vendor_products_sync_enabled` on `stock_sync_enabled` (partial index where TRUE)

## Running Migrations

### Using psql

```bash
# Run all migrations in order
psql -U your_user -d your_database -f migrations/001_create_master_products_table.sql
psql -U your_user -d your_database -f migrations/002_create_vendor_products_table.sql
psql -U your_user -d your_database -f migrations/003_create_updated_at_triggers.sql
```

### Using a Migration Tool

If using a migration tool like `node-pg-migrate`, `knex`, or `sequelize`, configure it to read these SQL files in order.

### Rollback

```bash
# Rollback migrations in reverse order
psql -U your_user -d your_database -f migrations/003_create_updated_at_triggers.down.sql
psql -U your_user -d your_database -f migrations/002_create_vendor_products_table.down.sql
psql -U your_user -d your_database -f migrations/001_create_master_products_table.down.sql
```

## Key Features

### Referential Integrity
- Foreign key constraint ensures vendor products always reference valid master products
- ON DELETE RESTRICT prevents deletion of master products with active vendor clones

### Data Validation
- CHECK constraints ensure non-negative prices and stock quantities
- Product type enum validation at database level
- Unique constraint prevents duplicate product clones per vendor

### Performance Optimization
- Strategic indexes on frequently queried columns
- Partial index on stock_sync_enabled for efficient sync queries
- Descending index on created_at for recent product queries

### Automatic Timestamp Management
- Triggers automatically update `updated_at` on any row modification
- Ensures accurate audit trail without application-level logic

## Notes

- All prices are stored in cents (INTEGER) to avoid floating-point precision issues
- UUIDs are used for all primary keys for distributed system compatibility
- The `created_by` field in `master_products` should reference a `users` table (not created in these migrations)
- The `vendor_id` field in `vendor_products` should reference a `users` table (not created in these migrations)
