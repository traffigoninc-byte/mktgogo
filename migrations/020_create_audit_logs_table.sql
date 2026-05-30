-- Migration: Create audit_logs table
-- Description: Creates the audit_logs table for security monitoring and audit logging
-- Requirements: 7.1

-- Create audit_logs table
CREATE TABLE IF NOT EXISTS audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  event_type VARCHAR(50) NOT NULL,
  user_id UUID REFERENCES users(id),
  email VARCHAR(255),
  ip_address VARCHAR(45) NOT NULL,
  user_agent TEXT,
  success BOOLEAN NOT NULL,
  details JSONB,
  timestamp TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_audit_logs_event_type ON audit_logs(event_type);
CREATE INDEX IF NOT EXISTS idx_audit_logs_timestamp ON audit_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_audit_logs_ip_address ON audit_logs(ip_address);

-- Add comments to table
COMMENT ON TABLE audit_logs IS 'Audit logs for security monitoring and authentication event tracking';
COMMENT ON COLUMN audit_logs.id IS 'Unique identifier for the audit log entry';
COMMENT ON COLUMN audit_logs.event_type IS 'Type of event (LOGIN_ATTEMPT, TOKEN_REFRESH, PASSWORD_RESET_REQUEST, etc.)';
COMMENT ON COLUMN audit_logs.user_id IS 'Foreign key to users table (nullable for failed login attempts)';
COMMENT ON COLUMN audit_logs.email IS 'Email address associated with the event';
COMMENT ON COLUMN audit_logs.ip_address IS 'IP address of the client making the request';
COMMENT ON COLUMN audit_logs.user_agent IS 'User agent string from the client';
COMMENT ON COLUMN audit_logs.success IS 'Flag indicating if the operation was successful';
COMMENT ON COLUMN audit_logs.details IS 'Additional details about the event stored as JSONB';
COMMENT ON COLUMN audit_logs.timestamp IS 'Timestamp when the event occurred';
