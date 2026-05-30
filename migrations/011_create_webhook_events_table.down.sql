-- Rollback: Drop webhook_events table

DROP INDEX IF EXISTS idx_webhook_events_event_type;
DROP INDEX IF EXISTS idx_webhook_events_gateway;
DROP INDEX IF EXISTS idx_webhook_events_created;
DROP INDEX IF EXISTS idx_webhook_events_processed;
DROP INDEX IF EXISTS idx_webhook_events_event_id;
DROP TABLE IF EXISTS webhook_events;
