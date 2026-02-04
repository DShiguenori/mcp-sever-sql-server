# SQL MCP Server

A Model Context Protocol (MCP) server that exposes SQL Server data to AI agents. Built with [Data API Builder](https://learn.microsoft.com/en-us/azure/data-api-builder/) and designed to be consumed by clients like Discord bots or VS Code.

## Prerequisites

- **.NET 9+** — [Download](https://dotnet.microsoft.com/download)
- **Data API Builder CLI** — Install with:
  ```bash
  dotnet tool install microsoft.dataapibuilder --prerelease --global
  ```
- **SQL Server** — LocalDB, Docker, or SQL Server Express

### Optional: Add DAB to your PATH

If `dab` is not found after installation:

```bash
export PATH="$PATH:$HOME/.dotnet/tools"
export DOTNET_ROOT=$HOME/.dotnet   # Required on some systems
```

Add these lines to your shell profile (`~/.zshrc` or `~/.bashrc`) for persistence.

---

## Quick Start

### 1. Clone the repository

```bash
git clone https://github.com/DShiguenori/mcp-sever-sql-server.git
cd mcp-sever-sql-server
```

### 2. Run SQL Server (Docker)

Start SQL Server in a container:

```bash
docker run -e "ACCEPT_EULA=Y" -e "MSSQL_SA_PASSWORD=YourStrong@Passw0rd" \
  -p 1433:1433 --name sql-products --platform linux/amd64 -d \
  mcr.microsoft.com/mssql/server:2022-latest
```

Wait ~15 seconds for SQL Server to start, then create the database:

```bash
docker cp scripts/init-db.sql sql-products:/tmp/init-db.sql
docker exec sql-products /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa \
  -P 'YourStrong@Passw0rd' -C -i /tmp/init-db.sql
```

### 3. Configure environment

Copy the example env file and set your connection string:

```bash
cp .env.example .env
```

Edit `.env` and ensure `MSSQL_CONNECTION_STRING` matches your SQL Server:

```
MSSQL_CONNECTION_STRING=Server=localhost,1433;Database=ProductsDb;User Id=sa;Password=YourStrong@Passw0rd;TrustServerCertificate=True;
```

> **Security:** Never commit `.env` to version control. It is already in `.gitignore`.

### 4. Start the MCP server

```bash
dab start --config dab-config.json
```

The server listens on:
- **MCP endpoint:** http://localhost:5000/mcp
- **REST API:** http://localhost:5000/api
- **GraphQL:** http://localhost:5000/graphql

### 5. Connect from your IDE

**VS Code:**
1. Open this project folder in VS Code.
2. Press `Cmd+Shift+P` (macOS) or `Ctrl+Shift+P` (Windows/Linux).
3. Run **MCP: List Servers**.
4. Select **sql-mcp-server** and choose **Start**.

**Cursor:**
1. Open this project folder in Cursor.
2. Ensure the DAB server is running (`dab start --config dab-config.json`).
3. The `.cursor/mcp.json` file is preconfigured — Cursor will detect **sql-mcp-server** automatically.
4. In chat, the AI can use the SQL MCP tools to query your database. Try: *"Which products have stock under 50?"*

---

## Project structure

```
├── README.md           # This file
├── plan.md             # Project plan and phases
├── dab-config.json     # Data API Builder / MCP configuration
├── .env.example        # Template for connection string (no secrets)
├── .gitignore
├── scripts/
│   └── init-db.sql     # Database creation and seed script
├── .cursor/
│   └── mcp.json        # Cursor MCP server definition
└── .vscode/
    └── mcp.json        # VS Code MCP server definition
```

---

## API endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/Products` | List all products |
| `GET /api/Products/{id}` | Get product by ID |
| `POST /api/Products` | Create product (if write permissions enabled) |

---

## SQL Server container commands

```bash
# Stop
docker stop sql-products

# Start (after stopping)
docker start sql-products

# Remove (data is lost)
docker rm -f sql-products
```

---

---

## Phase 2: Deploy to Azure (Optional)

To host the MCP server on Azure Container Apps:

1. Install Azure CLI: `brew install azure-cli`
2. Sign in: `az login` and `az account set --subscription "<id>"`
3. Set a strong password: `export SQL_PASSWORD='YourStrong@Passw0rd'`
4. Run: `./scripts/deploy-azure.sh`

See [plan.md](plan.md) for full Phase 2 details.

---

## References

- [SQL MCP Server Overview](https://learn.microsoft.com/en-us/azure/data-api-builder/mcp/overview)
- [Data API Builder Documentation](https://learn.microsoft.com/en-us/azure/data-api-builder/)
- [Model Context Protocol](https://modelcontextprotocol.io/)
