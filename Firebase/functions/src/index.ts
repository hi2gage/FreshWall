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

export { joinTeamCreateUser } from "./signup/joinTeamCreateUser";
export { createTeamCreateUser } from "./signup/createTeamCreateUser";
// Trigger to update client document with latest incident timestamp when a new incident is written
import { onDocumentWritten } from "firebase-functions/v2/firestore";

export const updateClientLastIncident = onDocumentWritten(
  "teams/{teamId}/clients/{clientId}/incidents/{incidentId}",
  async (event) => {
    const { teamId, clientId } = event.params;
    const clientRef = admin
      .firestore()
      .collection("teams")
      .doc(teamId)
      .collection("clients")
      .doc(clientId);
    const now = admin.firestore.Timestamp.now();
    await clientRef.update({ lastIncidentAt: now });
  }
);