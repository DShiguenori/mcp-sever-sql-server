import "dotenv/config";
import sql from "mssql";

async function main() {
  const conn = process.env.AUDIOCONTROL_CONNECTION_STRING;
  if (!conn) {
    console.error("AUDIOCONTROL_CONNECTION_STRING not set");
    process.exit(1);
  }
  const pool = await sql.connect(conn);
  const result = await pool.request()
    .input("limit", 100)
    .query("SELECT TOP (@limit) [id] FROM [dbo].[atend]");
  console.log(JSON.stringify(result.recordset, null, 2));
  await pool.close();
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
