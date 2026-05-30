require('dotenv').config();
const { Client } = require('pg');

async function verifySchema() {
  const client = new Client({
    connectionString: process.env.DATABASE_URL
  });

  try {
    await client.connect();
    console.log('Connected to database\n');

    const tables = ['vendors', 'store_templates', 'store_configurations', 'onboarding_sessions'];
    
    console.log('Vendor Store Engine Tables:');
    for (const table of tables) {
      const result = await client.query(
        `SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name = $1`,
        [table]
      );
      if (result.rows.length > 0) {
        console.log(`  ✓ ${table}`);
      } else {
        console.log(`  ✗ ${table} (NOT FOUND)`);
      }
    }

    console.log('\nVerifying foreign key constraints:');
    const fkResult = await client.query(`
      SELECT 
        tc.table_name, 
        kcu.column_name, 
        ccu.table_name AS foreign_table_name
      FROM information_schema.table_constraints AS tc 
      JOIN information_schema.key_column_usage AS kcu
        ON tc.constraint_name = kcu.constraint_name
      JOIN information_schema.constraint_column_usage AS ccu
        ON ccu.constraint_name = tc.constraint_name
      WHERE tc.constraint_type = 'FOREIGN KEY' 
        AND tc.table_name IN ('vendors', 'store_configurations', 'onboarding_sessions')
      ORDER BY tc.table_name, kcu.column_name
    `);

    fkResult.rows.forEach(row => {
      console.log(`  ✓ ${row.table_name}.${row.column_name} → ${row.foreign_table_name}`);
    });

    console.log('\n✓ Schema verification complete');
  } catch (error) {
    console.error('Verification failed:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

verifySchema();
