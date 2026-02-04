import sql from "mssql";

let pool: sql.ConnectionPool | null = null;

export async function getPool(): Promise<sql.ConnectionPool> {
  const connectionString = process.env.AUDIOCONTROL_CONNECTION_STRING;
  if (!connectionString) {
    throw new Error(
      "AUDIOCONTROL_CONNECTION_STRING is not set. Copy .env.example to .env and configure the connection string."
    );
  }

  if (!pool) {
    pool = await sql.connect(connectionString);
  }

  return pool;
}

export async function closePool(): Promise<void> {
  if (pool) {
    await pool.close();
    pool = null;
  }
}
