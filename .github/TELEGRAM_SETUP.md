# Telegram Deployment Notifications Setup

This guide explains how to set up Telegram notifications for deployment events.

## Overview

The deployment workflows now send Telegram notifications when:
- **Staging**: Functions and Firestore rules are deployed to staging
- **Production**: Functions, Firestore rules, or Extensions are deployed to production

## Bots

You have two Telegram bots configured:

1. **Staging Bot**: `@freshwall_state_bot`
2. **Production Bot**: `@freshwall_alert_tracker_bot`

> **Security Note**: Bot tokens should be kept secure and never committed to the repository. Get tokens from @BotFather in Telegram.

## Setup Instructions

### Step 1: Get Chat IDs

You need to get the chat ID where the bot will send messages. This can be a private chat, group, or channel.

#### Option A: Send message to bot directly (Private chat)

1. Open Telegram and search for your bot:
   - Staging: `@freshwall_state_bot`
   - Production: `@freshwall_alert_tracker_bot`

2. Click "Start" or send any message to the bot

3. Run this command to get the chat ID:

```bash
# For staging bot
curl "https://api.telegram.org/bot<YOUR_STAGING_BOT_TOKEN>/getUpdates"

# For production bot
curl "https://api.telegram.org/bot<YOUR_PRODUCTION_BOT_TOKEN>/getUpdates"
```

4. Look for the `"chat":{"id":XXXXXXX}` in the response. That number is your chat ID.

#### Option B: Add bot to a group/channel

1. Create a Telegram group or use an existing one
2. Add the bot to the group as an admin
3. Send a message in the group
4. Run the same curl command as above
5. Look for `"chat":{"id":-XXXXXXX}` (note: group IDs are negative)

### Step 2: Add GitHub Secrets

Go to your GitHub repository settings and add the following secrets:

**Settings → Secrets and variables → Actions → New repository secret**

Add these four secrets:

1. **TELEGRAM_BOT_TOKEN_STAGING**
   - Value: Get from @BotFather for `@freshwall_state_bot`

2. **TELEGRAM_CHAT_ID_STAGING**
   - Value: `[YOUR_CHAT_ID_FROM_STEP_1]`

3. **TELEGRAM_BOT_TOKEN_PRODUCTION**
   - Value: Get from @BotFather for `@freshwall_alert_tracker_bot`

4. **TELEGRAM_CHAT_ID_PRODUCTION**
   - Value: `[YOUR_CHAT_ID_FROM_STEP_1]`

### Step 3: Test

After setting up the secrets, trigger a deployment:

- **Test staging**: Push to the `staging` branch or manually trigger the workflow
- **Test production**: Push to the `main` branch

You should receive a message like:

```
🚀 Production Deployment Complete

Environment: Production
Branch: main
Deployed by: @hi2gage
Components: Functions, Firestore Rules

Commit: abc1234
Message: Add deployment notifications

🔗 View deployment
```

## Troubleshooting

### No message received

1. **Check secrets are set correctly**: Go to Settings → Secrets and verify all 4 secrets exist
2. **Verify chat ID**: Make sure you used the correct chat ID from the getUpdates response
3. **Check workflow logs**: Look at the GitHub Actions logs for any error messages
4. **Bot permissions**: If using a group, make sure the bot is an admin

### Message format issues

The messages use HTML formatting. If you see raw HTML tags, the bot's parse_mode might not be set correctly (this shouldn't happen with the current implementation).

## Security Notes

- Never commit bot tokens to the repository
- Bot tokens are stored securely in GitHub Secrets
- Only repository admins can view/edit secrets
- Tokens can be regenerated via @BotFather if compromised

## Notification Details

### Staging Notifications
- Sent on every push to `staging` branch that modifies Firebase files
- Sent on manual workflow triggers
- Includes: branch, deployer, components deployed, commit info, deployment link

### Production Notifications
- Sent only on successful deployments to `main` branch
- Intelligently shows which components were deployed (Functions, Firestore, Extensions)
- Includes: branch, deployer, components deployed, commit info, deployment link
