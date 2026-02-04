import type { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerDescribeEntities } from "./describe-entities.js";
import { registerReadRecords } from "./read-records.js";

export function registerTools(server: McpServer): void {
  server.registerTool(
    "ping",
    {
      description: "Placeholder tool to verify the server is running",
      inputSchema: {},
    },
    async (_args, _extra) => ({
      content: [{ type: "text", text: "AudioControl MCP Server is running." }],
    })
  );

  registerDescribeEntities(server);
  registerReadRecords(server);
}
