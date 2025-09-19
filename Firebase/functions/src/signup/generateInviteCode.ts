import { randomBytes } from "node:crypto";
import * as admin from "firebase-admin";
import { Timestamp, FieldValue } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { onCall } from "firebase-functions/v2/https";

export const generateInviteCode = onCall(async (request) => {
  try {
    if (!request.auth?.uid) {
      throw new Error("User must be authenticated.");
    }

    const uid = request.auth.uid;
    const role: string = request.data.role ?? "member";
    const maxUses: number = request.data.maxUses ?? 10;

    const now = Timestamp.now();
    const expiresAt = Timestamp.fromMillis(
      now.toMillis() + 7 * 24 * 60 * 60 * 1000 // 7 days from now
    );

    const teamsSnapshot = await admin.firestore().collection("teams").get();
    let teamDoc: admin.firestore.QueryDocumentSnapshot | null = null;

    for (const doc of teamsSnapshot.docs) {
      const userDoc = await doc.ref.collection("users").doc(uid).get();
      if (userDoc.exists) {
        const data = userDoc.data();
        if (data?.role === "lead") {
          teamDoc = doc;
          break;
        } else {
          throw new Error("Only team leads can generate invite codes.");
        }
      }
    }

    if (!teamDoc) {
      throw new Error("User must belong to a team.");
    }

    const code = randomBytes(3).toString("hex").toUpperCase();

    await teamDoc.ref.collection("inviteCodes").doc(code).set({
      createdAt: FieldValue.serverTimestamp(),
      createdBy: uid,
      expiresAt,
      maxUses,
      usedCount: 0,
      role,
    });

    // Generate join URL
    const baseUrl = process.env.WEB_BASE_URL || 'https://freshwall.app';
    const joinUrl = `${baseUrl}/more/join?teamCode=${code}`;

    logger.info(
      `✅ Invite code ${code} created for team ${teamDoc.id} by user ${uid}`
    );
    logger.info(`🔗 Join URL: ${joinUrl}`);

    return {
      code,
      expiresAt,
      joinUrl,
      teamId: teamDoc.id,
      role,
      maxUses
    };
  } catch (err: unknown) {
    const message =
      err instanceof Error ? err.message : "unknown error";
    logger.error(`❌ generateInviteCode failed: ${message}`);
    throw new Error(`Failed to generate code: ${message}`);
  }
});
