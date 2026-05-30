-- Migration: Create onboarding_sessions table
-- Description: Creates the onboarding_sessions table to store temporary onboarding progress data
-- Requirements: 12.1

-- Create onboarding_sessions table
CREATE TABLE IF NOT EXISTS onboarding_sessions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  vendor_id UUID NOT NULL REFERENCES vendors(id) ON DELETE CASCADE,
  current_step VARCHAR(50) NOT NULL,
  session_data JSONB NOT NULL DEFAULT '{}',
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '24 hours'
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_onboarding_sessions_vendor_id ON onboarding_sessions(vendor_id);
CREATE INDEX IF NOT EXISTS idx_onboarding_sessions_expires_at ON onboarding_sessions(expires_at);

-- Add comments to table
COMMENT ON TABLE onboarding_sessions IS 'Temporary storage for vendor onboarding progress (expires after 24 hours)';
COMMENT ON COLUMN onboarding_sessions.id IS 'Unique identifier for the onboarding session';
COMMENT ON COLUMN onboarding_sessions.vendor_id IS 'Reference to the vendor being onboarded';
COMMENT ON COLUMN onboarding_sessions.current_step IS 'Current step in the onboarding flow';
COMMENT ON COLUMN onboarding_sessions.session_data IS 'JSON object containing onboarding progress data';
COMMENT ON COLUMN onboarding_sessions.created_at IS 'Timestamp when the session was created';
COMMENT ON COLUMN onboarding_sessions.expires_at IS 'Timestamp when the session expires (24 hours from creation)';
