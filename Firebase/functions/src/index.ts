/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// functions/src/index.ts
import { onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";

admin.initializeApp();

export const joinTeam = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated.");
    }

    const uid = request.auth.uid;
    const teamCode = request.data.teamCode?.toUpperCase()?.trim();
    const email = request.data.email ?? null;
    const displayName = request.data.displayName?.trim();

    if (!teamCode || !displayName) {
      throw new Error("Missing teamCode or displayName.");
    }

    const teamsSnapshot = await admin.firestore().collection("teams").get();
    for (const teamDoc of teamsSnapshot.docs) {
      const userDoc = await teamDoc.ref.collection("users").doc(uid).get();
      if (userDoc.exists) {
        throw new Error("User already belongs to a team.");
      }
    }

    const teams = await admin
      .firestore()
      .collection("teams")
      .where("teamCode", "==", teamCode)
      .get();
    if (teams.empty) {
      throw new Error("No team found with that code.");
    }

    const teamDoc = teams.docs[0];
    const teamId = teamDoc.id;

    await teamDoc.ref.collection("users").doc(uid).set({
      displayName,
      email,
      role: "member",
      isDeleted: false,
      createdAt: FieldValue.serverTimestamp(),
    });

    logger.info(`✅ joinTeam success: user ${uid} joined team ${teamId}`);
    return { teamId };
  } catch (err: any) {
    logger.error(`❌ joinTeam failed: ${err.message ?? err}`);
    throw new Error("Failed to join team: " + (err.message ?? "unknown error"));
  }
});