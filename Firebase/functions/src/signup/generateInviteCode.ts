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

    // ✅ OPTIMIZED: Use collection group query to find user with admin/manager role
    const userQuery = await admin
      .firestore()
      .collectionGroup("users")
      .where("role", "in", ["admin", "manager"])
      .get();

    // Find the user document that matches the authenticated user ID
    const userDoc = userQuery.docs.find(doc => doc.id === uid);

    if (!userDoc) {
      throw new Error("User must be a team admin or manager to generate invite codes.");
    }

    const teamRef = userDoc.ref.parent.parent;

    if (!teamRef) {
      throw new Error("Invalid team reference.");
    }

    // ✅ OPTIMIZED: Generate unique code with retry logic to prevent collisions
    let code: string;
    let codeDoc: admin.firestore.DocumentReference;
    let attempts = 0;
    const maxAttempts = 5;

    do {
      if (attempts >= maxAttempts) {
        throw new Error("Failed to generate unique invite code after multiple attempts.");
      }

      code = randomBytes(3).toString("hex").toUpperCase();
      codeDoc = teamRef.collection("inviteCodes").doc(code);

      // Check if code already exists
      const existingCode = await codeDoc.get();
      if (!existingCode.exists) {
        break;
      }

      attempts++;
    } while (true);

    // ✅ OPTIMIZED: Use transaction to ensure atomic code creation
    await admin.firestore().runTransaction(async (transaction) => {
      // Double-check the code doesn't exist in the transaction
      const codeCheck = await transaction.get(codeDoc);
      if (codeCheck.exists) {
        throw new Error("Invite code collision detected.");
      }

      transaction.set(codeDoc, {
        createdAt: FieldValue.serverTimestamp(),
        createdBy: uid,
        expiresAt,
        maxUses,
        usedCount: 0,
        role,
      });
    });

    // Generate join URL
    const baseUrl = process.env.WEB_BASE_URL || 'https://freshwall.app';
    const joinUrl = `${baseUrl}/more/join?teamCode=${code}`;

    logger.info(
      `✅ Invite code ${code} created for team ${teamRef.id} by user ${uid}`
    );
    logger.info(`🔗 Join URL: ${joinUrl}`);

    return {
      code,
      expiresAt,
      joinUrl,
      teamId: teamRef.id,
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
