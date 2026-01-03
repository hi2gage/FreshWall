#!/usr/bin/env node

/**
 * NocoDB Duplicate Finder
 * Finds duplicate entries based on URL or phone number
 */

const API_TOKEN = 'zVmKmhAOgE2zftUAN640P6liBGfReWm7uqIoQSrw';
const BASE_URL = 'http://nocodb.nas.lan';
const TABLE_ID = 'mbpovx8z8k7wlo6'; // Extracted from your URL

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

function findDuplicates(records) {
  // Filter out records that are already marked as duplicates
  const activeRecords = records.filter(record => record.deduplicated_company === false || record.deduplicated_company === null);

  console.log(`\n🔍 Analyzing ${activeRecords.length} active records (filtered out ${records.length - activeRecords.length} already marked as duplicates)\n`);

  const urlMap = new Map();
  const phoneMap = new Map();

  // Group records by URL and phone
  activeRecords.forEach(record => {
    const url = record.url?.trim().toLowerCase();
    const phone = record.phone?.toString().trim();

    if (url && url !== '') {
      if (!urlMap.has(url)) {
        urlMap.set(url, []);
      }
      urlMap.get(url).push(record);
    }

    if (phone && phone !== '') {
      if (!phoneMap.has(phone)) {
        phoneMap.set(phone, []);
      }
      phoneMap.get(phone).push(record);
    }
  });

  // Find duplicates (groups with more than 1 record)
  const urlDuplicates = Array.from(urlMap.entries())
    .filter(([_, records]) => records.length > 1);

  const phoneDuplicates = Array.from(phoneMap.entries())
    .filter(([_, records]) => records.length > 1);

  return { urlDuplicates, phoneDuplicates };
}

function displayResults(urlDuplicates, phoneDuplicates) {
  console.log('🔍 DUPLICATE ANALYSIS RESULTS\n');
  console.log('═'.repeat(80));

  // URL Duplicates
  if (urlDuplicates.length > 0) {
    console.log(`\n🌐 URL DUPLICATES: ${urlDuplicates.length} unique URLs with duplicates\n`);

    urlDuplicates.forEach(([url, records], index) => {
      console.log(`${index + 1}. URL: ${url}`);
      console.log(`   Count: ${records.length} duplicates`);
      records.forEach((record, i) => {
        console.log(`   ${i + 1}) ID: ${record.ID} | Company: ${record.company_name || 'N/A'} | Phone: ${record.phone || 'N/A'}`);
      });
      console.log('');
    });
  } else {
    console.log('\n✅ No URL duplicates found!\n');
  }

  console.log('─'.repeat(80));

  // Phone Duplicates
  if (phoneDuplicates.length > 0) {
    console.log(`\n📞 PHONE DUPLICATES: ${phoneDuplicates.length} unique phone numbers with duplicates\n`);

    phoneDuplicates.forEach(([phone, records], index) => {
      console.log(`${index + 1}. Phone: ${phone}`);
      console.log(`   Count: ${records.length} duplicates`);
      records.forEach((record, i) => {
        console.log(`   ${i + 1}) ID: ${record.ID} | Company: ${record.company_name || 'N/A'} | URL: ${record.url || 'N/A'}`);
      });
      console.log('');
    });
  } else {
    console.log('\n✅ No phone duplicates found!\n');
  }

  console.log('═'.repeat(80));

  // Summary
  const totalUrlDupes = urlDuplicates.reduce((sum, [_, records]) => sum + records.length, 0);
  const totalPhoneDupes = phoneDuplicates.reduce((sum, [_, records]) => sum + records.length, 0);

  console.log('\n📊 SUMMARY:');
  console.log(`   Total records with duplicate URLs: ${totalUrlDupes}`);
  console.log(`   Total records with duplicate phones: ${totalPhoneDupes}`);
  console.log(`   Records to review: ${totalUrlDupes + totalPhoneDupes - urlDuplicates.length - phoneDuplicates.length}`);
  console.log('');
}

async function main() {
  try {
    const records = await fetchAllRecords();
    console.log(`✅ Fetched ${records.length} records\n`);

    const { urlDuplicates, phoneDuplicates } = findDuplicates(records);
    displayResults(urlDuplicates, phoneDuplicates);

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

main();
