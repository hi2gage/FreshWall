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
    const teamId: string = request.data.teamId;
    const role: string = request.data.role ?? "member";
    const maxUses: number = request.data.maxUses ?? 10;

    if (!teamId) {
      throw new Error("teamId is required.");
    }

    const now = Timestamp.now();
    const expiresAt = Timestamp.fromMillis(
      now.toMillis() + 7 * 24 * 60 * 60 * 1000 // 7 days from now
    );

    console.log("🔍 Looking for user:", uid, "in team:", teamId);

    // ✅ DIRECT QUERY: Check user's role in the specific team
    const userRef = admin.firestore()
      .collection("teams")
      .doc(teamId)
      .collection("users")
      .doc(uid);

    const userDoc = await userRef.get();

    if (!userDoc.exists) {
      console.log("❌ User not found in team:", teamId);
      throw new Error("User not found in the specified team.");
    }

    const userData = userDoc.data();
    const userRole = userData?.role;

    console.log("✅ Found user:", uid, "with role:", userRole);

    if (!userRole || !["admin", "manager"].includes(userRole)) {
      console.log("❌ User role insufficient:", userRole);
      throw new Error("User must be a team admin or manager to generate invite codes.");
    }

    const teamRef = admin.firestore().collection("teams").doc(teamId);

    console.log("✅ Team reference:", teamRef.id);

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

    console.log("🔍 Starting transaction to create invite code:", code);

    // ✅ OPTIMIZED: Use transaction to ensure atomic code creation
    await admin.firestore().runTransaction(async (transaction) => {
      console.log("🔍 Inside transaction, checking code existence");

      // Double-check the code doesn't exist in the transaction
      const codeCheck = await transaction.get(codeDoc);
      if (codeCheck.exists) {
        console.log("❌ Code collision detected in transaction");
        throw new Error("Invite code collision detected.");
      }

      console.log("🔍 Creating invite code document");

      transaction.set(codeDoc, {
        createdAt: FieldValue.serverTimestamp(),
        createdBy: uid,
        expiresAt,
        maxUses,
        usedCount: 0,
        role,
      });

      console.log("✅ Transaction set completed");
    });

    console.log("✅ Transaction completed successfully");

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
