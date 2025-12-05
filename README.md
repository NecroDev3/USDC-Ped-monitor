# USDC Peg Monitor 📊

A real-time monitoring system for USDC/USD price stability using **Chainlink Data Feeds** and **Chainlink Automation** on Ethereum Sepolia testnet.

![Solidity](https://img.shields.io/badge/Solidity-0.8.25-blue)
![Foundry](https://img.shields.io/badge/Foundry-Latest-orange)
![Chainlink](https://img.shields.io/badge/Chainlink-Automated-blue)
![Tests](https://img.shields.io/badge/Tests-22%2F22%20Passing-green)

---

## 🎯 Project Overview

This project monitors the USDC stablecoin's peg to the US Dollar by:
- Fetching real-time USDC/USD prices from Chainlink oracles
- Checking if the price stays within the stable range ($0.99 - $1.01)
- Automatically recording price checks every 5 minutes via Chainlink Automation
- Emitting events for indexing and analysis

### Live Deployment

- **Network**: Ethereum Sepolia Testnet
- **Contract Address**: [`0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750`](https://sepolia.etherscan.io/address/0x80bf808902d4dabeddbdd9edadfed3064aa0b750)
- **Deployment Block**: 9766160
- **Status**: ✅ Verified & Operational
- **Chainlink Automation**: [View Upkeep](https://automation.chain.link/sepolia/96972436388670139943534231169140193743831575507702730398177253526836197323642)

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    USDC Peg Monitor System                  │
└─────────────────────────────────────────────────────────────┘
                              │
                              │
        ┌─────────────────────┼─────────────────────┐
        │                     │                     │
        ▼                     ▼                     ▼
┌──────────────┐    ┌──────────────────┐    ┌──────────────┐
│  Chainlink   │    │   PegMonitor     │    │  Chainlink   │
│  Price Feed  │───▶│   Smart Contract │◀───│  Automation  │
│  (USDC/USD)  │    │                  │    │  (5 min)     │
└──────────────┘    └──────────────────┘    └──────────────┘
                              │
                              │ Emits PriceUpdate Event
                              ▼
                    ┌──────────────────┐
                    │   Envio.dev      │
                    │   Indexer        │
                    │   (GraphQL API)  │
                    └──────────────────┘
```

---

## 📋 Smart Contract Functionality

### Core Features

#### 1. **Real-Time Price Monitoring**
The contract integrates with Chainlink's USDC/USD price feed to fetch accurate, decentralized price data.

```solidity
// Chainlink Price Feed (Sepolia)
address constant PRICE_FEED = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
```

#### 2. **Peg Detection Logic**
Automatically determines if USDC is maintaining its $1.00 peg:

```solidity
// Peg boundaries (8 decimals)
int256 LOWER_BOUND = 99000000;  // $0.99
int256 UPPER_BOUND = 101000000; // $1.01

// isPegged = true if price is within $0.99 - $1.01
```

#### 3. **checkHeartbeat() Function**
The main function that:
- Fetches the latest USDC/USD price from Chainlink
- Checks if the price is within the peg range
- Emits a `PriceUpdate` event with the results

```solidity
function checkHeartbeat() external returns (int256 price, bool isPegged) {
    // Fetch price from Chainlink
    (,int256 answer,,uint256 updatedAt,) = priceFeed.latestRoundData();
    
    // Validate data
    require(answer > 0, "Invalid price data");
    require(updatedAt > 0, "Invalid timestamp");
    
    // Check peg status
    isPegged = (answer >= LOWER_BOUND && answer <= UPPER_BOUND);
    
    // Emit event for indexing
    emit PriceUpdate(block.timestamp, answer, isPegged);
    
    return (answer, isPegged);
}
```

#### 4. **Event Emission**
Every price check emits a structured event:

```solidity
event PriceUpdate(
    uint256 indexed timestamp,  // Block timestamp
    int256 price,               // USDC price (8 decimals)
    bool isPegged              // true if $0.99 ≤ price ≤ $1.01
);
```

#### 5. **Security Features**
- **OpenZeppelin Ownable**: Industry-standard access control
- **Input Validation**: All critical inputs validated
- **Price Validation**: Ensures positive, reasonable prices
- **Immutable Constants**: Peg bounds and decimals

### Additional Functions

```solidity
// View latest price without gas cost
function getLatestPrice() external view returns (
    int256 price,
    bool isPegged,
    uint256 updatedAt
);

// Get peg boundaries
function getPegBounds() external pure returns (
    int256 lowerBound,
    int256 upperBound
);

// Owner management (OpenZeppelin)
function transferOwnership(address newOwner) external;
function renounceOwnership() external;
```

---

## 🚀 Deployment Process

### Prerequisites Setup

#### 1. **Development Environment**
```bash
# Install Foundry (Ethereum development toolkit)
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Clone repository
git clone <repository-url>
cd USDC-Ped-monitor/peg-monitor

# Install dependencies
forge install
```

#### 2. **Getting Test Tokens**

##### Sepolia ETH (for gas)
We used the Sepolia faucet to get testnet ETH:

1. **Faucet**: [https://sepoliafaucet.com](https://sepoliafaucet.com)
2. **Amount**: 0.01 ETH
3. **Purpose**: Pay for deployment gas and transaction fees
4. **Wallet**: `0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1`

**Why needed**: Every transaction on Ethereum requires gas fees, even on testnet.

##### Sepolia LINK (for Chainlink Automation)
We got LINK tokens from the Chainlink faucet:

1. **Faucet**: [https://faucets.chain.link/sepolia](https://faucets.chain.link/sepolia)
2. **Amount**: 10 LINK
3. **Purpose**: Fund Chainlink Automation upkeep
4. **Cost**: 5-10 LINK covers thousands of automated calls

**Why needed**: Chainlink Automation requires LINK tokens to pay for the automated function calls.

### Contract Deployment

#### 1. **Environment Configuration**
```bash
# Set up RPC URL (Alchemy)
export SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/..."

# Set up Etherscan API key (for verification)
export ETHERSCAN_API_KEY="NYWPMSV9929VIRQNWN1J63XA167HWT1FXF"
```

#### 2. **Build & Test**
```bash
# Compile contracts
forge build

# Run test suite (22 tests)
forge test --offline

# Results: ✅ 22/22 tests passing
```

#### 3. **Deploy to Sepolia**
```bash
# Deploy using Foundry wallet (secure!)
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --chain sepolia \
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    --verify \
    --etherscan-api-key $ETHERSCAN_API_KEY \
    -vvvv
```

#### 4. **Deployment Results**

**Transaction Hash**: [`0xcdac5c7f9c9d0acaae666bfc165b43ea6292184a3a0474a2cd22bd3354c64f1d`](https://sepolia.etherscan.io/tx/0xcdac5c7f9c9d0acaae666bfc165b43ea6292184a3a0474a2cd22bd3354c64f1d)

```
✅ Contract deployed: 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750
✅ Block: 9766160
✅ Gas used: 796,216
✅ Cost: 0.000000838116070784 ETH (~$0.002 USD)
✅ Status: Verified on Etherscan
```

**Why verification matters**: Verified contracts show their source code on Etherscan, enabling transparency and easier integration with tools like Chainlink Automation.

---

## 🤖 Chainlink Automation Setup

### What is Chainlink Automation?

Chainlink Automation is a decentralized automation service that reliably executes smart contract functions on a schedule or based on conditions. Think of it as a "cron job for blockchain."

**Benefits**:
- ✅ Decentralized and reliable
- ✅ No need to run your own server
- ✅ Pay-as-you-go with LINK tokens
- ✅ Fully auditable on-chain

### Our Automation Configuration

#### Upkeep Details

**Live Dashboard**: [View on Chainlink Automation](https://automation.chain.link/sepolia/96972436388670139943534231169140193743831575507702730398177253526836197323642)

```yaml
Upkeep ID: 96972436388670139943534231169140193743831575507702730398177253526836197323642
Network: Ethereum Sepolia
Contract: 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750
Function: checkHeartbeat()
Trigger Type: Time-based
Schedule: Every 5 minutes
Gas Limit: 200,000
Status: ✅ Active
```

#### Time-Based Trigger Configuration

**Cron Expression**: `*/5 * * * *`

**Breakdown**:
- `*/5` = Every 5 minutes
- `*` = Every hour (all hours)
- `*` = Every day (all days)
- `*` = Every month (all months)
- `*` = Every day of week (all weekdays)

**Visual Schedule**:
```
Time    | Action
--------|------------------
00:00   | ✅ checkHeartbeat() called
00:05   | ✅ checkHeartbeat() called
00:10   | ✅ checkHeartbeat() called
00:15   | ✅ checkHeartbeat() called
...     | (continues 24/7)
```

### How the 5-Minute Heartbeat Works

#### Step-by-Step Flow

```
┌─────────────────────────────────────────────────────────┐
│  Every 5 Minutes (Automated by Chainlink)               │
└─────────────────────────────────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 1. Chainlink Automation Node  │
        │    Checks: "Is it time?"      │
        │    → Yes! 5 minutes passed    │
        └───────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 2. Execute Transaction        │
        │    → Call checkHeartbeat()    │
        │    → Pay gas with LINK        │
        └───────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 3. PegMonitor Contract        │
        │    → Fetch USDC/USD price     │
        │    → Check peg ($0.99-$1.01)  │
        │    → Emit PriceUpdate event   │
        └───────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 4. Event Published On-Chain   │
        │    timestamp: 1701648123      │
        │    price: 100000000 ($1.00)   │
        │    isPegged: true ✅          │
        └───────────────────────────────┘
                        │
                        ▼
        ┌───────────────────────────────┐
        │ 5. Visible on Blockchain      │
        │    → Etherscan shows event    │
        │    → Indexers pick it up      │
        │    → Data available via API   │
        └───────────────────────────────┘
```

#### Real Example

**Setup Transaction**: [`0xa474dce5727b05086fbe1b1db7e6f07f270a184cd00ec68b20adb5209f4dc71c`](https://sepolia.etherscan.io/tx/0xa474dce5727b05086fbe1b1db7e6f07f270a184cd00ec68b20adb5209f4dc71c)

This transaction registered our upkeep with Chainlink Automation, configuring:
- Target contract address
- Function to call (`checkHeartbeat()`)
- Time schedule (every 5 minutes)
- Gas limit (200,000)
- Initial LINK funding

**First Heartbeat**: [`0x43c212401c51228f963bb203636dd8e2c90553804da52e30403fc3899b16bc0b`](https://sepolia.etherscan.io/tx/0x43c212401c51228f963bb203636dd8e2c90553804da52e30403fc3899b16bc0b)

This was the first automated execution by Chainlink, which:
- Called `checkHeartbeat()` at the scheduled time
- Fetched USDC/USD price from Chainlink oracle
- Determined peg status
- Emitted `PriceUpdate` event
- All automated—no manual intervention needed!

### Monitoring the Heartbeat

#### 1. **Chainlink Automation Dashboard**

Visit: [https://automation.chain.link/sepolia/96972436388670139943534231169140193743831575507702730398177253526836197323642](https://automation.chain.link/sepolia/96972436388670139943534231169140193743831575507702730398177253526836197323642)

**What you can see**:
- ✅ Upkeep status (Active/Paused)
- ✅ Execution history (all heartbeats)
- ✅ LINK balance remaining
- ✅ Gas used per execution
- ✅ Next scheduled execution time
- ✅ Success/failure logs

#### 2. **Etherscan Events**

View all emitted events: [Contract Events](https://sepolia.etherscan.io/address/0x80bf808902d4dabeddbdd9edadfed3064aa0b750#events)

Every 5 minutes, you'll see a new `PriceUpdate` event with:
- **timestamp**: When the check happened
- **price**: USDC/USD price (8 decimals)
- **isPegged**: Whether USDC is stable

#### 3. **Command Line Monitoring**

```bash
# Watch for new events (run continuously)
cast logs \
    --address 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750 \
    --from-block latest \
    "PriceUpdate(uint256,int256,bool)" \
    --rpc-url $SEPOLIA_RPC_URL \
    --subscribe

# Get latest 10 events
cast logs \
    --address 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750 \
    "PriceUpdate(uint256,int256,bool)" \
    --rpc-url $SEPOLIA_RPC_URL \
    | tail -10
```

### Cost Analysis

#### Gas Costs per Heartbeat
- **Gas used**: ~30,000 per execution
- **Sepolia gas price**: ~0.001 gwei (essentially free)
- **Cost in ETH**: ~0.00000003 ETH per execution

#### LINK Costs
- **LINK per execution**: ~0.001 LINK
- **10 LINK funds**: ~10,000 executions
- **At 5-minute intervals**: ~35 days of continuous monitoring

**Total cost for 24/7 monitoring**: Very inexpensive on testnet, and LINK can be topped up anytime!

---

## 📊 Data & Events

### PriceUpdate Event Structure

```solidity
event PriceUpdate(
    uint256 indexed timestamp,  // Indexed for efficient filtering
    int256 price,               // USDC/USD price (8 decimals)
    bool isPegged              // true = within peg range
);
```

### Example Event Data

```json
{
  "event": "PriceUpdate",
  "timestamp": 1701648123,
  "price": 100000000,        // $1.00000000
  "isPegged": true,
  "blockNumber": 9766234,
  "transactionHash": "0x43c212...",
  "logIndex": 0
}
```

### Interpreting the Data

**Price Format**: Chainlink uses 8 decimals for USD pairs
- `100000000` = $1.00000000
- `99500000` = $0.99500000 (still pegged ✅)
- `98000000` = $0.98000000 (depegged ❌)

**isPegged Logic**:
- `true`: Price is between $0.99 and $1.01 (stable ✅)
- `false`: Price is outside range (potential issue ⚠️)

---

## 🔧 Technical Details

### Tech Stack

- **Smart Contract**: Solidity 0.8.25
- **Framework**: Foundry (forge, cast, anvil)
- **Access Control**: OpenZeppelin Ownable v5.0.0
- **Oracle**: Chainlink Price Feeds
- **Automation**: Chainlink Automation (Keeper Network)
- **Network**: Ethereum Sepolia Testnet
- **Testing**: Foundry Test Suite (22 tests)

### Dependencies

```toml
[dependencies]
forge-std = "1.8.1"
openzeppelin-contracts = "5.0.0"
chainlink-brownie-contracts = "1.1.1"
```

### Contract Statistics

- **Solidity Version**: 0.8.25
- **License**: MIT
- **Contract Size**: 131 lines
- **Test Coverage**: 22 tests, 100% pass rate
- **Gas Efficiency**: ~30,000 gas per heartbeat
- **Security**: OpenZeppelin audited components

---

## 🧪 Testing

### Test Suite Overview

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test test_CheckHeartbeat
```

### Test Results

```
Ran 22 tests for test/PegMonitor.t.sol:PegMonitorTest
✅ 22 passed; 0 failed; 0 skipped

Test Categories:
├── Constructor Tests (2)
├── Core Functionality (3)  
├── Peg Detection (7)
├── Access Control (7)
└── Utility Tests (3)
```

### Key Tests

- ✅ Price fetching from Chainlink
- ✅ Peg detection at boundaries ($0.99, $1.00, $1.01)
- ✅ Event emission verification
- ✅ OpenZeppelin Ownable integration
- ✅ Input validation and error handling

---

## 🎯 Next Steps: Envio.dev Indexer

The next phase involves setting up an indexer to make the event data easily queryable:

### 1. **Install Envio CLI**
```bash
npm install -g envio
```

### 2. **Create Indexer Project**
Configure to monitor contract `0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750` starting from block 9766160.

### 3. **Define GraphQL Schema**
Create entities for `PriceCheck` and `PegStats`.

### 4. **Query Last 10 Price Checks**
```graphql
query GetLast10Checks {
  priceChecks(
    orderBy: timestamp
    orderDirection: desc
    first: 10
  ) {
    timestamp
    priceFormatted
    isPegged
  }
}
```

📚 **Full Guide**: See `ENVIO_INDEXER_SETUP.md` for complete instructions.

---

## 📚 Project Structure

```
USDC-Ped-monitor/
├── peg-monitor/
│   ├── src/
│   │   └── PegMonitor.sol              # Main contract
│   ├── script/
│   │   └── DeployPegMonitor.s.sol      # Deployment script
│   ├── test/
│   │   ├── PegMonitor.t.sol            # Test suite
│   │   └── mocks/
│   │       └── MockAggregatorV3.sol    # Mock Chainlink feed
│   ├── lib/
│   │   ├── forge-std/                  # Foundry std lib
│   │   ├── openzeppelin-contracts/     # OpenZeppelin v5
│   │   └── chainlink-brownie-contracts/ # Chainlink contracts
│   ├── CHAINLINK_AUTOMATION_SETUP.md   # Automation guide
│   ├── ENVIO_INDEXER_SETUP.md          # Indexer guide
│   ├── CONTRACT_SUMMARY.md             # Technical details
│   └── DEPLOYMENT.md                   # Deploy instructions
└── README.md                           # This file
```

---

## 🔗 Important Links

### Live Contract
- **Etherscan**: [0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750](https://sepolia.etherscan.io/address/0x80bf808902d4dabeddbdd9edadfed3064aa0b750)
- **Contract Events**: [View Events](https://sepolia.etherscan.io/address/0x80bf808902d4dabeddbdd9edadfed3064aa0b750#events)

### Transactions
- **Deployment**: [0xcdac5c7f9c9d0acaae666bfc165b43ea6292184a3a0474a2cd22bd3354c64f1d](https://sepolia.etherscan.io/tx/0xcdac5c7f9c9d0acaae666bfc165b43ea6292184a3a0474a2cd22bd3354c64f1d)
- **Automation Setup**: [0xa474dce5727b05086fbe1b1db7e6f07f270a184cd00ec68b20adb5209f4dc71c](https://sepolia.etherscan.io/tx/0xa474dce5727b05086fbe1b1db7e6f07f270a184cd00ec68b20adb5209f4dc71c)
- **First Heartbeat**: [0x43c212401c51228f963bb203636dd8e2c90553804da52e30403fc3899b16bc0b](https://sepolia.etherscan.io/tx/0x43c212401c51228f963bb203636dd8e2c90553804da52e30403fc3899b16bc0b)

### Chainlink
- **Automation Upkeep**: [View Dashboard](https://automation.chain.link/sepolia/96972436388670139943534231169140193743831575507702730398177253526836197323642)
- **Price Feed**: [USDC/USD Sepolia](https://sepolia.etherscan.io/address/0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E)

### Faucets
- **Sepolia ETH**: [https://sepoliafaucet.com](https://sepoliafaucet.com)
- **Sepolia LINK**: [https://faucets.chain.link/sepolia](https://faucets.chain.link/sepolia)

### Documentation
- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)
- [Chainlink Automation](https://docs.chain.link/chainlink-automation/introduction)
- [Foundry Book](https://book.getfoundry.sh/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts/5.x/)

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

---

## 📄 License

This project is licensed under the MIT License.

---

## ⚠️ Disclaimer

This is a **testnet project** for educational and monitoring purposes only. Always audit smart contracts before deploying to mainnet.

---

## 🎉 Project Status

```
┌──────────────────────────────────────┐
│   USDC Peg Monitor - Status          │
├──────────────────────────────────────┤
│                                      │
│ ✅ Smart Contract      [DEPLOYED]   │
│ ✅ Testing             [COMPLETE]   │
│ ✅ Verification        [COMPLETE]   │
│ ✅ Chainlink Automation [ACTIVE]    │
│ ✅ 5-Min Heartbeat     [RUNNING]    │
│                                      │
│ ⏳ Envio.dev Indexer   [TODO]       │
│ ⏳ GraphQL API         [TODO]       │
│                                      │
└──────────────────────────────────────┘
```

**Last Updated**: December 4, 2025

---

Made with ❤️ using Foundry, Chainlink, and OpenZeppelin
