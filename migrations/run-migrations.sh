#!/bin/bash

# Migration Runner Script for Master Catalog Cloning System
# Usage: ./run-migrations.sh [up|down] [database_url]

set -e

COMMAND=${1:-up}
DATABASE_URL=${2:-$DATABASE_URL}

if [ -z "$DATABASE_URL" ]; then
  echo "Error: DATABASE_URL not provided"
  echo "Usage: ./run-migrations.sh [up|down] [database_url]"
  echo "Or set DATABASE_URL environment variable"
  exit 1
fi

MIGRATIONS_DIR="$(dirname "$0")"

run_migration_up() {
  echo "Running migrations UP..."
  
  echo "→ Running 001_create_master_products_table.sql"
  psql "$DATABASE_URL" -f "$MIGRATIONS_DIR/001_create_master_products_table.sql"
  
  echo "→ Running 002_create_vendor_products_table.sql"
  psql "$DATABASE_URL" -f "$MIGRATIONS_DIR/002_create_vendor_products_table.sql"
  
  echo "→ Running 003_create_updated_at_triggers.sql"
  psql "$DATABASE_URL" -f "$MIGRATIONS_DIR/003_create_updated_at_triggers.sql"
  
  echo "✓ All migrations completed successfully"
}

run_migration_down() {
  echo "Running migrations DOWN..."
  
  echo "→ Running 003_create_updated_at_triggers.down.sql"
  psql "$DATABASE_URL" -f "$MIGRATIONS_DIR/003_create_updated_at_triggers.down.sql"
  
  echo "→ Running 002_create_vendor_products_table.down.sql"
  psql "$DATABASE_URL" -f "$MIGRATIONS_DIR/002_create_vendor_products_table.down.sql"
  
  echo "→ Running 001_create_master_products_table.down.sql"
  psql "$DATABASE_URL" -f "$MIGRATIONS_DIR/001_create_master_products_table.down.sql"
  
  echo "✓ All rollbacks completed successfully"
}

case "$COMMAND" in
  up)
    run_migration_up
    ;;
  down)
    run_migration_down
    ;;
  *)
    echo "Error: Invalid command '$COMMAND'"
    echo "Usage: ./run-migrations.sh [up|down] [database_url]"
    exit 1
    ;;
esac
