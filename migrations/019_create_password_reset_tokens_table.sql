-- Migration: Create password_reset_tokens table
-- Description: Creates the password_reset_tokens table for password reset functionality
-- Requirements: 4.1

-- Create password_reset_tokens table
CREATE TABLE IF NOT EXISTS password_reset_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  expires_at TIMESTAMP NOT NULL,
  used BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  
  -- Constraint: expires_at must be after created_at
  CONSTRAINT valid_expiration CHECK (expires_at > created_at)
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_user_id ON password_reset_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_password_reset_tokens_token_hash ON password_reset_tokens(token_hash);

-- Add comments to table
COMMENT ON TABLE password_reset_tokens IS 'Password reset tokens for secure password reset functionality';
COMMENT ON COLUMN password_reset_tokens.id IS 'Unique identifier for the password reset token';
COMMENT ON COLUMN password_reset_tokens.user_id IS 'Foreign key to users table';
COMMENT ON COLUMN password_reset_tokens.token_hash IS 'Hashed password reset token value (unique)';
COMMENT ON COLUMN password_reset_tokens.expires_at IS 'Timestamp when the token expires (1 hour from creation)';
COMMENT ON COLUMN password_reset_tokens.used IS 'Flag indicating if token has been used';
COMMENT ON COLUMN password_reset_tokens.created_at IS 'Timestamp when the token was created';
COMMENT ON CONSTRAINT valid_expiration ON password_reset_tokens IS 'Ensures expiration time is after creation time';
