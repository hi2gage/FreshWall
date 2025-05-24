import { onCall } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import { randomBytes } from "crypto";

export const createTeamCreateUser = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated.");
    }

    const uid = request.auth.uid;
    const teamName = request.data.teamName?.trim();
    const displayName = request.data.displayName?.trim();
    const email: string | null = request.data.email ?? null;

    if (!teamName || !displayName) {
      throw new Error("Missing teamName or displayName.");
    }

    const teamCode = randomBytes(3).toString("hex").toUpperCase();
    const teamRef = admin.firestore().collection("teams").doc();
    await teamRef.set({
      name: teamName,
      teamCode,
      createdAt: FieldValue.serverTimestamp(),
    });
    const teamId = teamRef.id;

    await teamRef.collection("users").doc(uid).set({
      displayName,
      email,
      role: "lead",
      isDeleted: false,
      createdAt: FieldValue.serverTimestamp(),
    });

    logger.info(`✅ createTeamCreateUser success: user ${uid} created team ${teamId}`);
    return { teamId, teamCode };
  } catch (err: any) {
    logger.error(`❌ createTeamCreateUser failed: ${err.message ?? err}`);
    throw new Error("Failed to create team and user: " + (err.message ?? "unknown error"));
  }
});