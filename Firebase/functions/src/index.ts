/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// functions/src/index.ts
import * as admin from "firebase-admin";

admin.initializeApp();

export { createTeamCreateUser } from "./signup/createTeamCreateUser";
export { joinTeamCreateUser } from "./signup/joinTeamCreateUser";
export { generateInviteCode } from "./signup/generateInviteCode";

// Trigger to update client document with latest incident timestamp when a new incident is written
import { onDocumentWritten } from "firebase-functions/v2/firestore";

export const updateClientLastIncident = onDocumentWritten(
  "teams/{teamId}/incidents/{incidentId}",
  async (event) => {
    const after = event.data?.after?.data();
    if (!after) {
      return;
    }
    const clientRef = admin.firestore().doc(after.clientRef.path);
    const createdAt = after.createdAt as admin.firestore.Timestamp;
    await clientRef.update({ lastIncidentAt: createdAt });
  },
);
