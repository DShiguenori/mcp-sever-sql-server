# AudioControl MCP Server

An MCP (Model Context Protocol) server built from scratch with Node.js and TypeScript. Connects to the **AudioControl** SQL Server database and exposes tools for AI agents (e.g., Cursor, VS Code, Discord bots).

## Prerequisites

- **Node.js 18+** — [Download](https://nodejs.org/)
- **SQL Server** — LocalDB, Docker, or SQL Server Express with the AudioControl database

## Quick Start

### 1. Install dependencies

```bash
npm install
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env` and set `AUDIOCONTROL_CONNECTION_STRING` to your SQL Server connection string:

```
AUDIOCONTROL_CONNECTION_STRING=Server=localhost,1433;Database=AudioControl;User Id=sa;Password=<YourPassword>;TrustServerCertificate=True;
```

> **Security:** Never commit `.env` to version control. It is already in `.gitignore`.

### 3. Start the MCP server

```bash
npm run dev
```

Or build and run:

```bash
npm run build
npm start
```

### 4. Connect from Cursor or VS Code

The project includes preconfigured MCP settings:

- **Cursor:** `.cursor/mcp.json`
- **VS Code:** `.vscode/mcp.json`

1. Open this project folder in Cursor or VS Code.
2. Run **MCP: List Servers** (Cmd+Shift+P / Ctrl+Shift+P).
3. Select **audio-control** and start the server.
4. In chat, ask questions like: *"What tables are in the AudioControl database?"* or *"Show me records from the Products table."*

## Available Tools

| Tool | Description |
|------|-------------|
| `ping` | Verify the server is running |
| `describe_entities` | List all tables and columns in the AudioControl database |
| `read_records` | Query records from a table with optional filters and limit |

## Project Structure

```
├── src/
│   ├── index.ts           # MCP server entry point
│   ├── db/
│   │   ├── connection.ts  # SQL Server connection pool
│   │   └── index.ts
│   └── tools/
│       ├── index.ts       # Tool registration
│       ├── describe-entities.ts
│       └── read-records.ts
├── docs/
│   └── schema.md          # AudioControl schema reference
├── backup/                # Previous DAB project files
├── .env.example
├── package.json
├── tsconfig.json
├── plan.md
└── README.md
```

## Scripts

| Command | Description |
|---------|-------------|
| `npm run dev` | Run server with tsx (no build) |
| `npm run build` | Compile TypeScript to `dist/` |
| `npm start` | Run compiled server from `dist/` |

## References

- [Model Context Protocol](https://modelcontextprotocol.io/)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Build an MCP Server](https://modelcontextprotocol.io/docs/develop/build-server)
