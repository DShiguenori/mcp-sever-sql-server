import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import { getPool } from "../db/index.js";

const TABLE_NAME_PATTERN = /^[a-zA-Z_][a-zA-Z0-9_]*$/;

export function registerReadRecords(server: McpServer): void {
  server.registerTool(
    "read_records",
    {
      description:
        "Read records from a table in the AudioControl database. Use describe_entities first to find available tables. Supports optional filters and limit.",
      inputSchema: {
        entity: z.string().describe("Table name (e.g. Products) or schema.table (e.g. dbo.Products)"),
        select: z
          .string()
          .optional()
          .describe("Comma-separated column names (default: all columns)"),
        filter: z
          .string()
          .optional()
          .describe("Simple filter: column=value (e.g. 'Status=active'). Only one equality filter supported."),
        limit: z.number().min(1).max(1000).optional().default(100).describe("Max rows to return (default: 100)"),
      },
    },
    async (args, _extra) => {
      try {
        const { entity, select, filter, limit } = args;

        if (!entity) {
          return {
            content: [{ type: "text", text: "Error: entity (table name) is required" }],
            isError: true,
          };
        }

        const tableName = entity.includes(".") ? entity : `dbo.${entity}`;
        const parts = tableName.split(".");
        if (!parts.every((p) => TABLE_NAME_PATTERN.test(p)) || parts.length > 2) {
          return {
            content: [{ type: "text", text: "Error: Invalid table name. Use alphanumeric and underscores only." }],
            isError: true,
          };
        }

        const quotedTable =
          parts.length === 2 ? `[${parts[0]}].[${parts[1]}]` : `[dbo].[${parts[0]}]`;

        const colPattern = /^[a-zA-Z_][a-zA-Z0-9_]*$/;
        const columns = select
          ? select
              .split(",")
              .map((c) => c.trim())
              .filter((c) => colPattern.test(c))
          : [];
        const selectClause =
          columns.length > 0 ? columns.map((c) => `[${c}]`).join(", ") : "*";

        let query = `SELECT TOP (@limit) ${selectClause} FROM ${quotedTable}`;
        const request = (await getPool()).request();
        request.input("limit", limit);

        if (filter && filter.trim()) {
          const match = filter.trim().match(/^([a-zA-Z_][a-zA-Z0-9_]*)=(.+)$/);
          if (match) {
            const [, col, val] = match;
            query += ` WHERE [${col}] = @filterVal`;
            request.input("filterVal", val.trim());
          }
        }

        const result = await request.query(query);
        const rows = result.recordset as Record<string, unknown>[];

        const formatted = JSON.stringify(rows, null, 2);
        return {
          content: [
            {
              type: "text",
              text: rows.length === 0 ? "No records found." : formatted,
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
