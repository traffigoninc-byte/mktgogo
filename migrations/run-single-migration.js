const { Pool } = require('pg');
const fs = require('fs');
const path = require('path');

async function runMigration() {
  const databaseUrl = process.env.DATABASE_URL;
  
  if (!databaseUrl) {
    console.error('DATABASE_URL environment variable not set');
    process.exit(1);
  }

  const pool = new Pool({ connectionString: databaseUrl });

  try {
    console.log('Connected to database');
    
    const migrationFile = process.argv[2];
    if (!migrationFile) {
      console.error('Please provide migration file as argument');
      process.exit(1);
    }

    const migrationPath = path.join(__dirname, migrationFile);
    const sql = fs.readFileSync(migrationPath, 'utf8');
    
    console.log(`Running ${migrationFile}...`);
    await pool.query(sql);
    console.log(`✓ Completed ${migrationFile}`);
    
  } catch (error) {
    console.error('Migration failed:', error.message);
    process.exit(1);
  } finally {
    await pool.end();
  }
}

runMigration();
