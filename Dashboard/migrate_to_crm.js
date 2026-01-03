#!/usr/bin/env node

/**
 * Migrate Clean Leads to CRM
 * Copies deduplicated_company=false records from scrape_results to CRM table
 */

const API_TOKEN = 'zVmKmhAOgE2zftUAN640P6liBGfReWm7uqIoQSrw';
const BASE_URL = 'http://nocodb.nas.lan';
const SOURCE_TABLE_ID = 'mbpovx8z8k7wlo6'; // scrape_results
const CRM_TABLE_ID = 'mjx6wj53lvdqtur'; // CRM

// Set to true to actually migrate, false for dry run
const DRY_RUN = true;

async function fetchCleanLeads() {
  console.log('📥 Fetching clean leads from scrape_results...\n');

  let allLeads = [];
  let offset = 0;
  const limit = 100;
  let hasMore = true;

  while (hasMore) {
    const url = `${BASE_URL}/api/v2/tables/${SOURCE_TABLE_ID}/records?limit=${limit}&offset=${offset}&where=(deduplicated_company,eq,false)`;

    const response = await fetch(url, {
      headers: {
        'xc-token': API_TOKEN,
      }
    });

    if (!response.ok) {
      throw new Error(`Failed to fetch leads: ${response.status}`);
    }

    const data = await response.json();
    const records = data.list || [];
    allLeads = allLeads.concat(records);

    console.log(`   Fetched ${allLeads.length}/${data.pageInfo.totalRows} leads...`);

    hasMore = !data.pageInfo.isLastPage;
    offset += limit;
  }

  return allLeads;
}

function transformLead(scrapedLead) {
  // Map scraped data to CRM format
  return {
    company_name: scrapedLead.company_name,
    phone: scrapedLead.phone || null,
    email: scrapedLead.email || null,
    url: scrapedLead.url || null,
    rating_value: scrapedLead.rating_value || null,
    rating_count: scrapedLead.rating_count || null,
    location_name: scrapedLead.location_name || null,
    keyword: scrapedLead.keyword || null,
    user_notes: scrapedLead.user_notes || null,
    status: 'To Research', // Default status for new leads
    Priority: determinePriority(scrapedLead),
    Call_Attempts: 0,
    Last_Contact_Date: null,
    Next_Follow_up: null
  };
}

function determinePriority(lead) {
  // Auto-assign priority based on ratings
  const rating = lead.rating_value || 0;
  const reviewCount = lead.rating_count || 0;
  const hasPhone = lead.phone && lead.phone.trim() !== '';

  if (rating >= 4.5 && reviewCount >= 50 && hasPhone) {
    return 'High';
  } else if (rating >= 4.0 || (hasPhone && reviewCount >= 20)) {
    return 'Medium';
  } else {
    return 'Low';
  }
}

async function insertLeads(leads) {
  console.log(`\n${DRY_RUN ? '🔍 DRY RUN - Would insert' : '✏️  Inserting'} ${leads.length} leads into CRM...\n`);

  if (DRY_RUN) {
    // Show preview of first 5 leads
    console.log('Preview of leads to migrate:\n');
    leads.slice(0, 5).forEach((lead, i) => {
      console.log(`${i + 1}. ${lead.company_name}`);
      console.log(`   Phone: ${lead.phone || 'N/A'}`);
      console.log(`   Email: ${lead.email || 'N/A'}`);
      console.log(`   Rating: ${lead.rating_value || 'N/A'} (${lead.rating_count || 0} reviews)`);
      console.log(`   Location: ${lead.location_name || 'N/A'}`);
      console.log(`   Priority: ${lead.Priority}`);
      console.log(`   Status: ${lead.status}`);
      console.log('');
    });

    if (leads.length > 5) {
      console.log(`... and ${leads.length - 5} more leads\n`);
    }

    // Show priority breakdown
    const priorityCounts = leads.reduce((acc, lead) => {
      acc[lead.Priority] = (acc[lead.Priority] || 0) + 1;
      return acc;
    }, {});

    console.log('📊 Priority Breakdown:');
    console.log(`   High: ${priorityCounts.High || 0} leads`);
    console.log(`   Medium: ${priorityCounts.Medium || 0} leads`);
    console.log(`   Low: ${priorityCounts.Low || 0} leads`);
    console.log('');

    return;
  }

  // Insert in batches of 100
  const batchSize = 100;
  let inserted = 0;

  for (let i = 0; i < leads.length; i += batchSize) {
    const batch = leads.slice(i, i + batchSize);

    try {
      const url = `${BASE_URL}/api/v2/tables/${CRM_TABLE_ID}/records`;
      const response = await fetch(url, {
        method: 'POST',
        headers: {
          'xc-token': API_TOKEN,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(batch)
      });

      if (!response.ok) {
        const text = await response.text();
        throw new Error(`Failed to insert batch: ${response.status} - ${text}`);
      }

      inserted += batch.length;
      console.log(`   Inserted ${inserted}/${leads.length} leads...`);

    } catch (error) {
      console.error(`   ❌ Error inserting batch at offset ${i}: ${error.message}`);
      throw error;
    }
  }

  console.log(`\n✅ Successfully migrated ${inserted} leads to CRM!`);
}

async function main() {
  try {
    console.log(`\n🚀 CRM Migration Script`);
    console.log(`   Mode: ${DRY_RUN ? '🔍 DRY RUN (no changes will be made)' : '✏️  LIVE MIGRATION'}\n`);
    console.log(`   Source: scrape_results (deduplicated_company = false)`);
    console.log(`   Destination: CRM table\n`);

    const scrapedLeads = await fetchCleanLeads();
    console.log(`\n✅ Fetched ${scrapedLeads.length} clean leads\n`);

    if (scrapedLeads.length === 0) {
      console.log('No leads to migrate!');
      return;
    }

    // Transform leads to CRM format
    console.log('🔄 Transforming leads to CRM format...\n');
    const crmLeads = scrapedLeads.map(transformLead);

    await insertLeads(crmLeads);

    if (DRY_RUN) {
      console.log('\n💡 This was a DRY RUN. To actually migrate leads:');
      console.log('   1. Open this script');
      console.log('   2. Change: const DRY_RUN = true; to const DRY_RUN = false;');
      console.log('   3. Run again: node migrate_to_crm.js\n');
    } else {
      console.log('\n🎉 Migration complete! Check your CRM table.\n');
    }

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    process.exit(1);
  }
}

main();
