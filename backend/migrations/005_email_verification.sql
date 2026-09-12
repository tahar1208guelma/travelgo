ALTER TABLE users
ADD COLUMN is_email_verified BOOLEAN DEFAULT FALSE,
ADD COLUMN verification_otp VARCHAR(6),
ADD COLUMN verification_otp_expires_at TIMESTAMP;
