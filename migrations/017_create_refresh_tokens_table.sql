-- Migration: Create refresh_tokens table
-- Description: Creates the refresh_tokens table for JWT refresh token rotation and management
-- Requirements: 2.3, 3.2

-- Create refresh_tokens table
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  is_revoked BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraint: expires_at must be after created_at
  CONSTRAINT valid_expiration CHECK (expires_at > created_at)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

-- Add comments to table
COMMENT ON TABLE refresh_tokens IS 'Refresh tokens for JWT token rotation and session management';
COMMENT ON COLUMN refresh_tokens.id IS 'Unique identifier for the refresh token';
COMMENT ON COLUMN refresh_tokens.user_id IS 'Foreign key to users table';
COMMENT ON COLUMN refresh_tokens.token_hash IS 'Hashed refresh token value (unique)';
COMMENT ON COLUMN refresh_tokens.expires_at IS 'Timestamp when the token expires';
COMMENT ON COLUMN refresh_tokens.is_revoked IS 'Flag indicating if token has been revoked';
COMMENT ON COLUMN refresh_tokens.created_at IS 'Timestamp when the token was created';
COMMENT ON CONSTRAINT valid_expiration ON refresh_tokens IS 'Ensures expiration time is after creation time';
