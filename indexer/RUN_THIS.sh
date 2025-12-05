#!/bin/bash
# Quick script to start the USDC Peg Monitor Indexer

echo "🚀 Starting USDC Peg Monitor Indexer..."
echo ""

# Navigate to indexer directory
cd "$(dirname "$0")"

echo "📁 Current directory: $(pwd)"
echo ""

# Step 1: Check if PostgreSQL is running
echo "1️⃣  Checking PostgreSQL..."
if docker ps | grep -q usdc-peg-postgres; then
    echo "   ✅ PostgreSQL is running"
else
    echo "   ⚠️  PostgreSQL not running. Starting it now..."
    docker run --name usdc-peg-postgres \
      -e POSTGRES_PASSWORD=postgres \
      -e POSTGRES_DB=envio \
      -p 5432:5432 \
      -d postgres:15 2>/dev/null || docker start usdc-peg-postgres
    echo "   ✅ PostgreSQL started"
    sleep 2
fi

echo ""

# Step 2: Generate types
echo "2️⃣  Generating TypeScript types..."
pnpx envio codegen

if [ $? -ne 0 ]; then
    echo "   ❌ Codegen failed. Check the error above."
    exit 1
fi

echo "   ✅ Types generated successfully"
echo ""

# Step 3: Start indexer
echo "3️⃣  Starting indexer..."
echo "   📊 GraphQL API will be available at: http://localhost:8080"
echo "   🔄 Syncing from block 9766160..."
echo ""
echo "   Press Ctrl+C to stop"
echo ""

pnpx envio dev

