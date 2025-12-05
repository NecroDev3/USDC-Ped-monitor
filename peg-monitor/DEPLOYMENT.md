# PegMonitor Deployment Guide

## Overview
PegMonitor is a Solidity smart contract that monitors USDC/USD price stability using Chainlink Data Feeds and is designed to work with Chainlink Automation.

## Contract Features

### Core Functionality
- **checkHeartbeat()**: Fetches latest USDC/USD price from Chainlink Oracle and emits PriceUpdate event
- **PriceUpdate Event**: Contains timestamp, raw price, and isPegged boolean
- **Peg Detection**: Monitors if price is outside stable range ($0.99 - $1.01)

### Additional Features
- **getLatestPrice()**: View function to check price without emitting event
- **updatePriceFeed()**: Owner can update price feed address (useful for testing)
- **Owner Management**: Transfer ownership functionality

## Supported Networks

### Sepolia Testnet
- **Chain ID**: 11155111
- **USDC/USD Price Feed**: `0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E`
- **RPC URL**: https://sepolia.infura.io/v3/YOUR-API-KEY

### Polygon Amoy Testnet
- **Chain ID**: 80002
- **USDC/USD Price Feed**: `0x1b8739bB4CdF0089d07097A9Ae5Bd274b29C6F16`
- **RPC URL**: https://rpc-amoy.polygon.technology

## Prerequisites

1. **Install Foundry** (if not already installed):
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. **Get Testnet ETH/MATIC**:
   - Sepolia: https://sepoliafaucet.com
   - Amoy: https://faucet.polygon.technology

3. **Get Testnet LINK** (for Chainlink Automation):
   - Sepolia: https://faucets.chain.link/sepolia
   - Amoy: https://faucets.chain.link/polygon-amoy

## Deployment Steps

### 1. Choose Your Deployment Method

You have **two options** for deployment (Foundry wallet is more secure):

#### Option A: Foundry Wallet (Recommended ✅)
Use your existing Foundry keystore wallet - **More Secure!**

```bash
# Check your wallets
cast wallet list

# Check wallet address (example)
cast wallet address --account liamDeploy
```

#### Option B: Private Key (Alternative)
Create a `.env` file with your private key:

```bash
PRIVATE_KEY=your_private_key_here
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR-API-KEY
ETHERSCAN_API_KEY=your_etherscan_api_key
```

### 2. Set Up RPC URL

**Required**: Set your Sepolia RPC URL

```bash
export SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR-API-KEY
# OR use public RPC
export SEPOLIA_RPC_URL=https://rpc.sepolia.org
```

### 3. Compile Contracts

```bash
forge build
```

### 4. Deploy to Sepolia

#### Using Foundry Wallet (Recommended ✅):
```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --chain sepolia \
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    --verify \
    -vvvv
```

You'll be prompted for your wallet password (secure!).

#### Using Private Key (Alternative):
```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --chain sepolia \
    --broadcast \
    --verify \
    -vvvv
```

Requires `PRIVATE_KEY` in `.env` file.

### 5. Deploy to Amoy (Optional)

**Note**: Polygon Amoy is optional! Only needed if you want to deploy on multiple networks.

```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $AMOY_RPC_URL \
    --account liamDeploy \
    --broadcast \
    --verify \
    -vvvv
```

## Setting Up Chainlink Automation

### 1. Register Upkeep

1. Go to [Chainlink Automation](https://automation.chain.link)
2. Click "Register New Upkeep"
3. Select "Time-based trigger"
4. Fill in the details:
   - **Target contract address**: Your deployed PegMonitor address
   - **Function to call**: `checkHeartbeat()`
   - **Cron expression**: `*/5 * * * *` (every 5 minutes)
   - **Gas limit**: 200000
   - **Starting balance**: Fund with testnet LINK

### 2. Cron Expression for 5 Minutes
```
*/5 * * * *
```
This runs every 5 minutes.

### 3. Monitor Your Upkeep
- View execution history in Chainlink Automation dashboard
- Check PriceUpdate events on block explorer

## Testing

### Run All Tests
```bash
forge test
```

### Run Tests with Verbosity
```bash
forge test -vvv
```

### Run Fork Tests (Sepolia)
```bash
forge test --fork-url $SEPOLIA_RPC_URL -vvv
```

### Run Specific Test
```bash
forge test --match-test test_CheckHeartbeat -vvv
```

## Interacting with Deployed Contract

### Check Latest Price
```bash
cast call YOUR_CONTRACT_ADDRESS "getLatestPrice()" --rpc-url $SEPOLIA_RPC_URL
```

### Manually Trigger Heartbeat
```bash
cast send YOUR_CONTRACT_ADDRESS "checkHeartbeat()" \
    --private-key $PRIVATE_KEY \
    --rpc-url $SEPOLIA_RPC_URL
```

### Get Peg Bounds
```bash
cast call YOUR_CONTRACT_ADDRESS "getPegBounds()" --rpc-url $SEPOLIA_RPC_URL
```

## Event Monitoring

### Watch for PriceUpdate Events

```bash
cast logs --address YOUR_CONTRACT_ADDRESS \
    "PriceUpdate(uint256,int256,bool)" \
    --rpc-url $SEPOLIA_RPC_URL
```

## Troubleshooting

### Issue: "Invalid price data"
- **Cause**: Chainlink price feed returned 0 or negative value
- **Solution**: Check if price feed address is correct for your network

### Issue: "Insufficient LINK balance"
- **Cause**: Chainlink Automation ran out of LINK
- **Solution**: Top up LINK balance in Automation dashboard

### Issue: Deployment fails
- **Cause**: Insufficient gas or network issues
- **Solution**: Ensure you have enough testnet ETH/MATIC and correct RPC URL

## Gas Optimization Notes

- `checkHeartbeat()` is called frequently, so it's optimized for gas efficiency
- Event emission is necessary for indexing but adds ~1500 gas per call
- View functions (`getLatestPrice()`) don't consume gas when called externally

## Security Considerations

1. **Owner Controls**: Only owner can update price feed address
2. **Price Validation**: Contract validates price data before emitting events
3. **No Value Handling**: Contract doesn't handle ETH/tokens, reducing attack surface

## Next Steps

After deployment:
1. Set up Chainlink Automation (see above)
2. Configure Envio.dev indexer to monitor PriceUpdate events
3. Create GraphQL queries for historical data
4. Monitor contract on block explorer

## Useful Links

- [Chainlink Price Feeds](https://docs.chain.link/data-feeds/price-feeds/addresses)
- [Chainlink Automation](https://docs.chain.link/chainlink-automation/introduction)
- [Foundry Book](https://book.getfoundry.sh/)
- [Sepolia Etherscan](https://sepolia.etherscan.io/)
- [Amoy Polygonscan](https://www.oklink.com/amoy)

