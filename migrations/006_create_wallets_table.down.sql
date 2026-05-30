-- Rollback: Drop wallets table

DROP TRIGGER IF EXISTS update_wallets_updated_at ON wallets;
DROP INDEX IF EXISTS idx_wallets_currency;
DROP INDEX IF EXISTS idx_wallets_vendor;
DROP TABLE IF EXISTS wallets;
