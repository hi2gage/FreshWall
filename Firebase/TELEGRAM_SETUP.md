# Telegram Bot Setup Guide

This guide will help you set up Telegram notifications for FreshWall.

## Prerequisites

- A Telegram account
- Firebase CLI installed
- Access to Firebase project settings

## Step 1: Create a Telegram Bot

1. Open Telegram and search for `@BotFather`
2. Send `/newbot` command
3. Follow the prompts to name your bot (e.g., "FreshWall Notifications")
4. BotFather will provide you with a **bot token** (looks like `123456789:ABCdefGHIjklMNOpqrsTUVwxyz`)
5. **Save this token** - you'll need it later

## Step 2: Get Your Chat ID

1. Search for `@userinfobot` in Telegram
2. Start a chat with it
3. It will reply with your **Chat ID** (a number like `123456789`)
4. **Save this ID** - you'll need it later

Alternatively, if you want to send to a group:
1. Add your bot to the group
2. Send a message in the group
3. Visit `https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates`
4. Look for `"chat":{"id":-100123456789}` - this is your group chat ID

## Step 3: Configure Firebase Environment Variables

### For Local Development (Emulator)

Create a `.env` file in `Firebase/functions/`:

```bash
TELEGRAM_BOT_TOKEN="123456789:ABCdefGHIjklMNOpqrsTUVwxyz"
TELEGRAM_CHAT_ID="123456789"
```

### For Production (Firebase)

Set environment variables using Firebase CLI:

```bash
cd Firebase

# Set the bot token
firebase functions:secrets:set TELEGRAM_BOT_TOKEN

# Set the chat ID
firebase functions:secrets:set TELEGRAM_CHAT_ID
```

You'll be prompted to enter each value.

## Step 4: Deploy the Functions

```bash
cd Firebase

# Build TypeScript
npm run build

# Deploy to Firebase
firebase deploy --only functions
```

## Step 5: Test the Integration

### Local Testing (Emulator)

1. Start the Firebase emulator:
   ```bash
   cd Firebase
   npm run build
   firebase emulators:start
   ```

2. Create a test incident/client/user through your app
3. Check your Telegram for notifications

### Production Testing

1. After deployment, create a new incident/client/user in production
2. You should receive a Telegram notification within seconds

## Notifications

The following events trigger Telegram notifications:

- **New Incident**: When a new graffiti incident is reported
- **New Client**: When a new client is added to a team
- **New User**: When a new user joins a team

## Troubleshooting

### Not receiving notifications?

1. **Check bot token**: Make sure you copied the full token from BotFather
2. **Check chat ID**: Verify your chat ID is correct
3. **Start bot**: Send `/start` to your bot in Telegram (required for private chats)
4. **Check logs**: View function logs in Firebase Console
   ```bash
   firebase functions:log
   ```
5. **Verify deployment**: Check that functions deployed successfully
   ```bash
   firebase functions:list
   ```

### Error: "Forbidden: bot was blocked by the user"

- You need to start a conversation with your bot first
- Send `/start` to your bot in Telegram

### Error: "Bad Request: chat not found"

- Your chat ID is incorrect
- For group chats, make sure the bot is added to the group
- Try using `@userinfobot` to get your correct chat ID

## Customization

To modify notification messages, edit:
`Firebase/functions/src/notifications/telegramNotifications.ts`

You can:
- Change message formatting (HTML is supported)
- Add/remove notification triggers
- Customize which data is included in notifications
- Add emojis or formatting

## Disabling Notifications

To temporarily disable notifications without removing the code:

1. Remove the environment variables:
   ```bash
   firebase functions:secrets:delete TELEGRAM_BOT_TOKEN
   firebase functions:secrets:delete TELEGRAM_CHAT_ID
   ```

2. Or comment out the exports in `Firebase/functions/src/index.ts`

## Security Notes

- ⚠️ **Never commit bot tokens to git**
- Keep your `.env` file in `.gitignore`
- Use Firebase Secrets for production credentials
- Rotate your bot token periodically for security
