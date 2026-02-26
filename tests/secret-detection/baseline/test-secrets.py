#!/usr/bin/env python3
"""
Test file with embedded secrets for detection testing
This file contains intentional secrets for testing detection tools
"""

# GitHub Personal Access Tokens (classic)
github_token_1 = "ghp_1234567890abcdefghijklmnopqrstuvwxyz12"
github_token_2 = "ghp_aB3dE5fG7hI9jK1lM3nO5pQ7rS9tU1vW3xY5zA"
github_token_3 = "ghp_xYzAbCdEfGhIjKlMnOpQrStUvWx123456789"

# GitHub OAuth Tokens
oauth_token_1 = "gho_abcdefghijklmnopqrstuvwxyz123456789012"
oauth_token_2 = "gho_1234567890ABCDEFGHIJKLMNOPQRSTUVWXyz"

# GitHub App Tokens
app_token_1 = "ghu_1234567890abcdefghijklmnopqrstuvwxyzAB"
app_token_2 = "ghu_aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890"

# Fine-grained Personal Access Tokens
fine_token = "github_pat_11ABCDEFG0123456789_abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# AWS Credentials
AWS_ACCESS_KEY_ID = "AKIAIOSFODNN7EXAMPLE"
AWS_SECRET_ACCESS_KEY = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"

# OpenAI API Keys
openai_key_1 = "sk-1234567890abcdefghijklmnopqrstuvwxyz1234567890AB"
openai_key_2 = "sk-proj-abcdefghijklmnopqrstuvwxyz1234567890ABCDEFGHIJKLMN"

# Anthropic API Key
anthropic_key = "sk-ant-api03-1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrst"

# Stripe API Keys
stripe_test_key = "sk_test_4eC39HqLyjWDarjtT1zdp7dc"
stripe_live_key = "sk_live_51AbCdEfGhIjKlMnOpQrStUvWxYz1234567890"

# Slack Tokens
slack_bot_token = "xoxb-1234567890123-1234567890123-abcdefghijklmnopqrstuvwx"
slack_user_token = "xoxp-1234567890123-1234567890123-1234567890123-abcdef1234567890abcdef1234567890"

# Twilio
twilio_key = "SK1234567890abcdef1234567890abcdef"

# SendGrid
sendgrid_key = "SG.1234567890abcdefghij.1234567890abcdefghijklmnopqrstuvwxyz123456"

# Mailgun
mailgun_key = "key-1234567890abcdef1234567890abcdef"

# Google API Key
google_api_key = "AIzaSy1234567890abcdefghijklmnopqrstuvwxy"

# JWT Token
jwt_token = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c"

# Generic API Keys
api_key = "api_key_1234567890abcdefghijklmnopqrstuvwxyz"
config = {"apikey": "abcdef1234567890"}

# Database Connection Strings
db_url_postgres = "postgresql://user:password@localhost:5432/database"
db_url_mysql = "mysql://root:secret123@localhost:3306/mydb"
db_url_mongo = "mongodb://admin:password123@cluster0.mongodb.net/test?retryWrites=true"
redis_url = "redis://:password123@localhost:6379"

# Private Keys
rsa_private_key = """-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA1234567890abcdefghijklmnopqrstuvwxyz
ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklm
-----END RSA PRIVATE KEY-----"""

# Password in URL
api_url = "https://user:password123@api.example.com/v1/data"
ftp_url = "ftp://admin:P@ssw0rd@ftp.example.com/files"

# Slack Webhook
slack_webhook = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"

# High-entropy strings
random_secret = "randomSecretString_aB3dE5fG7hI9jK1lM3nO5pQ7rS9tU1vW3xY5zA"
long_random = "verylongrandomstring1234567890ABCDEFGHIJKLMNOPQRSTUVWXYZ"

def main():
    """This is a test file - do not execute"""
    pass

if __name__ == "__main__":
    main()
