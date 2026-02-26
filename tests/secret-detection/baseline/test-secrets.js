// JavaScript test file with embedded secrets
// For testing secret detection tools

// GitHub Tokens
const githubToken = "ghp_zZ9yY8xX7wW6vV5uU4tT3sS2rR1qQ0pP1234";
const githubOAuth = "gho_xXyYzZaAbBcCdDeEfFgGhHiIjJkKlLmMnNoO";
const githubApp = "ghu_zZ9yY8xX7wW6vV5uU4tT3sS2rR1qQ0pP1234";

// GitHub Fine-grained Token
const finegrained = "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0";

// AWS Credentials
const awsConfig = {
  accessKeyId: "ASIATESTACCESSKEYID",
  secretAccessKey: "wJalrXUtnFEMI/K7MDENG/bPxRfiCYzExampleKey",
  sessionToken: "FwoGZXIvYXdzEBQaDH5F5V4+JzExampleToken+veryLongSessionTokenHere"
};

// API Keys
const OPENAI_API_KEY = "sk-proj-xYzAbCdEfGhIjKlMnOpQrStUvWx1234567890ABCD";
const ANTHROPIC_API_KEY = "sk-ant-api03-zZ9yY8xX7wW6vV5uU4tT3sS2rR1qQ0pP1234567890zZ9yY8xX7wW6vV5uU4tT3sS2rR1qQ0pP1234567890zZ9yY8xX7wW6vV5uU4tT3sS2rR";
const STRIPE_KEY = "sk_test_51XyZaBcDeFgHiJkLmNoPqRsT1234567890";
const GOOGLE_API_KEY = "AIzaSyABCDEFGHIJKLMNOPQRSTUVWXYZ1234567";

// Slack Tokens
const slackConfig = {
  botToken: "FAKE_SLACK_BOT_TOKEN_FOR_TESTING_ONLY",
  userToken: "xoxp-9876543210987-9876543210987-9876543210987-zyxwvu9876543210zyxwvu9876543210"
};

// Twilio & SendGrid
const twilioKey = "SKzyxwvu9876543210zyxwvu9876543210";
const sendgridKey = "SG.zyxwvu9876543210.zyxwvutsrqponmlkjihgfedcba9876543210";

// Database URLs
const DATABASE_URL = "postgres://admin:P@ssw0rd123@db.example.com/production";
const MONGODB_URI = "mongodb+srv://user:secretPass123@cluster.mongodb.net/database";
const REDIS_URL = "redis://:superSecret@localhost:6379";

// JWT
const token = "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI5ODc2NTQzMjEwIiwibmFtZSI6IkphbmUgRG9lIiwiaWF0IjoxNjE2MjM5MDIyfQ.ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";

// Private Key
const privateKey = `-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABFwAAAAdzc2gtcn
NhAAAAAwEAAQAAAQEAzyxwvutsrqponmlkjihgfedcba9876543210ABCDEFGHIJKLMNOPQR
-----END OPENSSH PRIVATE KEY-----`;

// EC Private Key
const ecKey = `-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIAzyxwvutsrqponmlkjihgfedcba9876543210oAoGCCqGSM49AwEHoUQDQgAE
ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890abcdefghijklmnopqrstuvwxyz12345678
-----END EC PRIVATE KEY-----`;

// Webhook
const webhookUrl = "https://example.com/fake-slack-webhook-for-testingabcdefghijklmnopqrstuvwx";

module.exports = {
  githubToken,
  awsConfig,
  OPENAI_API_KEY
};
