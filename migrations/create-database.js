/**
 * Database Creation Script
 * Creates the mktgogo database if it doesn't exist
 */

const { Client } = require('pg');

async function createDatabase() {
  // Connect to postgres database to create our target database
  const client = new Client({
    host: 'localhost',
    port: 5432,
    user: 'postgres',
    password: '789214',
    database: 'postgres'
  });

  try {
    await client.connect();
    console.log('Connected to PostgreSQL');

    // Check if database exists
    const result = await client.query(
      "SELECT 1 FROM pg_database WHERE datname = 'mktgogo'"
    );

    if (result.rows.length === 0) {
      console.log('Creating database mktgogo...');
      await client.query('CREATE DATABASE mktgogo');
      console.log('✓ Database mktgogo created successfully');
    } else {
      console.log('Database mktgogo already exists');
    }
  } catch (error) {
    console.error('Failed to create database:', error.message);
    process.exit(1);
  } finally {
    await client.end();
  }
}

createDatabase();
