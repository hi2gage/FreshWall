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