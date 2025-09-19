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

    console.log("🔍 Looking for user:", uid);

    // ✅ OPTIMIZED: Use collection group query to find user with admin/manager role
    console.log("🔍 Starting collection group query...");

    let userQuery;
    try {
      userQuery = await admin
        .firestore()
        .collectionGroup("users")
        .where("role", "in", ["admin", "manager"])
        .get();
      console.log("✅ Collection group query completed");
    } catch (error) {
      console.log("❌ Collection group query failed:", error);
      // Fallback: try separate queries
      console.log("🔄 Trying fallback queries...");

      const adminQuery = await admin
        .firestore()
        .collectionGroup("users")
        .where("role", "==", "admin")
        .get();

      const managerQuery = await admin
        .firestore()
        .collectionGroup("users")
        .where("role", "==", "manager")
        .get();

      userQuery = {
        docs: [...adminQuery.docs, ...managerQuery.docs]
      };
      console.log("✅ Fallback queries completed");
    }

    console.log("🔍 Found", userQuery.docs.length, "admin/manager users");
    userQuery.docs.forEach(doc => {
      console.log("🔍 User:", doc.id, "Role:", doc.data().role, "Path:", doc.ref.path);
    });

    // Find the user document that matches the authenticated user ID
    const userDoc = userQuery.docs.find(doc => doc.id === uid);

    if (!userDoc) {
      console.log("❌ User not found in admin/manager list");
      console.log("🔍 Looking for UID:", uid);

      // Fallback: try to find user without role restriction
      const allUsersQuery = await admin
        .firestore()
        .collectionGroup("users")
        .where(admin.firestore.FieldPath.documentId(), "==", uid)
        .get();

      console.log("🔍 Found", allUsersQuery.docs.length, "users with this UID");
      allUsersQuery.docs.forEach(doc => {
        console.log("🔍 User found:", doc.id, "Role:", doc.data().role, "Path:", doc.ref.path);
      });

      throw new Error("User must be a team admin or manager to generate invite codes.");
    }

    console.log("✅ Found user:", userDoc.id, "with role:", userDoc.data().role);

    const teamRef = userDoc.ref.parent.parent;

    if (!teamRef) {
      console.log("❌ Invalid team reference");
      throw new Error("Invalid team reference.");
    }

    if (!teamRef.id) {
      console.log("❌ Team reference has no ID");
      console.log("🔍 teamRef:", teamRef);
      console.log("🔍 userDoc.ref.path:", userDoc.ref.path);
      throw new Error("Team reference has no ID.");
    }

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
