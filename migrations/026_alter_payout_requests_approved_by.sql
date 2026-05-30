-- Migration: Alter payout_requests.approved_by to support system approvals
-- Description: Change approved_by from UUID to VARCHAR to support 'system' value for auto-approvals

-- Drop the column and recreate it as VARCHAR
ALTER TABLE payout_requests 
  DROP COLUMN IF EXISTS approved_by;

ALTER TABLE payout_requests 
  ADD COLUMN approved_by VARCHAR(255);

-- Add comment explaining the column
COMMENT ON COLUMN payout_requests.approved_by IS 'User ID or "system" for auto-approved payouts';
