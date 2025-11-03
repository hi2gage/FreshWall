#!/usr/bin/env node

/**
 * Check expiration dates of invite codes for a team
 */

const admin = require('firebase-admin');
const path = require('path');

const TEAM_ID = '4bn04KFSRcPvGbHXOV49';

// Try to load production service account, fall back to application default credentials
let prodCredential;
const prodServiceAccountPath = path.join(__dirname, '../Firebase/prod-service-account.json');
try {
  const fs = require('fs');
  if (fs.existsSync(prodServiceAccountPath)) {
    prodCredential = admin.credential.cert(prodServiceAccountPath);
  } else {
    prodCredential = admin.credential.applicationDefault();
  }
} catch (error) {
  prodCredential = admin.credential.applicationDefault();
}

// Initialize production Firebase
const prodApp = admin.initializeApp({
  credential: prodCredential,
  projectId: 'freshwall-30afe',
}, 'production');

const prodDb = prodApp.firestore();

async function checkInviteCodes() {
  console.log('🔍 Checking invite codes for team:', TEAM_ID);
  console.log('');

  const teamRef = prodDb.collection('teams').doc(TEAM_ID);
  const inviteCodes = await teamRef.collection('inviteCodes').get();

  console.log(`Found ${inviteCodes.size} invite codes:`);
  console.log('');

  const now = Date.now();

  inviteCodes.docs.forEach(doc => {
    const data = doc.data();
    const expiresAt = data.expiresAt.toMillis();
    const daysUntilExpiry = Math.floor((expiresAt - now) / (1000 * 60 * 60 * 24));
    const isExpired = expiresAt <= now;

    const status = isExpired ? '❌ EXPIRED' : `✅ Valid (${daysUntilExpiry} days left)`;

    console.log(`Code: ${doc.id}`);
    console.log(`  Role: ${data.role}`);
    console.log(`  Status: ${status}`);
    console.log(`  Created: ${data.createdAt.toDate().toLocaleDateString()}`);
    console.log(`  Expires: ${new Date(expiresAt).toLocaleDateString()}`);
    console.log(`  Uses: ${data.usedCount}/${data.maxUses}`);
    console.log('');
  });

  await prodApp.delete();
}

checkInviteCodes()
  .then(() => {
    console.log('✅ Done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('❌ Error:', error);
    process.exit(1);
  });
