-- Migration: Create email_verification_tokens table
-- Description: Creates the email_verification_tokens table for email verification during user registration
-- Requirements: 1.2

-- Create email_verification_tokens table
CREATE TABLE IF NOT EXISTS email_verification_tokens (
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
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_user_id ON email_verification_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_email_verification_tokens_token_hash ON email_verification_tokens(token_hash);

-- Add comments to table
COMMENT ON TABLE email_verification_tokens IS 'Email verification tokens for user registration email verification';
COMMENT ON COLUMN email_verification_tokens.id IS 'Unique identifier for the email verification token';
COMMENT ON COLUMN email_verification_tokens.user_id IS 'Foreign key to users table';
COMMENT ON COLUMN email_verification_tokens.token_hash IS 'Hashed email verification token value (unique)';
COMMENT ON COLUMN email_verification_tokens.expires_at IS 'Timestamp when the token expires';
COMMENT ON COLUMN email_verification_tokens.used IS 'Flag indicating if token has been used';
COMMENT ON COLUMN email_verification_tokens.created_at IS 'Timestamp when the token was created';
COMMENT ON CONSTRAINT valid_expiration ON email_verification_tokens IS 'Ensures expiration time is after creation time';
