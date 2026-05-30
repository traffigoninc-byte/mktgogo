-- Schema Verification Script
-- Description: Validates that all tables, indexes, constraints, and triggers are properly created
-- Run this after migrations to verify the schema

\echo 'Verifying Master Catalog Cloning System Schema...'
\echo ''

-- Check master_products table exists
\echo 'Checking master_products table...'
SELECT 
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name = 'master_products';

-- Check master_products columns
\echo 'Checking master_products columns...'
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'master_products'
ORDER BY ordinal_position;

-- Check master_products constraints
\echo 'Checking master_products constraints...'
SELECT 
  constraint_name,
  constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public' 
  AND table_name = 'master_products';

-- Check master_products indexes
\echo 'Checking master_products indexes...'
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public' 
  AND tablename = 'master_products';

\echo ''
\echo 'Checking vendor_products table...'
SELECT 
  table_name,
  table_type
FROM information_schema.tables
WHERE table_schema = 'public' 
  AND table_name = 'vendor_products';

-- Check vendor_products columns
\echo 'Checking vendor_products columns...'
SELECT 
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'vendor_products'
ORDER BY ordinal_position;

-- Check vendor_products constraints
\echo 'Checking vendor_products constraints...'
SELECT 
  constraint_name,
  constraint_type
FROM information_schema.table_constraints
WHERE table_schema = 'public' 
  AND table_name = 'vendor_products';

-- Check vendor_products indexes
\echo 'Checking vendor_products indexes...'
SELECT 
  indexname,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public' 
  AND tablename = 'vendor_products';

-- Check foreign key relationships
\echo ''
\echo 'Checking foreign key relationships...'
SELECT
  tc.table_name,
  kcu.column_name,
  ccu.table_name AS foreign_table_name,
  ccu.column_name AS foreign_column_name,
  rc.delete_rule
FROM information_schema.table_constraints AS tc
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
  AND tc.table_schema = kcu.table_schema
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
  AND ccu.table_schema = tc.table_schema
JOIN information_schema.referential_constraints AS rc
  ON tc.constraint_name = rc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY'
  AND tc.table_schema = 'public'
  AND tc.table_name IN ('master_products', 'vendor_products');

-- Check triggers
\echo ''
\echo 'Checking triggers...'
SELECT 
  trigger_name,
  event_manipulation,
  event_object_table,
  action_timing,
  action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND event_object_table IN ('master_products', 'vendor_products')
ORDER BY event_object_table, trigger_name;

-- Check trigger function
\echo ''
\echo 'Checking trigger function...'
SELECT 
  routine_name,
  routine_type,
  data_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name = 'update_updated_at_column';

\echo ''
\echo '✓ Schema verification complete'
