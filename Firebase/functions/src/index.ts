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
import { FieldPath, FieldValue } from "firebase-admin/firestore";

admin.initializeApp();

export const joinTeam = onCall(async (request) => {
  logger.debug("joinTeam function called");

  if (!request.auth?.uid) {
    logger.error("Authentication missing");
    throw new Error("User must be authenticated.");
  }

  const uid = request.auth.uid;
  const teamCode = request.data.teamCode?.toUpperCase()?.trim();
  const email = request.data.email ?? null;
  const displayName = request.data.displayName?.trim();

  logger.debug("Request Data:", {
    uid,
    teamCode,
    email,
    displayName,
  });

  if (!teamCode || !displayName) {
    logger.error("Missing teamCode or displayName");
    throw new Error("Missing teamCode or displayName.");
  }

  try {
    logger.debug("Checking if user is already in a team...");

    const teamsSnapshot = await admin.firestore().collection("teams").get();

    for (const teamDoc of teamsSnapshot.docs) {
      const userDoc = await teamDoc.ref.collection("users").doc(uid).get();
      if (userDoc.exists) {
        logger.debug(`User already exists in team ${teamDoc.id}`);
        throw new Error("User already belongs to a team.");
      }
    }

    logger.debug(`Looking up team by code: ${teamCode}`);
    const teams = await admin
      .firestore()
      .collection("teams")
      .where("teamCode", "==", teamCode)
      .get();

    if (teams.empty) {
      logger.error("No team found with provided code");
      throw new Error("No team found with that code.");
    }

    const teamDoc = teams.docs[0];
    const teamId = teamDoc.id;

    logger.debug(`Adding user to team ${teamId}`);

    const userRef = teamDoc.ref.collection("users").doc(uid);
    await userRef.set({
      displayName,
      email,
      role: "member",
      isDeleted: false,
      createdAt: FieldValue.serverTimestamp(),
    });

    logger.info(`✅ User ${uid} successfully joined team ${teamId}`);
    return { teamId };
  } catch (err: any) {
    logger.error("🔥 joinTeam failed", err);
    throw new Error("Failed to join team: " + (err.message ?? "unknown error"));
  }
});