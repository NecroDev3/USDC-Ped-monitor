# Quick Start Guide - PegMonitor

This is a condensed guide to get you up and running quickly.

## 🚀 Fast Setup

```bash
# 1. Build contracts
forge build

# 2. Run tests
forge test

# 3. Check your Foundry wallet
cast wallet list

# 4. Set up RPC URL
export SEPOLIA_RPC_URL=https://rpc.sepolia.org

# 5. Deploy to Sepolia (using Foundry wallet - Recommended!)
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --chain sepolia \
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    --verify \
    -vvvv

# Or use the quick deploy script:
./QUICK_DEPLOY.sh
```

**Alternative**: Use private key in `.env` (less secure):
```bash
# Set PRIVATE_KEY=your_key in .env
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --chain sepolia \
    --broadcast \
    --verify \
    -vvvv
```

## 📋 Common Commands

### Development
```bash
# Build
forge build

# Test (offline)
forge test --offline

# Test (with Sepolia fork)
forge test --fork-url $SEPOLIA_RPC_URL -vvv

# Test specific function
forge test --match-test test_CheckHeartbeat -vvv

# Format code
forge fmt

# Gas snapshot
forge snapshot
```

### Deployment

**Sepolia (Foundry Wallet - Recommended):**
```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --chain sepolia \
    --account YOUR_ACCOUNT_NAME \
    --sender YOUR_ADDRESS \
    --broadcast \
    --verify
```

**Quick Deploy Script:**
```bash
./QUICK_DEPLOY.sh
```

**Sepolia (Private Key - Alternative):**
```bash
# Requires PRIVATE_KEY in .env
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $SEPOLIA_RPC_URL \
    --chain sepolia \
    --broadcast \
    --verify
```

**Note**: Amoy (Polygon) is optional - Sepolia alone is sufficient!

### Interaction

**Check latest price:**
```bash
cast call <CONTRACT_ADDRESS> "getLatestPrice()" --rpc-url $SEPOLIA_RPC_URL
```

**Manually trigger heartbeat:**
```bash
cast send <CONTRACT_ADDRESS> "checkHeartbeat()" \
    --private-key $PRIVATE_KEY \
    --rpc-url $SEPOLIA_RPC_URL
```

**Get peg bounds:**
```bash
cast call <CONTRACT_ADDRESS> "getPegBounds()" --rpc-url $SEPOLIA_RPC_URL
```

**Watch for events:**
```bash
cast logs --address <CONTRACT_ADDRESS> \
    "PriceUpdate(uint256,int256,bool)" \
    --rpc-url $SEPOLIA_RPC_URL
```

## 🔗 Chainlink Automation Setup

1. Go to https://automation.chain.link
2. Click "Register New Upkeep"
3. Select "Time-based trigger"
4. Fill in:
   - **Contract**: `<YOUR_DEPLOYED_ADDRESS>`
   - **Function**: `checkHeartbeat()`
   - **Cron**: `*/5 * * * *`
   - **Gas**: `200000`
5. Fund with testnet LINK

## 📊 Get Testnet Tokens

- **Sepolia ETH**: https://sepoliafaucet.com
- **Sepolia LINK**: https://faucets.chain.link/sepolia
- **Amoy MATIC**: https://faucet.polygon.technology
- **Amoy LINK**: https://faucets.chain.link/polygon-amoy

## 📈 Network Info

| Network | Chain ID | RPC | Explorer |
|---------|----------|-----|----------|
| Sepolia | 11155111 | https://sepolia.infura.io/v3/YOUR-KEY | https://sepolia.etherscan.io |
| Amoy | 80002 | https://rpc-amoy.polygon.technology | https://www.oklink.com/amoy |

## 🔍 Price Feed Addresses

- **Sepolia USDC/USD**: `0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E`
- **Amoy USDC/USD**: `0x1b8739bB4CdF0089d07097A9Ae5Bd274b29C6F16`

## 📝 Environment Variables

**Option 1: Foundry Wallet (Recommended)**
```bash
# Only need RPC URL
export SEPOLIA_RPC_URL=https://rpc.sepolia.org
export ETHERSCAN_API_KEY=your_etherscan_key  # For verification
```

**Option 2: Private Key (Alternative)**
Required in `.env`:
```bash
PRIVATE_KEY=your_private_key_without_0x
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR-API-KEY
ETHERSCAN_API_KEY=your_etherscan_key
```

**Note**: Polygon/Amoy variables only needed if deploying there (optional).

## 🎯 Contract Functions

```solidity
// Anyone can call (designed for Chainlink Automation)
checkHeartbeat() → (int256 price, bool isPegged)

// View functions (no gas)
getLatestPrice() → (int256 price, bool isPegged, uint256 updatedAt)
getPegBounds() → (int256 lower, int256 upper)
getPriceFeedAddress() → address

// Owner only
updatePriceFeed(address newFeed)
transferOwnership(address newOwner)
```

## 📚 Documentation Files

- **README.md** - Overview and features
- **DEPLOYMENT.md** - Detailed deployment guide
- **CONTRACT_SUMMARY.md** - Implementation details
- **QUICK_START.md** - This file

## ⚡ Troubleshooting

**Build fails:**
```bash
forge clean
forge build
```

**Tests fail (network):**
```bash
forge test --offline
```

**Deployment fails:**
- Check you have testnet ETH/MATIC
- Verify RPC URL is correct
- Ensure private key is set in .env (without 0x)

**Can't verify contract:**
- Check API key in .env
- Try adding `--chain-id <CHAIN_ID>` flag
- Verify manually on block explorer

## 🎉 Success Checklist

- [ ] Contract compiles (`forge build`)
- [ ] All tests pass (`forge test`)
- [ ] Deployed to testnet
- [ ] Contract verified on explorer
- [ ] Chainlink Automation registered
- [ ] Automation funded with LINK
- [ ] First heartbeat executed
- [ ] Events visible on explorer

---

**Need Help?** Check the detailed guides:
- Deployment issues → See DEPLOYMENT.md
- Contract details → See CONTRACT_SUMMARY.md
- General info → See README.md

