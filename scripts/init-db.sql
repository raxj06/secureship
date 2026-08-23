-- Creates second database for tracking-service
SELECT 'CREATE DATABASE secureship_tracking'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'secureship_tracking')\gexec
