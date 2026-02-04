# AudioControl MCP Server — Plan

> **Purpose:** Project plan and context reference for development sessions.

---

## Overview

Build an MCP server from scratch using Node.js and TypeScript. The server connects to the **AudioControl** SQL Server database and exposes business-logic tools to AI agents (Cursor, VS Code, Discord bot).

### Key Components

| Component | Technology | Status |
|-----------|------------|--------|
| **MCP Server** | Node.js + TypeScript (@modelcontextprotocol/sdk) | Complete |
| **Database** | SQL Server (AudioControl) | Complete |
| **Version Control** | GitHub | Planned |
| **Hosting** | Local → Azure Container Apps (later) | Planned |
| **User Interface** | Discord Bot | Later phase |

---

## Phases

### Phase 1: Backup Current Project — Complete

- [x] Create `backup/` folder
- [x] Move DAB configs, Dockerfile, plan, README, scripts, .vscode to backup

### Phase 2: Initialize Node.js + TypeScript Project — Complete

- [x] Create `package.json` with dependencies
- [x] Create `tsconfig.json`
- [x] Create `src/index.ts` with MCP server skeleton
- [x] Update `.gitignore`

### Phase 3: Database Connection and Environment — Complete

- [x] Update `.env.example` with `AUDIOCONTROL_CONNECTION_STRING`
- [x] Create `src/db/connection.ts` (mssql pool, singleton)
- [x] Create `src/db/index.ts`

### Phase 4: Document Schema and Define Tools — Complete

- [x] Create `docs/schema.md` (template for user to fill)
- [x] Create `src/tools/` structure
- [x] Define tools: describe_entities, read_records, ping

### Phase 5: Implement Core Tools — Complete

- [x] Implement `describe_entities` (list tables/columns)
- [x] Implement `read_records` (query with filters, parameterized)
- [x] Wire tools into `src/index.ts`

### Phase 6: MCP Client Configuration — Complete

- [x] Update `.cursor/mcp.json` (stdio, command-based)
- [x] Create `.vscode/mcp.json`
- [x] Test with Cursor/VS Code

### Phase 7: README and Plan — Complete

- [x] Create new `README.md`
- [x] Create new `plan.md` (this file)

---

## Phase 8: Discord Bot (Later)

**Goal:** Users chat with a Discord bot that uses the MCP Server to query the database.

1. Bot Setup — Create Discord application and bot
2. MCP Client Integration — Connect via HTTP (Streamable HTTP transport)
3. LLM Integration — Orchestrate user message → LLM → MCP tools → response
4. Hosting — Deploy bot (Railway, Render, VPS, or Azure)

---

## Phase 9: Deploy to Azure (Later)

**Goal:** Host the MCP Server on Azure for remote access.

1. Create Dockerfile for Node.js server
2. Azure Container Apps deployment
3. Obtain MCP URL for remote clients

---

## Security Notes

- Never commit `.env` or connection strings to GitHub
- Use parameterized queries for all user input
- Consider read-only DB user for query-only tools
- For production: managed identity, Key Vault, restricted permissions

---

## References

- [MCP SDK - TypeScript](https://github.com/modelcontextprotocol/typescript-sdk)
- [Build an MCP Server](https://modelcontextprotocol.io/docs/develop/build-server)
- [mssql npm package](https://www.npmjs.com/package/mssql)

---

*Last updated: February 4, 2025*
