# Final Steps to Complete Indexer Setup 🚀

## ✅ What's Already Done

1. ✅ Envio project initialized
2. ✅ Dependencies installed (pnpm)
3. ✅ Contract imported from Sepolia
4. ✅ **Fixed `config.yaml`** - Set start_block to 9766160
5. ✅ **Enhanced `schema.graphql`** - Added PriceCheck and PegStats entities
6. ✅ **Enhanced `EventHandlers.ts`** - Added price formatting and statistics
7. ✅ **Created `queries.graphql`** - Ready-to-use GraphQL queries including the required "last 10" query
8. ✅ **Added `PegMonitor-abi.json`** - Correct contract ABI

---

## 🎯 What You Need to Do (3 Simple Commands)

### Step 1: Regenerate Code

```bash
cd /Users/linumlabs/USDC-Ped-monitor/indexer

# Use pnpx (since pnpm is installed via pnpx)
pnpx envio codegen
```

This will generate TypeScript types from your updated schema.

### Step 2: Start PostgreSQL

```bash
# Start PostgreSQL database
docker run --name usdc-peg-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=envio \
  -p 5432:5432 \
  -d postgres:15

# Verify it's running
docker ps | grep usdc-peg-postgres
```

### Step 3: Start the Indexer

```bash
cd /Users/linumlabs/USDC-Ped-monitor/indexer

# Start indexer in development mode
pnpx envio dev
```

**What happens:**
- 🔄 Syncs from block 9766160
- 📊 Processes all PriceUpdate events
- 🚀 Starts GraphQL server at http://localhost:8080
- ✅ Ready to query!

---

## 🧪 Step 4: Test the Required Query

Once the indexer is running (Step 3), open a new terminal:

```bash
# Test the "Last 10 Price Checks" query (THE REQUIRED QUERY!)
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ priceChecks(orderBy: \"timestamp\", orderDirection: \"desc\", limit: 10) { id timestamp priceFormatted isPegged transactionHash } }"
  }'
```

Or open browser: **http://localhost:8080** and paste this query:

```graphql
query GetLast10PriceChecks {
  priceChecks(
    orderBy: "timestamp"
    orderDirection: "desc"
    limit: 10
  ) {
    id
    timestamp
    priceFormatted
    isPegged
    blockNumber
    transactionHash
  }
}
```

---

## 📊 Expected Output

```json
{
  "data": {
    "priceChecks": [
      {
        "id": "11155111_9766234_0",
        "timestamp": "1733305245",
        "priceFormatted": "1.00000000",
        "isPegged": true,
        "blockNumber": "9766234",
        "transactionHash": "0x43c212401c51228f963bb203636dd8e2c90553804da52e30403fc3899b16bc0b"
      },
      // ... up to 10 records
    ]
  }
}
```

---

## ✅ Success Criteria

Your setup is complete when:

- [ ] `pnpx envio codegen` runs without errors
- [ ] `pnpx envio dev` starts successfully
- [ ] GraphQL Playground opens at http://localhost:8080
- [ ] **"GetLast10PriceChecks" query returns data** ✅ (Main requirement!)
- [ ] Global stats query shows totalChecks > 0
- [ ] New events appear automatically every 5 minutes

---

## 📋 What We Built

### 1. **Indexer Configuration** ✅

**File**: `config.yaml`
- ✅ Network: Sepolia (11155111)
- ✅ Start block: 9766160 (your deployment)
- ✅ Contract: 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750
- ✅ Event: PriceUpdate
- ✅ ABI: PegMonitor-abi.json

### 2. **Data Schema** ✅

**File**: `schema.graphql`

Two entity types:
- **PriceCheck**: Individual price check records
  - timestamp, price, priceFormatted, isPegged
  - blockNumber, transactionHash
  
- **PegStats**: Global statistics
  - totalChecks, peggedCount, unpeggedCount
  - lastPrice, lastPriceFormatted, lastIsPegged

### 3. **Event Handlers** ✅

**File**: `src/EventHandlers.ts`

Features:
- ✅ Formats price (8 decimals → "1.00000000")
- ✅ Creates PriceCheck entity for each event
- ✅ Updates global statistics
- ✅ Maintains pegged/unpegged counts

### 4. **GraphQL Queries** ✅

**File**: `queries.graphql`

Includes:
- ✅ **GetLast10PriceChecks** (THE REQUIRED QUERY!)
- ✅ GetGlobalStats
- ✅ GetUnpeggedEvents
- ✅ And 5 more useful queries

---

## 🎉 Requirements Met

| Requirement | Status | File |
|-------------|--------|------|
| Create indexer for deployed contract | ✅ Done | `config.yaml` |
| Monitor PriceUpdate events | ✅ Done | `config.yaml`, `EventHandlers.ts` |
| Persist event data | ✅ Done | `schema.graphql`, `EventHandlers.ts` |
| GraphQL query for last 10 records | ✅ Done | `queries.graphql` |

---

## 🐛 Troubleshooting

### "pnpx: command not found"
Run the init command again to install pnpm:
```bash
npx envio@latest init
# Select current folder (.)
```

### "Error parsing config"
Make sure `abis/PegMonitor-abi.json` exists:
```bash
ls -la abis/
```

### "Port 8080 already in use"
Kill the process using that port:
```bash
lsof -i :8080
kill -9 <PID>
```

### "Cannot connect to database"
Start PostgreSQL:
```bash
docker start usdc-peg-postgres
```

---

## 📞 Need Help?

If you get stuck, check:
1. `pnpx envio --help` - CLI documentation
2. https://docs.envio.dev/ - Full documentation
3. Run `docker ps` to verify PostgreSQL is running
4. Check `pnpx envio logs` for error messages

---

## 🎊 After This Works

Once you see data in the GraphQL playground, **you're 100% done!** 🎉

All 3 requirements will be complete:
1. ✅ Indexer created and monitoring contract
2. ✅ PriceUpdate events persisted in database
3. ✅ GraphQL query returns last 10 price check records

---

**Ready to run the 3 commands above?** Go for it! 🚀

