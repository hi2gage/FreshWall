#!/usr/bin/env node

/**
 * Clone Firestore data from production to staging (including images)
 *
 * Usage:
 *   node Scripts/clone-firestore-data.js --team-id=TEAM_ID [options]
 *
 * Examples:
 *   # Dry run (preview only)
 *   node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49 --dry-run
 *
 *   # Full migration with images
 *   node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49
 *
 *   # Skip image migration
 *   node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49 --skip-images
 *
 * Prerequisites:
 *   1. npm install firebase-admin
 *   2. Install gcloud CLI: brew install google-cloud-sdk
 *   3. Authenticate with both projects:
 *      gcloud auth application-default login
 *   4. Download production service account key (staging will use gcloud auth):
 *      - Production: Firebase Console → Project Settings → Service Accounts → Generate New Private Key
 *      - Save as: Firebase/prod-service-account.json
 */

const admin = require('firebase-admin');
const path = require('path');
const readline = require('readline');

// Parse command line arguments
const args = process.argv.slice(2).reduce((acc, arg) => {
  const [key, value] = arg.split('=');
  acc[key.replace('--', '')] = value || true;
  return acc;
}, {});

const SOURCE_TEAM_ID = args['team-id'];
const DRY_RUN = args['dry-run'] || false;
const SKIP_IMAGES = args['skip-images'] || false;
const NEW_TEAM_ID = args['new-team-id'] || false;

if (!SOURCE_TEAM_ID) {
  console.error('❌ Error: --team-id is required');
  console.log('\nUsage:');
  console.log('  node Scripts/clone-firestore-data.js --team-id=4bn04KFSRcPvGbHXOV49');
  console.log('\nOptions:');
  console.log('  --dry-run       Preview what will be copied (no changes)');
  console.log('  --skip-images   Skip copying Storage images');
  console.log('  --new-team-id   Generate a new team ID for staging (recommended)');
  process.exit(1);
}

// Try to load production service account, fall back to application default credentials
let prodCredential;
const prodServiceAccountPath = path.join(__dirname, '../Firebase/prod-service-account.json');
try {
  const fs = require('fs');
  if (fs.existsSync(prodServiceAccountPath)) {
    prodCredential = admin.credential.cert(prodServiceAccountPath);
    console.log('✓ Using production service account key');
  } else {
    prodCredential = admin.credential.applicationDefault();
    console.log('✓ Using application default credentials for production');
  }
} catch (error) {
  prodCredential = admin.credential.applicationDefault();
  console.log('✓ Using application default credentials for production');
}

// Initialize production Firebase
const prodApp = admin.initializeApp({
  credential: prodCredential,
  projectId: 'freshwall-30afe',
  storageBucket: 'freshwall-30afe.appspot.com'
}, 'production');

// Staging always uses application default credentials (to avoid org policy restrictions)
console.log('✓ Using application default credentials for staging');
const stagingApp = admin.initializeApp({
  credential: admin.credential.applicationDefault(),
  projectId: 'freshwall-staging',
  storageBucket: 'freshwall-staging.firebasestorage.app'
}, 'staging');

const prodDb = prodApp.firestore();
const stagingDb = stagingApp.firestore();
const prodBucket = prodApp.storage().bucket();
const stagingBucket = stagingApp.storage().bucket();

// Sub-collections under /teams/{teamId}/
const TEAM_SUBCOLLECTIONS = [
  'clients',
  'incidents',
  'users',
  'inviteCodes'
];

// Utility to ask user for confirmation
function askQuestion(query) {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });

  return new Promise(resolve => rl.question(query, ans => {
    rl.close();
    resolve(ans);
  }));
}

/**
 * Copy a Storage file from production to staging
 * If new team ID is used, updates the path
 */
async function copyStorageFile(sourcePath, sourceTeamId, destTeamId) {
  try {
    const destPath = sourcePath.replace(sourceTeamId, destTeamId);
    const [file] = await prodBucket.file(sourcePath).download();
    await stagingBucket.file(destPath).save(file, {
      metadata: {
        contentType: 'image/jpeg', // Adjust if needed
      }
    });
    return { success: true, newPath: destPath };
  } catch (error) {
    console.error(`    ⚠️  Failed to copy ${sourcePath}:`, error.message);
    return { success: false, newPath: null };
  }
}

/**
 * Extract Storage paths from photo objects
 */
function extractStoragePaths(photos) {
  if (!photos || !Array.isArray(photos)) return [];

  return photos
    .filter(photo => photo.fullPath)
    .map(photo => photo.fullPath);
}

/**
 * Main migration function
 */
