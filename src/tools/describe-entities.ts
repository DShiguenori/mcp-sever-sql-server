import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { getPool } from "../db/index.js";

export function registerDescribeEntities(server: McpServer): void {
  server.registerTool(
    "describe_entities",
    {
      description:
        "List all tables (entities) in the AudioControl database with their columns and types. Use this first to discover available tables before querying.",
      inputSchema: {},
    },
    async (_args, _extra) => {
      try {
        const pool = await getPool();
        const result = await pool.request().query(`
          SELECT 
            t.TABLE_SCHEMA,
            t.TABLE_NAME,
            c.COLUMN_NAME,
            c.DATA_TYPE,
            c.IS_NULLABLE,
            c.CHARACTER_MAXIMUM_LENGTH
          FROM INFORMATION_SCHEMA.TABLES t
          JOIN INFORMATION_SCHEMA.COLUMNS c 
            ON t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
          WHERE t.TABLE_TYPE = 'BASE TABLE'
          ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME, c.ORDINAL_POSITION
        `);

        const rows = result.recordset as Array<{
          TABLE_SCHEMA: string;
          TABLE_NAME: string;
          COLUMN_NAME: string;
          DATA_TYPE: string;
          IS_NULLABLE: string;
          CHARACTER_MAXIMUM_LENGTH: number | null;
        }>;

        const tables = new Map<
          string,
          Array<{ name: string; type: string; nullable: string; maxLength: number | null }>
        >();

        for (const row of rows) {
          const key = `${row.TABLE_SCHEMA}.${row.TABLE_NAME}`;
          if (!tables.has(key)) {
            tables.set(key, []);
          }
          tables.get(key)!.push({
            name: row.COLUMN_NAME,
            type: row.DATA_TYPE,
            nullable: row.IS_NULLABLE,
            maxLength: row.CHARACTER_MAXIMUM_LENGTH,
          });
        }

        const output: string[] = [];
        for (const [tableName, columns] of tables) {
          output.push(`\n## ${tableName}`);
          for (const col of columns) {
            const typeStr =
              col.maxLength != null && col.maxLength > 0
                ? `${col.type}(${col.maxLength})`
                : col.type;
            output.push(`  - ${col.name}: ${typeStr} ${col.nullable === "YES" ? "(nullable)" : ""}`);
          }
        }

        return {
          content: [
            {
              type: "text",
              text: `AudioControl database entities:\n${output.join("\n")}`,
            },
          ],
        };
      } catch (error) {
        const message = error instanceof Error ? error.message : String(error);
        return {
          content: [{ type: "text", text: `Error: ${message}` }],
          isError: true,
        };
      }
    }
  );
}
