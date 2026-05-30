-- Rollback: Drop platform_settings table

DROP TRIGGER IF EXISTS update_platform_settings_updated_at ON platform_settings;
DROP TABLE IF EXISTS platform_settings;