async function migrateTeam() {
  // Determine destination team ID
  const DEST_TEAM_ID = NEW_TEAM_ID ? stagingDb.collection('teams').doc().id : SOURCE_TEAM_ID;

  console.log('🔍 Firestore Data Migration Tool');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('');
  console.log(`Source:           freshwall-30afe (Production)`);
  console.log(`Destination:      freshwall-staging (Staging)`);
  console.log(`Source Team ID:   ${SOURCE_TEAM_ID}`);
  if (NEW_TEAM_ID) {
    console.log(`Dest Team ID:     ${DEST_TEAM_ID} (NEW)`);
  } else {
    console.log(`Dest Team ID:     ${DEST_TEAM_ID} (same as source)`);
  }
  console.log(`Mode:             ${DRY_RUN ? '🔍 DRY RUN (preview only)' : '⚠️  LIVE MIGRATION'}`);
  console.log(`Images:           ${SKIP_IMAGES ? '⏭️  SKIP' : '✅ COPY'}`);
  console.log('');

  try {
    // Step 1: Get team data from production
    console.log('📊 Step 1: Analyzing production data...');
    const teamRef = prodDb.collection('teams').doc(SOURCE_TEAM_ID);
    const teamDoc = await teamRef.get();

    if (!teamDoc.exists) {
      console.error(`❌ Team ${SOURCE_TEAM_ID} not found in production`);
      process.exit(1);
    }

    const teamData = teamDoc.data();
    console.log(`   ✓ Team found: ${teamData.name}`);

    // Step 2: Get subcollections
    const users = await teamRef.collection('users').get();
    const clients = await teamRef.collection('clients').get();
    const incidents = await teamRef.collection('incidents').get();
    const inviteCodes = await teamRef.collection('inviteCodes').get();

    console.log(`   ✓ Users: ${users.size}`);
    console.log(`   ✓ Clients: ${clients.size}`);
    console.log(`   ✓ Incidents: ${incidents.size}`);
    console.log(`   ✓ Invite Codes: ${inviteCodes.size}`);

    // Count photos and collect paths
    let photoCount = 0;
    const allPhotoPaths = [];
    incidents.forEach(doc => {
      const data = doc.data();
      if (data.beforePhotos) {
        photoCount += data.beforePhotos.length;
        allPhotoPaths.push(...extractStoragePaths(data.beforePhotos));
      }
      if (data.afterPhotos) {
        photoCount += data.afterPhotos.length;
        allPhotoPaths.push(...extractStoragePaths(data.afterPhotos));
      }
    });
    console.log(`   ✓ Photos: ${photoCount}${SKIP_IMAGES ? ' (will skip)' : ''}`);

    console.log('');

    // Step 3: Show preview
    console.log('📋 Data Preview:');
    console.log('');
    console.log('Team:', teamData.name, `(Code: ${teamData.teamCode})`);
    console.log('');
    console.log('Users:');
    users.docs.slice(0, 3).forEach(doc => {
      const data = doc.data();
      console.log(`  - ${data.displayName || data.email} (${data.role})`);
    });
    if (users.size > 3) console.log(`  ... and ${users.size - 3} more`);
    console.log('');
    console.log('Clients:');
    clients.docs.slice(0, 3).forEach(doc => {
      const data = doc.data();
      console.log(`  - ${data.name}`);
    });
    if (clients.size > 3) console.log(`  ... and ${clients.size - 3} more`);
    console.log('');
    console.log('Incidents:');
    incidents.docs.slice(0, 3).forEach(doc => {
      const data = doc.data();
      const title = data.title || data.description || 'Untitled';
      console.log(`  - ${title.substring(0, 50)} (${data.status})`);
    });
    if (incidents.size > 3) console.log(`  ... and ${incidents.size - 3} more`);
    console.log('');
    console.log('Invite Codes:');
    inviteCodes.docs.slice(0, 3).forEach(doc => {
      const data = doc.data();
      console.log(`  - Code: ${doc.id} (Role: ${data.role})`);
    });
    if (inviteCodes.size > 3) console.log(`  ... and ${inviteCodes.size - 3} more`);
    console.log('');

    // Step 4: Confirmation
    if (DRY_RUN) {
      console.log('✅ DRY RUN complete. No data was copied.');
      console.log('');
      console.log('To perform actual migration, run without --dry-run');
      process.exit(0);
    }

    console.log('⚠️  WARNING: This will copy data to staging environment');
    console.log('');
    const answer = await askQuestion('Continue? (yes/no): ');

    if (answer.toLowerCase() !== 'yes') {
      console.log('Aborted.');
      process.exit(0);
    }

    // Step 5: Create team in staging
    console.log('');
    console.log('📝 Step 2: Creating team in staging...');
    const stagingTeamRef = stagingDb.collection('teams').doc(DEST_TEAM_ID);

    await stagingTeamRef.set(teamData);
    console.log(`   ✓ Team created with ID: ${DEST_TEAM_ID}`);

    // Step 6: Copy users
    console.log('');
    console.log('👥 Step 3: Copying users...');
    let userCount = 0;
    for (const doc of users.docs) {
      const userData = doc.data();
      await stagingTeamRef.collection('users').doc(doc.id).set(userData);
      userCount++;
      process.stdout.write(`\r   Copied ${userCount}/${users.size} users`);
    }
    console.log(' ✓');

    // Step 7: Copy clients
    console.log('');
    console.log('🏢 Step 4: Copying clients...');
    let clientCount = 0;
    for (const doc of clients.docs) {
      const clientData = doc.data();
      await stagingTeamRef.collection('clients').doc(doc.id).set(clientData);
      clientCount++;
      process.stdout.write(`\r   Copied ${clientCount}/${clients.size} clients`);
    }
    console.log(' ✓');

    // Step 8: Copy invite codes
    console.log('');
    console.log('🎟️  Step 5: Copying invite codes...');
    let inviteCount = 0;
    for (const doc of inviteCodes.docs) {
      const inviteData = doc.data();
      await stagingTeamRef.collection('inviteCodes').doc(doc.id).set(inviteData);
      inviteCount++;
      process.stdout.write(`\r   Copied ${inviteCount}/${inviteCodes.size} invite codes`);
    }
    console.log(' ✓');

    // Step 9: Copy incidents (update photo paths if new team ID)
    console.log('');
    console.log('📍 Step 6: Copying incidents...');
    let incidentCount = 0;
    for (const doc of incidents.docs) {
      const incidentData = doc.data();

      // Update photo paths if using new team ID
      if (NEW_TEAM_ID) {
        if (incidentData.beforePhotos) {
          incidentData.beforePhotos = incidentData.beforePhotos.map(photo => {
            const updated = { ...photo };
            if (photo.fullPath) {
              updated.fullPath = photo.fullPath.replace(SOURCE_TEAM_ID, DEST_TEAM_ID);
            }
            return updated;
          });
        }
        if (incidentData.afterPhotos) {
          incidentData.afterPhotos = incidentData.afterPhotos.map(photo => {
            const updated = { ...photo };
            if (photo.fullPath) {
              updated.fullPath = photo.fullPath.replace(SOURCE_TEAM_ID, DEST_TEAM_ID);
            }
            return updated;
          });
        }
      }

      await stagingTeamRef.collection('incidents').doc(doc.id).set(incidentData);
      incidentCount++;
      process.stdout.write(`\r   Copied ${incidentCount}/${incidents.size} incidents`);
    }
    console.log(' ✓');

    // Step 10: Copy photos (with updated paths if new team ID)
    if (!SKIP_IMAGES && allPhotoPaths.length > 0) {
      console.log('');
      console.log('📸 Step 7: Copying photos from Storage...');
      let photosCopied = 0;
      let photosFailed = 0;

      for (let i = 0; i < allPhotoPaths.length; i++) {
        const photoPath = allPhotoPaths[i];
        const result = await copyStorageFile(photoPath, SOURCE_TEAM_ID, DEST_TEAM_ID);
        if (result.success) {
          photosCopied++;
        } else {
          photosFailed++;
        }
        process.stdout.write(`\r   Copied ${photosCopied}/${allPhotoPaths.length} photos (${photosFailed} failed)`);
      }
      console.log(' ✓');
    }

    // Done!
    console.log('');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ Migration Complete!');
    console.log('');
    console.log('Summary:');
    console.log(`  Source Team ID:    ${SOURCE_TEAM_ID}`);
    console.log(`  Dest Team ID:      ${DEST_TEAM_ID}${NEW_TEAM_ID ? ' (NEW)' : ''}`);
    console.log(`  Team Name:         ${teamData.name}`);
    console.log(`  Users copied:      ${userCount}`);
    console.log(`  Clients copied:    ${clientCount}`);
    console.log(`  Invite codes:      ${inviteCount}`);
    console.log(`  Incidents copied:  ${incidentCount}`);
    if (SKIP_IMAGES) {
      console.log(`  Photos:            Skipped`);
    } else {
      console.log(`  Photos copied:     ${photoCount}`);
    }
    console.log('');
    console.log('Next steps:');
    console.log('  1. Test the staging app with this team data');
    console.log('  2. Team code: ' + teamData.teamCode);
    console.log('  3. Users need to create accounts and join with team code');
    console.log('  4. Original passwords won\'t work (different Firebase Auth)');
    console.log('');

  } catch (error) {
    console.error('');
    console.error('❌ Migration failed:', error);
    console.error('');
    console.error('Stack trace:', error.stack);
    process.exit(1);
  } finally {
    await prodApp.delete();
    await stagingApp.delete();
  }
}

// Run migration
migrateTeam()
  .then(() => {
    console.log('🎉 All done!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('💥 Fatal error:', error);
    process.exit(1);
  });
