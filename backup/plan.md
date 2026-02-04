# SQL MCP Server Learning Project — Plan

> **Purpose:** This document serves as the project plan and context reference for future development sessions. Use it to maintain continuity across new chats.

---

## Overview

A learning project to build an MCP (Model Context Protocol) server that exposes SQL Server data to AI agents. The server will eventually be accessed by a Discord bot, allowing users to query the database through natural language chat.

### Key Components

| Component | Technology | Status |
|-----------|------------|--------|
| **MCP Server** | Microsoft SQL MCP Server (Data API Builder) | Planned |
| **Database** | SQL Server (local → Azure SQL) | Planned |
| **Version Control** | GitHub | Planned |
| **Hosting** | Local → Azure Container Apps (MSDN) | Planned |
| **User Interface** | Discord Bot | Later phase |

---

## Architecture

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│  Discord User   │────▶│   Discord Bot     │────▶│   MCP Server    │
│  (chat)         │     │   (MCP Client +   │     │   (SQL tools)   │
└─────────────────┘     │   LLM/OpenAPI)   │     └────────┬────────┘
                         └────────┬─────────┘              │
                                  │                        │
                                  │                        ▼
                                  │               ┌─────────────────┐
                                  └──────────────▶│  SQL Server DB  │
                                    OpenAPI key   └─────────────────┘
```

- **MCP Server** and **Discord Bot** are separate services (not built into each other).
- **MCP Server** uses Streamable HTTP transport for remote access.
- **Discord Bot** acts as an MCP client and uses an OpenAPI key for the LLM.

---

## Phases

### Phase 1: Local Setup & GitHub ✓ Complete

**Goal:** Run SQL MCP Server locally and establish version control.

1. **Prerequisites**
   - [x] Install .NET 9+
   - [x] Install Data API Builder CLI: `dotnet tool install microsoft.dataapibuilder --prerelease`
   - [x] SQL Server access (LocalDB, Docker, or SQL Server Express)

2. **Database**
   - [x] Create sample database (e.g., `ProductsDb`)
   - [x] Create and seed tables (e.g., `Products`)

3. **MCP Server Configuration**
   - [x] Create `dab-config.json` with `dab init`
   - [x] Add entities with `dab add`
   - [x] Add field descriptions with `dab update` (optional but recommended)

4. **Run Locally**
   - [x] Start server: `dab start --config dab-config.json`
   - [x] Verify MCP endpoint: `http://localhost:5000/mcp`
   - [x] Test with VS Code (MCP: List Servers → connect to `sql-mcp-server`)

5. **GitHub**
   - [x] Initialize git repo
   - [x] Create `.gitignore` (exclude `.env`, secrets, build artifacts)
   - [x] Push to GitHub
   - [x] Document setup in README

**Reference:** [SQL MCP Server - VS Code Quickstart](https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/quickstart-visual-studio-code)

---

### Phase 2: Deploy to Azure (MSDN)

**Goal:** Host the MCP Server on Azure so it can be reached remotely (e.g., by the Discord bot).

1. **Prerequisites**
   - [ ] Azure CLI installed
   - [ ] MSDN subscription with Azure credits
   - [ ] PowerShell (for deployment script)

2. **Azure Resources**
   - [ ] Resource Group
   - [ ] Azure SQL Server + Database
   - [ ] Azure Container Registry (ACR)
   - [ ] Container Apps Environment
   - [ ] Container App (SQL MCP Server)

3. **Deployment**
   - [ ] Create `Dockerfile` (Data API Builder image + `dab-config.json`)
   - [ ] Build and push image to ACR
   - [ ] Deploy Container App with connection string as secret
   - [ ] Obtain MCP URL: `https://<app>.azurecontainerapps.io/mcp`

4. **Verification**
   - [ ] Health check: `curl https://<app>.azurecontainerapps.io/health`
   - [ ] Connect from VS Code using remote MCP URL

**Reference:** [SQL MCP Server - Azure Container Apps Quickstart](https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/quickstart-azure-container-apps)

---

### Phase 3: Discord Bot (Later)

**Goal:** Users chat with a Discord bot that uses the MCP Server to query the database.

1. **Bot Setup**
   - [ ] Create Discord application and bot
   - [ ] Implement message handler

2. **MCP Client Integration**
   - [ ] Connect to MCP Server via HTTP (Streamable HTTP transport)
   - [ ] Implement tool discovery and invocation

3. **LLM Integration**
   - [ ] Use OpenAPI key for LLM
   - [ ] Orchestrate: user message → LLM decides tools → call MCP → format response

4. **Hosting**
   - [ ] Deploy bot (Railway, Render, VPS, or Azure)

---

## Project Structure (Target)

```
LearningMCP AudioControl/
├── plan.md                 # This file
├── README.md               # Setup and usage instructions
├── dab-config.json         # Data API Builder / MCP config (local dev)
├── dab-config.azure.json   # Production config for Azure deployment
├── Dockerfile              # For Azure Container Apps deployment
├── .env.example            # Template for connection string (no secrets)
├── .gitignore
├── .cursor/mcp.json        # Cursor MCP server definition
├── .vscode/mcp.json        # VS Code MCP server definition
└── scripts/                # init-db.sql, init-db-azure.sql, deploy-azure.sh
```

---

## Security Notes

- **Never commit** `.env` or connection strings to GitHub.
- Use `@env('MSSQL_CONNECTION_STRING')` in config; store value in environment.
- For production: consider managed identity, Key Vault, and restricted permissions.

---

## Useful Commands

| Action | Command |
|--------|---------|
| Start MCP server locally | `dab start --config dab-config.json` |
| Initialize DAB config | `dab init --database-type mssql --connection-string "@env('MSSQL_CONNECTION_STRING')" --host-mode Development --config dab-config.json` |
| Add entity | `dab add <EntityName> --source dbo.<TableName> --permissions "anonymous:read" --description "..."` |
| Azure login | `az login` |
| Set subscription | `az account set --subscription "<subscription-id>"` |

---

## References

- [SQL MCP Server Overview](https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/overview)
- [SQL MCP Server - VS Code Quickstart](https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/quickstart-visual-studio-code)
- [SQL MCP Server - Azure Container Apps Quickstart](https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/quickstart-azure-container-apps)
- [Data API Builder Documentation](https://learn.microsoft.com/en-us/azure/data-api-builder/)
- [Model Context Protocol Specification](https://modelcontextprotocol.io/)

---

*Last updated: February 4, 2025*
