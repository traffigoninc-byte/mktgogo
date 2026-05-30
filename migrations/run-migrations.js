/**
 * Migration Runner Script for Master Catalog Cloning System
 * 
 * Usage:
 *   node run-migrations.js up
 *   node run-migrations.js down
 * 
 * Requires: pg (PostgreSQL client)
 * Install: npm install pg
 * 
 * Set DATABASE_URL environment variable or update the connection config below
 */

const fs = require('fs');
const path = require('path');
const { Client } = require('pg');

const MIGRATIONS_DIR = __dirname;

const migrations = [
  '001_create_master_products_table.sql',
  '002_create_vendor_products_table.sql',
  '003_create_updated_at_triggers.sql',
  '004_add_external_id_to_master_products.sql',
  '005_create_payments_table.sql',
  '006_create_wallets_table.sql',
  '007_create_wallet_transactions_table.sql',
  '008_create_payout_requests_table.sql',
  '009_create_commission_records_table.sql',
  '010_create_refunds_table.sql',
  '011_create_webhook_events_table.sql',
  '012_create_vendor_commission_rates_table.sql',
  '013_create_platform_settings_table.sql',
  '014_create_users_table.sql',
  '015_create_tenants_table.sql',
  '016_add_users_tenant_fk.sql',
  '017_create_refresh_tokens_table.sql',
  '018_create_email_verification_tokens_table.sql',
  '019_create_password_reset_tokens_table.sql',
  '020_create_audit_logs_table.sql',
  '021_create_vendors_table.sql',
  '022_create_store_templates_table.sql',
  '023_create_store_configurations_table.sql',
  '024_create_onboarding_sessions_table.sql',
  '025_create_vendor_store_updated_at_triggers.sql'
];

async function runMigrations(direction = 'up') {
  const client = new Client({
    connectionString: process.env.DATABASE_URL
  });

  try {
    await client.connect();
    console.log('Connected to database');

    const filesToRun = direction === 'up' 
      ? migrations 
      : migrations.reverse().map(m => m.replace('.sql', '.down.sql'));

    console.log(`Running migrations ${direction.toUpperCase()}...`);

    for (const file of filesToRun) {
      const filePath = path.join(MIGRATIONS_DIR, file);
      const sql = fs.readFileSync(filePath, 'utf8');
      
      console.log(`→ Running ${file}`);
      await client.query(sql);
      console.log(`✓ Completed ${file}`);
    }

    console.log(`✓ All migrations ${direction} completed successfully`);
  } catch (error) {
    console.error('Migration failed:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

// Parse command line arguments
const command = process.argv[2] || 'up';

if (!['up', 'down'].includes(command)) {
  console.error('Error: Invalid command. Use "up" or "down"');
  process.exit(1);
}

if (!process.env.DATABASE_URL) {
  console.error('Error: DATABASE_URL environment variable not set');
  process.exit(1);
}

runMigrations(command);
