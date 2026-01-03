#!/usr/bin/env node

/**
 * NocoDB Duplicate Marker
 * Marks duplicate entries based on URL or phone number
 * PROTECTS records with email or user_notes from being marked as duplicates
 */

const API_TOKEN = 'zVmKmhAOgE2zftUAN640P6liBGfReWm7uqIoQSrw';
const BASE_URL = 'http://nocodb.nas.lan';
const TABLE_ID = 'mbpovx8z8k7wlo6';

// Set to true to actually update records, false for dry run
const DRY_RUN = false;

async function fetchAllRecords() {
  console.log('📥 Fetching records from NocoDB...\n');

  let allRecords = [];
  let page = 1;
  const pageSize = 100;
  let hasMore = true;

  while (hasMore) {
    const url = `${BASE_URL}/api/v2/tables/${TABLE_ID}/records?limit=${pageSize}&offset=${(page - 1) * pageSize}`;

    const response = await fetch(url, {
      headers: {
        'xc-token': API_TOKEN,
        'Content-Type': 'application/json'
      }
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch records: ${response.status} ${response.statusText}`);
    }

    const data = await response.json();
    const records = data.list || [];
    allRecords = allRecords.concat(records);

    console.log(`   Fetched page ${page}: ${records.length} records (Total: ${allRecords.length}/${data.pageInfo.totalRows})`);

    hasMore = !data.pageInfo.isLastPage;
    page++;
  }

  return allRecords;
}

function hasValuableData(record) {
  // Check if record has email or user_notes
  const hasEmail = record.email && record.email.trim() !== '';
  const hasNotes = record.user_notes && record.user_notes.trim() !== '';
  return hasEmail || hasNotes;
}

function findDuplicatesToMark(records) {
  // Filter to only active records (not already marked as duplicates)
  const activeRecords = records.filter(record =>
    record.deduplicated_company === false || record.deduplicated_company === null
  );

  console.log(`\n🔍 Analyzing ${activeRecords.length} active records (filtered out ${records.length - activeRecords.length} already marked)\n`);

  const urlGroups = new Map();
  const phoneGroups = new Map();

  // Group by URL
  activeRecords.forEach(record => {
    const url = record.url?.trim().toLowerCase();
    if (url && url !== '') {
      if (!urlGroups.has(url)) {
        urlGroups.set(url, []);
      }
      urlGroups.get(url).push(record);
    }
  });

  // Group by phone
  activeRecords.forEach(record => {
    const phone = record.phone?.toString().trim();
    if (phone && phone !== '') {
      if (!phoneGroups.has(phone)) {
        phoneGroups.set(phone, []);
      }
      phoneGroups.get(phone).push(record);
    }
  });

  // Find records to mark as duplicates
  const toMark = new Set();
  const protected = new Set();

  // Process URL duplicates
  Array.from(urlGroups.values())
    .filter(group => group.length > 1)
    .forEach(group => {
      // Sort by ID (lowest first)
      group.sort((a, b) => a.ID - b.ID);

      // Find records with valuable data
      const withData = group.filter(hasValuableData);

      if (withData.length > 0) {
        // If any have data, keep ALL records with data and mark the rest
        group.forEach(record => {
          if (hasValuableData(record)) {
            protected.add(record.ID);
          } else {
            toMark.add(record.ID);
          }
        });
      } else {
        // No records have data, keep the first (lowest ID) and mark the rest
        group.slice(1).forEach(record => {
          toMark.add(record.ID);
        });
      }
    });

  // Process phone duplicates (same logic)
  Array.from(phoneGroups.values())
    .filter(group => group.length > 1)
    .forEach(group => {
      group.sort((a, b) => a.ID - b.ID);

      const withData = group.filter(hasValuableData);

      if (withData.length > 0) {
        group.forEach(record => {
          if (hasValuableData(record)) {
            protected.add(record.ID);
          } else if (!protected.has(record.ID)) {
            toMark.add(record.ID);
          }
        });
      } else {
        group.slice(1).forEach(record => {
          if (!protected.has(record.ID)) {
            toMark.add(record.ID);
          }
        });
      }
    });

  // Get full record objects for IDs to mark
  const recordsToMark = activeRecords.filter(record => toMark.has(record.ID));
  const protectedRecords = activeRecords.filter(record => protected.has(record.ID));

  return { recordsToMark, protectedRecords };
}

async function updateRecords(records) {
  // Batch updates in groups of 100 for efficiency
  const batchSize = 100;
  const url = `${BASE_URL}/api/v2/tables/${TABLE_ID}/records`;

  for (let i = 0; i < records.length; i += batchSize) {
    const batch = records.slice(i, i + batchSize);
    const payload = batch.map(record => ({
      ID: record.ID,
      deduplicated_company: true
    }));

    const response = await fetch(url, {
      method: 'PATCH',
      headers: {
        'xc-token': API_TOKEN,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify(payload)
    });

    if (!response.ok) {
      const text = await response.text();
      throw new Error(`Failed to update batch: ${response.status} ${response.statusText} - ${text}`);
    }

    await response.json();
  }
}

async function markDuplicates(recordsToMark) {
  console.log(`\n${DRY_RUN ? '🔍 DRY RUN - Would mark' : '✏️  Marking'} ${recordsToMark.length} records as duplicates...\n`);

  if (DRY_RUN) {
    recordsToMark.slice(0, 10).forEach(record => {
      console.log(`   [DRY RUN] Would mark ID ${record.ID}: ${record.company_name}`);
    });
    if (recordsToMark.length > 10) {
      console.log(`   ... and ${recordsToMark.length - 10} more records`);
    }
  } else {
    try {
      const batchSize = 100;
      for (let i = 0; i < recordsToMark.length; i += batchSize) {
        await updateRecords(recordsToMark.slice(i, i + batchSize));
        console.log(`   Updated ${Math.min(i + batchSize, recordsToMark.length)}/${recordsToMark.length} records...`);
      }
    } catch (error) {
      console.error(`   ❌ Error updating records: ${error.message}`);
      throw error;
    }
  }

  console.log(`\n${DRY_RUN ? '✅ DRY RUN Complete!' : '✅ Update Complete!'}`);
  console.log(`   ${recordsToMark.length} records ${DRY_RUN ? 'would be' : 'were'} marked as duplicates`);
}

function displayPreview(recordsToMark, protectedRecords) {
  console.log('\n📊 DUPLICATE MARKING PREVIEW\n');
  console.log('═'.repeat(80));

  console.log(`\n✅ PROTECTED RECORDS (${protectedRecords.length}):`);
  console.log('   These have email or notes and will NOT be marked as duplicates\n');

  protectedRecords.slice(0, 10).forEach(record => {
    const reasons = [];
    if (record.email) reasons.push(`email: ${record.email}`);
    if (record.user_notes) reasons.push(`notes: "${record.user_notes.substring(0, 30)}..."`);
    console.log(`   ID ${record.ID}: ${record.company_name} (${reasons.join(', ')})`);
  });

  if (protectedRecords.length > 10) {
    console.log(`   ... and ${protectedRecords.length - 10} more protected records`);
  }

  console.log(`\n❌ TO BE MARKED AS DUPLICATES (${recordsToMark.length}):`);
  console.log('   These will be marked with deduplicated_company = true\n');

  recordsToMark.slice(0, 20).forEach(record => {
    console.log(`   ID ${record.ID}: ${record.company_name} | URL: ${record.url || 'N/A'} | Phone: ${record.phone || 'N/A'}`);
  });

  if (recordsToMark.length > 20) {
    console.log(`   ... and ${recordsToMark.length - 20} more records to mark`);
  }

  console.log('\n═'.repeat(80));
}

async function main() {
  try {
    console.log(`\n🚀 NocoDB Duplicate Marker`);
    console.log(`   Mode: ${DRY_RUN ? '🔍 DRY RUN (no changes will be made)' : '✏️  LIVE UPDATE'}\n`);

    const records = await fetchAllRecords();
    console.log(`✅ Fetched ${records.length} total records\n`);

    const { recordsToMark, protectedRecords } = findDuplicatesToMark(records);

    displayPreview(recordsToMark, protectedRecords);

    if (recordsToMark.length === 0) {
      console.log('\n✨ No duplicates found! Your data is clean.\n');
      return;
    }

    if (DRY_RUN) {
      console.log('\n💡 This was a DRY RUN. To actually mark duplicates:');
      console.log('   1. Open this script');
      console.log('   2. Change: const DRY_RUN = true; to const DRY_RUN = false;');
      console.log('   3. Run again: node mark_duplicates.js\n');
    } else {
      await markDuplicates(recordsToMark);
    }

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();
