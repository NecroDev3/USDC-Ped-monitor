# USDC Peg Monitor 📊

A smart contract system that monitors USDC/USD price stability using **Chainlink Data Feeds** and **Chainlink Automation**, with event indexing via **Envio.dev**.

## 🎯 Overview

The PegMonitor contract continuously monitors the USDC/USD price and detects when USDC deviates from its $1.00 peg (outside the $0.99 - $1.01 range). It uses:

- **Chainlink Price Feeds**: For reliable, decentralized USDC/USD price data
- **Chainlink Automation**: For automated periodic price checks (every 5 minutes)
- **Event Emission**: PriceUpdate events for indexing and monitoring
- **Envio.dev**: For indexing and querying historical price data (setup separately)

## 🏗️ Architecture

```
┌─────────────────────┐
│  Chainlink Oracle   │
│   (USDC/USD Feed)   │
└──────────┬──────────┘
           │
           │ Price Data
           ▼
┌─────────────────────┐
│   PegMonitor.sol    │◄──── Chainlink Automation
│                     │      (calls every 5 min)
└──────────┬──────────┘
           │
           │ PriceUpdate Event
           ▼
┌─────────────────────┐
│    Envio.dev        │
│    Indexer          │
└─────────────────────┘
           │
           │ GraphQL
           ▼
     Your Application
```

## 📋 Features

### Smart Contract (PegMonitor.sol)

✅ **checkHeartbeat()** - Main function that:
  - Fetches latest USDC/USD price from Chainlink
  - Determines if price is within peg range ($0.99 - $1.01)
  - Emits `PriceUpdate` event with timestamp, price, and isPegged status

✅ **PriceUpdate Event** - Contains:
  - `timestamp`: Block timestamp of the check
  - `price`: Raw price from Chainlink (8 decimals)
  - `isPegged`: Boolean indicating if price is within stable range

✅ **Additional Functions**:
  - `getLatestPrice()`: View function for checking price without gas cost
  - `updatePriceFeed()`: Owner function to change price feed address
  - `getPegBounds()`: Returns the peg boundaries
  - `transferOwnership()`: Transfer contract ownership

## 🚀 Quick Start

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) installed
- Testnet ETH/MATIC for gas
- Testnet LINK for Chainlink Automation

### Installation

```bash
# Clone the repository
cd peg-monitor

# Install dependencies
forge install

# Build contracts
forge build
```

### Testing

```bash
# Run all tests
forge test

# Run tests with verbosity
forge test -vvv

# Run fork tests (requires RPC URL)
forge test --fork-url $SEPOLIA_RPC_URL -vvv
```

## 📦 Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed deployment instructions including:
- Setting up environment variables
- Deploying to Sepolia or Amoy testnet
- Configuring Chainlink Automation
- Setting up Envio.dev indexer

### Quick Deploy (Sepolia)

```bash
# Set up environment variables
cp ENV_TEMPLATE .env
# Edit .env with your values

# Deploy to Sepolia
source .env
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --broadcast \
    --verify \
    -vvvv
```

## 🔗 Supported Networks

| Network | Chain ID | USDC/USD Price Feed |
|---------|----------|---------------------|
| Sepolia | 11155111 | `0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E` |
| Amoy (Polygon) | 80002 | `0x1b8739bB4CdF0089d07097A9Ae5Bd274b29C6F16` |

## 📊 Contract Interface

### Main Functions

```solidity
// Check USDC price and emit event
function checkHeartbeat() external returns (int256 price, bool isPegged)

// View latest price without gas cost
function getLatestPrice() external view returns (
    int256 price,
    bool isPegged,
    uint256 updatedAt
)

// Get peg boundaries
function getPegBounds() external pure returns (
    int256 lowerBound,
    int256 upperBound
)
```

### Events

```solidity
event PriceUpdate(
    uint256 indexed timestamp,
    int256 price,
    bool isPegged
)
```

## 🧪 Testing Strategy

The test suite includes **22 comprehensive tests**:
- ✅ Constructor validation
- ✅ Price fetching functionality
- ✅ Peg detection at boundaries
- ✅ Event emission verification
- ✅ OpenZeppelin Ownable integration tests
- ✅ Access control with custom errors
- ✅ Owner management (transfer & renounce)
- ✅ Fork tests with real Chainlink data

## 🔐 Security Features

- **OpenZeppelin Integration**: Uses audited OpenZeppelin `Ownable` v5.0.0 for access control
- **Input Validation**: All critical inputs are validated
- **Price Validation**: Ensures price data is positive and reasonable
- **Owner Controls**: Sensitive functions protected by battle-tested ownership
- **No Value Handling**: Contract doesn't handle ETH/tokens
- **Immutable Decimals**: Price feed decimals stored immutably

## 📈 Chainlink Automation Setup

1. Deploy the PegMonitor contract
2. Go to [Chainlink Automation](https://automation.chain.link)
3. Register new upkeep:
   - **Trigger**: Time-based
   - **Target**: Your PegMonitor contract address
   - **Function**: `checkHeartbeat()`
   - **Cron**: `*/5 * * * *` (every 5 minutes)
   - **Gas Limit**: 200,000
4. Fund with testnet LINK

## 📝 Project Structure

```
peg-monitor/
├── src/
│   └── PegMonitor.sol          # Main contract
├── script/
│   └── DeployPegMonitor.s.sol  # Deployment script
├── test/
│   └── PegMonitor.t.sol        # Test suite
├── lib/
│   ├── forge-std/              # Forge standard library
│   ├── chainlink-brownie-contracts/  # Chainlink contracts
│   └── openzeppelin-contracts/ # OpenZeppelin v5.0.0
├── foundry.toml                # Foundry configuration
├── DEPLOYMENT.md               # Detailed deployment guide
├── ENV_TEMPLATE                # Environment variables template
└── README.md                   # This file
```

## 🛠️ Foundry Commands

```bash
# Build contracts
forge build

# Run tests
forge test

# Format code
forge fmt

# Gas snapshots
forge snapshot

# Deploy script
forge script script/DeployPegMonitor.s.sol --rpc-url <RPC_URL> --broadcast

# Interact with deployed contract
cast call <CONTRACT_ADDRESS> "getLatestPrice()" --rpc-url <RPC_URL>
```

## 🔮 Next Steps

1. ✅ Deploy contract to testnet
2. ⏳ Set up Chainlink Automation
3. ⏳ Configure Envio.dev indexer
4. ⏳ Create GraphQL queries for data retrieval
5. ⏳ Build frontend dashboard (optional)

## 📚 Resources

- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)
- [Chainlink Automation](https://docs.chain.link/chainlink-automation/introduction)
- [Envio.dev Documentation](https://docs.envio.dev/)
- [Foundry Book](https://book.getfoundry.sh/)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## ⚠️ Disclaimer

This is a testnet project for monitoring purposes only. Always audit smart contracts before deploying to mainnet.
