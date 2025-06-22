import * as admin from "firebase-admin";
import { FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onCall } from "firebase-functions/v2/https";

export const joinTeamCreateUser = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated.");
    }

    const uid = request.auth.uid;
    const inviteCode = request.data.teamCode?.toUpperCase()?.trim();
    const email: string | null = request.data.email ?? null;
    const displayName = request.data.displayName?.trim();

    if (!inviteCode || !displayName) {
      throw new Error("Missing inviteCode or displayName.");
    }

    // Ensure user doesn't already belong to a team
    const teamsSnapshot = await admin.firestore().collection("teams").get();
    for (const teamDoc of teamsSnapshot.docs) {
      const userDoc = await teamDoc.ref.collection("users").doc(uid).get();
      if (userDoc.exists) {
        throw new Error("User already belongs to a team.");
      }
    }

    // Look for invite by doc.id match
    const allInviteDocs = await admin
      .firestore()
      .collectionGroup("inviteCodes")
      .get();

    const inviteDoc = allInviteDocs.docs.find((doc) => doc.id === inviteCode);

    if (!inviteDoc) {
      throw new Error("Invite code not found.");
    }

    const inviteData = inviteDoc.data();
    const teamRef = inviteDoc.ref.parent.parent;

    if (!teamRef) {
      throw new Error("Invalid invite code (no team ref).");
    }

    const expiresAt = inviteData.expiresAt as admin.firestore.Timestamp;
    const maxUses = inviteData.maxUses as number;
    const usedCount = inviteData.usedCount as number;
    const role = inviteData.role as string;

    if (expiresAt.toMillis() <= Date.now()) {
      throw new Error("Code expired.");
    }

    if (usedCount >= maxUses) {
      throw new Error("Code has been used too many times.");
    }

    const teamId = teamRef.id;

    // Atomically update invite + add user to team
    await admin.firestore().runTransaction(async (tx) => {
      const snap = await tx.get(inviteDoc.ref);
      const data = snap.data();
      if (!data) throw new Error("Invite no longer exists.");

      const currentUsed = data.usedCount as number;
      const currentMax = data.maxUses as number;
      const currentExpires = (data.expiresAt as admin.firestore.Timestamp).toMillis();

      if (currentExpires <= Date.now()) {
        throw new Error("Code expired.");
      }

      if (currentUsed >= currentMax) {
        throw new Error("Code has already been used the maximum number of times.");
      }

      tx.update(inviteDoc.ref, {
        usedCount: FieldValue.increment(1),
      });

      tx.set(teamRef.collection("users").doc(uid), {
        displayName,
        email,
        role: role || "member",
        isDeleted: false,
        createdAt: FieldValue.serverTimestamp(),
      });
    });

    logger.info(`✅ joinTeamCreateUser success: user ${uid} joined team ${teamId}`);
    return { teamId };
  } catch (err: unknown) {
    const message = err instanceof Error ? err.message : "unknown error";
    logger.error(`❌ joinTeamCreateUser failed: ${message}`);
    throw new Error(`Failed to join team: ${message}`);
  }
});
