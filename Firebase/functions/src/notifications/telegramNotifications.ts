import { onDocumentCreated } from "firebase-functions/v2/firestore";
import { logger } from "firebase-functions/v2";
import { defineSecret } from "firebase-functions/params";

// Secrets - configure these using firebase functions:secrets:set
const TELEGRAM_BOT_TOKEN = defineSecret("TELEGRAM_BOT_TOKEN");
const TELEGRAM_CHAT_ID = defineSecret("TELEGRAM_CHAT_ID");

/**
 * Sends a message to Telegram using the Bot API
 */
async function sendTelegramMessage(text: string): Promise<void> {
  const botToken = TELEGRAM_BOT_TOKEN.value();
  const chatId = TELEGRAM_CHAT_ID.value();

  if (!botToken || !chatId) {
    logger.warn("Telegram credentials not configured, skipping notification");
    return;
  }

  try {
    const response = await fetch(
      `https://api.telegram.org/bot${botToken}/sendMessage`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          chat_id: chatId,
          text,
          parse_mode: "HTML",
        }),
      }
    );

    if (!response.ok) {
      const error = await response.text();
      logger.error("Failed to send Telegram message", { error });
    } else {
      logger.info("Telegram notification sent successfully");
    }
  } catch (error) {
    logger.error("Error sending Telegram message", { error });
  }
}

/**
 * Notifies when a new incident is created
 */
export const notifyNewIncident = onDocumentCreated(
  {
    document: "teams/{teamId}/incidents/{incidentId}",
    secrets: [TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID],
  },
  async (event) => {
    const incident = event.data?.data();
    if (!incident) {
      return;
    }

    const teamId = event.params.teamId;
    const incidentId = event.params.incidentId;

    const message = `
🆕 <b>New Incident Created</b>

<b>Team:</b> ${teamId}
<b>Title:</b> ${incident.title || "Untitled"}
<b>Status:</b> ${incident.status || "unknown"}
<b>Client:</b> ${incident.clientRef?.id || "N/A"}
<b>ID:</b> ${incidentId}
    `.trim();

    await sendTelegramMessage(message);
  }
);

/**
 * Notifies when a new client is created
 */
export const notifyNewClient = onDocumentCreated(
  {
    document: "teams/{teamId}/clients/{clientId}",
    secrets: [TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID],
  },
  async (event) => {
    const client = event.data?.data();
    if (!client) {
      return;
    }

    const teamId = event.params.teamId;
    const clientId = event.params.clientId;

    const message = `
🏢 <b>New Client Added</b>

<b>Team:</b> ${teamId}
<b>Name:</b> ${client.name || "Unnamed"}
<b>Address:</b> ${client.address || "N/A"}
<b>ID:</b> ${clientId}
    `.trim();

    await sendTelegramMessage(message);
  }
);

/**
 * Notifies when a new user joins a team
 */
export const notifyNewUser = onDocumentCreated(
  {
    document: "teams/{teamId}/users/{userId}",
    secrets: [TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID],
  },
  async (event) => {
    const user = event.data?.data();
    if (!user) {
      return;
    }

    const teamId = event.params.teamId;
    const userId = event.params.userId;

    const message = `
👤 <b>New User Joined Team</b>

<b>Team:</b> ${teamId}
<b>Name:</b> ${user.displayName || "Unknown"}
<b>Email:</b> ${user.email || "N/A"}
<b>Role:</b> ${user.role || "member"}
<b>ID:</b> ${userId}
    `.trim();

    await sendTelegramMessage(message);
  }
);
