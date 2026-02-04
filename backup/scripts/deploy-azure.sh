#!/bin/bash
# Phase 2: Deploy SQL MCP Server to Azure Container Apps
# Prerequisites: az login, Azure subscription, Azure CLI, Docker
#
# Usage:
#   1. az login
#   2. az account set --subscription "<subscription-id>"
#   3. Edit variables below (RESOURCE_GROUP, LOCATION, SQL_PASSWORD)
#   4. ./scripts/deploy-azure.sh

set -e

# === Variables - EDIT THESE ===
RESOURCE_GROUP="${RESOURCE_GROUP:-rg-sql-mcp}"
LOCATION="${LOCATION:-eastus}"
SQL_SERVER="sql-mcp-$(shuf -i 1000-9999 -n 1)"
SQL_DATABASE="ProductsDb"
SQL_ADMIN="sqladmin"
SQL_PASSWORD="${SQL_PASSWORD:-}"  # Set via env or prompt

ACR_NAME="acrsqlmcp$(shuf -i 1000-9999 -n 1)"
CONTAINERAPP_ENV="sql-mcp-env"
CONTAINERAPP_NAME="sql-mcp-server"

# === Validate ===
if [ -z "$SQL_PASSWORD" ]; then
  echo "Error: Set SQL_PASSWORD environment variable (e.g. export SQL_PASSWORD='YourStrong@Passw0rd')"
  exit 1
fi

echo "=== Creating resource group ==="
az group create --name "$RESOURCE_GROUP" --location "$LOCATION"

echo "=== Creating Azure SQL Server ==="
az sql server create \
  --name "$SQL_SERVER" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION" \
  --admin-user "$SQL_ADMIN" \
  --admin-password "$SQL_PASSWORD"

echo "=== Configuring firewall ==="
az sql server firewall-rule create \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name AllowAzureServices \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0

# Allow current IP
MY_IP=$(curl -s https://api.ipify.org 2>/dev/null || echo "0.0.0.0")
az sql server firewall-rule create \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name AllowMyIP \
  --start-ip-address "$MY_IP" \
  --end-ip-address "$MY_IP" 2>/dev/null || true

echo "=== Creating database ==="
az sql db create \
  --resource-group "$RESOURCE_GROUP" \
  --server "$SQL_SERVER" \
  --name "$SQL_DATABASE" \
  --service-objective S0

CONNECTION_STRING="Server=tcp:${SQL_SERVER}.database.windows.net,1433;Database=${SQL_DATABASE};User ID=${SQL_ADMIN};Password=${SQL_PASSWORD};Encrypt=true;TrustServerCertificate=false;Connection Timeout=30;"

echo "=== Creating Products table (run init-db.sql manually if sqlcmd not available) ==="
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
if command -v sqlcmd &>/dev/null; then
  sqlcmd -S "${SQL_SERVER}.database.windows.net" -d "$SQL_DATABASE" -U "$SQL_ADMIN" -P "$SQL_PASSWORD" -I -i "$PROJECT_ROOT/scripts/init-db-azure.sql" || echo "Note: Run scripts/init-db-azure.sql manually against Azure SQL"
else
  echo "Note: Install sqlcmd and run scripts/init-db-azure.sql against Azure SQL, or use Azure Data Studio"
fi

echo "=== Creating Azure Container Registry ==="
az acr create \
  --resource-group "$RESOURCE_GROUP" \
  --name "$ACR_NAME" \
  --sku Basic \
  --admin-enabled true

echo "=== Building and pushing Docker image ==="
az acr build \
  --registry "$ACR_NAME" \
  --image sql-mcp-server:1 \
  --file "$PROJECT_ROOT/Dockerfile" \
  "$PROJECT_ROOT"

echo "=== Creating Container Apps environment ==="
az containerapp env create \
  --name "$CONTAINERAPP_ENV" \
  --resource-group "$RESOURCE_GROUP" \
  --location "$LOCATION"

echo "=== Deploying Container App ==="
ACR_LOGIN_SERVER=$(az acr show --name "$ACR_NAME" --query loginServer -o tsv)
ACR_USERNAME=$(az acr credential show --name "$ACR_NAME" --query username -o tsv)
ACR_PASSWORD=$(az acr credential show --name "$ACR_NAME" --query "passwords[0].value" -o tsv)

az containerapp create \
  --name "$CONTAINERAPP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --environment "$CONTAINERAPP_ENV" \
  --image "${ACR_LOGIN_SERVER}/sql-mcp-server:1" \
  --registry-server "$ACR_LOGIN_SERVER" \
  --registry-username "$ACR_USERNAME" \
  --registry-password "$ACR_PASSWORD" \
  --target-port 5000 \
  --ingress external \
  --min-replicas 1 \
  --max-replicas 3 \
  --secrets "mssql-connection-string=$CONNECTION_STRING" \
  --env-vars "MSSQL_CONNECTION_STRING=secretref:mssql-connection-string" \
  --cpu 0.5 \
  --memory 1.0Gi

MCP_URL=$(az containerapp show \
  --name "$CONTAINERAPP_NAME" \
  --resource-group "$RESOURCE_GROUP" \
  --query "properties.configuration.ingress.fqdn" -o tsv)

echo ""
echo "=== Deployment complete ==="
echo "MCP Server URL: https://${MCP_URL}/mcp"
echo "Health check:   https://${MCP_URL}/health"
echo ""
echo "Add to Cursor (.cursor/mcp.json):"
echo "  \"sql-mcp-server\": { \"url\": \"https://${MCP_URL}/mcp\" }"
