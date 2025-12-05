# Envio.dev Indexer Setup Guide 📊

## Overview

Set up an Envio.dev indexer to monitor and query `PriceUpdate` events from your deployed PegMonitor contract.

**Prerequisites**: 
- ✅ Contract deployed: `0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750`
- ⏳ Chainlink Automation set up (wait for first events to be emitted)

---

## 📋 Your Contract Details

```yaml
Contract Address: 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750
Network: Sepolia (Chain ID: 11155111)
Starting Block: 9766160
Event: PriceUpdate(uint256 indexed timestamp, int256 price, bool isPegged)
```

---

## 🚀 Step 1: Sign Up for Envio.dev

1. Go to: https://envio.dev/
2. Click **"Get Started"** or **"Sign Up"**
3. Sign up with:
   - GitHub (recommended)
   - Email
   - Wallet

---

## 🔧 Step 2: Install Envio CLI

```bash
# Install Envio CLI
npm install -g envio

# Or using pnpm
pnpm add -g envio

# Verify installation
envio --version
```

---

## 📦 Step 3: Initialize Indexer Project

```bash
# Create new directory for indexer
cd /Users/linumlabs/USDC-Ped-monitor
mkdir envio-indexer
cd envio-indexer

# Initialize Envio indexer
envio init

# When prompted:
# - Project name: usdc-peg-monitor
# - Template: EVM
# - Language: TypeScript (recommended)
```

---

## ⚙️ Step 4: Configure config.yaml

Create or edit `config.yaml`:

```yaml
name: usdc-peg-monitor
description: Indexes USDC peg monitoring events from PegMonitor contract
networks:
  - id: 11155111  # Sepolia
    start_block: 9766160  # Your deployment block
    contracts:
      - name: PegMonitor
        address: "0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750"
        abi_file_path: ./abis/PegMonitor.json
        handler: ./src/EventHandlers.ts
        events:
          - event: PriceUpdate(uint256 indexed timestamp, int256 price, bool isPegged)
            required_entities: []

# Database (PostgreSQL)
database:
  type: postgres
```

---

## 📄 Step 5: Add Contract ABI

Create `abis/PegMonitor.json`:

```json
[
  {
    "anonymous": false,
    "inputs": [
      {
        "indexed": true,
        "internalType": "uint256",
        "name": "timestamp",
        "type": "uint256"
      },
      {
        "indexed": false,
        "internalType": "int256",
        "name": "price",
        "type": "int256"
      },
      {
        "indexed": false,
        "internalType": "bool",
        "name": "isPegged",
        "type": "bool"
      }
    ],
    "name": "PriceUpdate",
    "type": "event"
  }
]
```

Or get the full ABI from Etherscan:
```bash
# Using cast
cast abi 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750 \
    --rpc-url $SEPOLIA_RPC_URL > abis/PegMonitor.json
```

---

## 🗄️ Step 6: Define Schema (schema.graphql)

Create `schema.graphql`:

```graphql
type PriceCheck @entity {
  id: ID!
  timestamp: BigInt!
  price: BigInt!
  priceFormatted: String!  # Price in dollars (e.g., "1.00")
  isPegged: Boolean!
  blockNumber: BigInt!
  transactionHash: String!
  createdAt: BigInt!
}

type PegStats @entity {
  id: ID!  # Will be "stats"
  totalChecks: BigInt!
  peggedCount: BigInt!
  unpeggedCount: BigInt!
  lastCheckTimestamp: BigInt!
  lastPrice: BigInt!
  lastPriceFormatted: String!
}
```

---

## 🔨 Step 7: Create Event Handlers

Create `src/EventHandlers.ts`:

```typescript
import {
  PegMonitor_PriceUpdate_event,
  PegMonitor_PriceUpdate_eventArgs,
} from "../generated/src/Handlers.gen";

import { PriceCheck, PegStats } from "../generated/src/Types.gen";

// Helper to format price (8 decimals to USD)
function formatPrice(price: bigint): string {
  const priceNum = Number(price) / 100000000;
  return priceNum.toFixed(8);
}

// Handler for PriceUpdate event
export async function handlePriceUpdate(
  event: PegMonitor_PriceUpdate_event
): Promise<void> {
  const { timestamp, price, isPegged } = event.params;

  // Create unique ID from tx hash and log index
  const id = `${event.transaction.hash}-${event.logIndex}`;

  // Create PriceCheck entity
  const priceCheck: PriceCheck = {
    id,
    timestamp: timestamp,
    price: price,
    priceFormatted: formatPrice(price),
    isPegged: isPegged,
    blockNumber: BigInt(event.block.number),
    transactionHash: event.transaction.hash,
    createdAt: BigInt(event.block.timestamp),
  };

  // Save price check
  await PriceCheck.set(priceCheck);

  // Update or create stats
  const statsId = "stats";
  let stats = await PegStats.get(statsId);

  if (!stats) {
    // First check - initialize stats
    stats = {
      id: statsId,
      totalChecks: BigInt(1),
      peggedCount: isPegged ? BigInt(1) : BigInt(0),
      unpeggedCount: isPegged ? BigInt(0) : BigInt(1),
      lastCheckTimestamp: timestamp,
      lastPrice: price,
      lastPriceFormatted: formatPrice(price),
    };
  } else {
    // Update existing stats
    stats.totalChecks = stats.totalChecks + BigInt(1);
    
    if (isPegged) {
      stats.peggedCount = stats.peggedCount + BigInt(1);
    } else {
      stats.unpeggedCount = stats.unpeggedCount + BigInt(1);
    }
    
    stats.lastCheckTimestamp = timestamp;
    stats.lastPrice = price;
    stats.lastPriceFormatted = formatPrice(price);
  }

  // Save stats
  await PegStats.set(stats);
}
```

