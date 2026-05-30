-- Rollback: Drop wallet_transactions table

DROP INDEX IF EXISTS idx_wallet_transactions_category;
DROP INDEX IF EXISTS idx_wallet_transactions_type;
DROP INDEX IF EXISTS idx_wallet_transactions_idempotency;
DROP INDEX IF EXISTS idx_wallet_transactions_created;
DROP INDEX IF EXISTS idx_wallet_transactions_reference;
DROP INDEX IF EXISTS idx_wallet_transactions_wallet;
DROP TABLE IF EXISTS wallet_transactions;
