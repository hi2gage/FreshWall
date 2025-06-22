import * as admin from "firebase-admin";
import { FieldValue, FieldPath } from "firebase-admin/firestore";
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

		const teamsSnapshot = await admin.firestore().collection("teams").get();
		for (const teamDoc of teamsSnapshot.docs) {
			const userDoc = await teamDoc.ref.collection("users").doc(uid).get();
			if (userDoc.exists) {
				throw new Error("User already belongs to a team.");
			}
		}

                const inviteQuery = await admin
                        .firestore()
                        .collectionGroup("inviteCodes")
                        .where(FieldPath.documentId(), "==", inviteCode)
                        .get();

                if (inviteQuery.empty) {
                        throw new Error("Code not found");
                }

                const inviteDoc = inviteQuery.docs[0];
                const inviteData = inviteDoc.data();
                const teamRef = inviteDoc.ref.parent.parent;

                if (!teamRef) {
                        throw new Error("Invalid invite code");
                }

                const expiresAt = inviteData.expiresAt as admin.firestore.Timestamp;
                const maxUses = inviteData.maxUses as number;
                const usedCount = inviteData.usedCount as number;
                const role = inviteData.role as string;

                if (expiresAt.toMillis() <= Date.now()) {
                        throw new Error("Code expired");
                }

                if (usedCount >= maxUses) {
                        throw new Error("Code used too many times");
                }

                const teamId = teamRef.id;

                await admin.firestore().runTransaction(async (tx) => {
                        const snap = await tx.get(inviteDoc.ref);
                        const data = snap.data();
                        if (!data) {
                                throw new Error("Code not found");
                        }
                        if ((data.expiresAt as admin.firestore.Timestamp).toMillis() <= Date.now()) {
                                throw new Error("Code expired");
                        }
                        if ((data.usedCount as number) >= (data.maxUses as number)) {
                                throw new Error("Code used too many times");
                        }

                        tx.update(inviteDoc.ref, { usedCount: FieldValue.increment(1) });
                        tx.set(teamRef.collection("users").doc(uid), {
                                displayName,
                                email,
                                role: role || "member",
                                isDeleted: false,
                                createdAt: FieldValue.serverTimestamp(),
                        });
                });

                logger.info(
                        `✅ joinTeamCreateUser success: user ${uid} joined team ${teamId}`,
                );
                return { teamId };
	} catch (err: unknown) {
	if (err instanceof Error) {
		logger.error(`❌ joinTeamCreateUser failed: ${err.message}`);
		throw new Error(`Failed to join team: ${err.message}`);
	} else {
		logger.error("❌ joinTeamCreateUser failed: unknown error");
		throw new Error("Failed to join team: unknown error");
	}
}
});