---

## 🏗️ Step 8: Generate Code

```bash
# Generate TypeScript types and handlers
envio codegen

# This creates:
# - generated/src/Types.gen.ts (entity types)
# - generated/src/Handlers.gen.ts (event types)
```

---

## 🚀 Step 9: Run the Indexer

### Local Development

```bash
# Start PostgreSQL (if not running)
# Using Docker:
docker run --name envio-postgres \
  -e POSTGRES_PASSWORD=postgres \
  -e POSTGRES_DB=envio \
  -p 5432:5432 \
  -d postgres:15

# Run indexer locally
envio dev

# This will:
# - Start indexing from block 9766160
# - Process all PriceUpdate events
# - Start GraphQL server at http://localhost:8080
```

### Deploy to Envio Cloud (Production)

```bash
# Deploy to Envio hosted service
envio deploy

# Follow prompts:
# - Confirm project name
# - Confirm network (Sepolia)
# - Confirm start block

# You'll get a hosted GraphQL endpoint like:
# https://indexer.envio.dev/YOUR_PROJECT_ID/graphql
```

---

## 📊 Step 10: GraphQL Queries

### Query: Get Last 10 Price Checks

```graphql
query GetRecentPriceChecks {
  priceChecks(
    orderBy: timestamp
    orderDirection: desc
    first: 10
  ) {
    id
    timestamp
    price
    priceFormatted
    isPegged
    blockNumber
    transactionHash
    createdAt
  }
}
```

### Query: Get Overall Stats

```graphql
query GetPegStats {
  pegStats(id: "stats") {
    totalChecks
    peggedCount
    unpeggedCount
    lastCheckTimestamp
    lastPrice
    lastPriceFormatted
  }
}
```

### Query: Get Only Unpegged Events

```graphql
query GetUnpeggedEvents {
  priceChecks(
    where: { isPegged: false }
    orderBy: timestamp
    orderDirection: desc
    first: 10
  ) {
    timestamp
    priceFormatted
    isPegged
    transactionHash
  }
}
```

### Query: Get Price Checks in Time Range

```graphql
query GetPriceChecksByTimeRange {
  priceChecks(
    where: {
      timestamp_gte: "1701648000"  # Start time
      timestamp_lte: "1701734400"  # End time
    }
    orderBy: timestamp
    orderDirection: asc
  ) {
    timestamp
    priceFormatted
    isPegged
  }
}
```

### Query: Count Pegged vs Unpegged

```graphql
query GetPeggedCounts {
  peggedChecks: priceChecks(
    where: { isPegged: true }
  ) {
    id
  }
  
  unpeggedChecks: priceChecks(
    where: { isPegged: false }
  ) {
    id
  }
}
```

---

## 🧪 Step 11: Test Your Queries

### Using GraphQL Playground

Once indexer is running:

1. Open: http://localhost:8080 (local) or your hosted URL
2. Use the GraphQL Playground
3. Run the queries above

### Using curl

```bash
# Get last 10 price checks
curl -X POST http://localhost:8080/graphql \
  -H "Content-Type: application/json" \
  -d '{
    "query": "{ priceChecks(orderBy: timestamp, orderDirection: desc, first: 10) { timestamp priceFormatted isPegged } }"
  }'
```

### Using JavaScript/TypeScript

```typescript
const query = `
  query {
    priceChecks(orderBy: timestamp, orderDirection: desc, first: 10) {
      timestamp
      priceFormatted
      isPegged
      transactionHash
    }
  }
`;

const response = await fetch('http://localhost:8080/graphql', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ query }),
});

const data = await response.json();
console.log(data);
```

---

## 📁 Final Project Structure

```
envio-indexer/
├── config.yaml              # Envio configuration
├── schema.graphql           # GraphQL schema
├── abis/
│   └── PegMonitor.json      # Contract ABI
├── src/
│   └── EventHandlers.ts     # Event processing logic
├── generated/               # Auto-generated code
│   └── src/
│       ├── Types.gen.ts
│       └── Handlers.gen.ts
├── package.json
└── .env                     # Database connection (local)
```

---

## 🔍 Monitoring & Debugging

### Check Indexer Status

```bash
# View logs
envio logs

# Check sync status
envio status
```

### View in Dashboard

- Envio Cloud: https://app.envio.dev/
- View indexing progress
- Monitor query performance
- View error logs

---

## 🎯 Success Checklist

- [ ] Envio CLI installed
- [ ] Indexer project initialized
- [ ] Config and schema created
- [ ] Event handlers implemented
- [ ] Code generated successfully
- [ ] Indexer running (local or deployed)
- [ ] GraphQL queries returning data
- [ ] Last 10 price checks query works

---

## 📚 Resources

- [Envio Documentation](https://docs.envio.dev/)
- [GraphQL Queries](https://docs.envio.dev/docs/query-api)
- [Event Handlers](https://docs.envio.dev/docs/event-handlers)
- [Envio Examples](https://github.com/enviodev/examples)

---

## 🎉 You're Done!

Once complete, you'll have:
- ✅ Real-time USDC peg monitoring on Sepolia
- ✅ Chainlink Automation calling every 5 minutes
- ✅ Events indexed and queryable via GraphQL
- ✅ Historical price data for analysis

Perfect for building a dashboard or monitoring UI! 🚀

