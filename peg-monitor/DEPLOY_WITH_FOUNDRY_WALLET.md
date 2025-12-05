# Deploy with Foundry Wallet (Recommended Method) 🔐

This guide shows you how to deploy using your existing Foundry keystore wallet - **the most secure method!**

## ✅ Why Use Foundry Wallet?

| Method | Private Key in .env | Foundry Wallet |
|--------|---------------------|----------------|
| **Security** | ❌ Plain text file | ✅ Encrypted keystore |
| **Password** | ❌ None | ✅ Required each use |
| **Git Risk** | ❌ Can be committed | ✅ Never exposed |
| **Recommended** | No | **Yes!** |

## 🔍 Your Current Setup

You have these Foundry wallets:
- `AnvilDeployer` (Local)
- `AnvilDeployer2` (Local)
- `FlagshipTestnetOwner` (Local)
- `liamDeploy` (Local)

Your deployer address: `0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1`

## 📋 Prerequisites

1. **Get Sepolia ETH** (for gas)
   - Faucet: https://sepoliafaucet.com
   - Send to: `0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1`
   - Amount needed: ~0.01 ETH (plenty for deployment)

2. **Get Sepolia LINK** (for Chainlink Automation later)
   - Faucet: https://faucets.chain.link/sepolia
   - Amount needed: 5-10 LINK

3. **Get Etherscan API Key** (optional, for verification)
   - Sign up: https://etherscan.io/apis
   - Free tier is fine

## 🚀 Deployment Steps

### 1. Verify Your Wallet Balance

```bash
# Check Sepolia ETH balance
cast balance 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 --rpc-url https://rpc.sepolia.org
```

You should see something like `10000000000000000` (0.01 ETH in wei).

### 2. Test Connection

```bash
# Test RPC connection
cast block-number --rpc-url https://rpc.sepolia.org
```

Should return the current Sepolia block number.

### 3. Build Contracts

```bash
cd /Users/linumlabs/USDC-Ped-monitor/peg-monitor
forge build
```

Expected output: `Compiler run successful!`

### 4. Run Tests (Optional but Recommended)

```bash
forge test --offline
```

Expected: `22 tests passed`

### 5. Deploy to Sepolia

**Important**: Replace `liamDeploy` with your actual account name if different.

```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url https://rpc.sepolia.org \
    --chain sepolia \
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    -vvvv
```

**What happens**:
1. You'll be prompted: `Enter password for account liamDeploy:`
2. Enter your wallet password (secure!)
3. Script simulates deployment
4. You'll see: `Do you want to continue? (y/N):`
5. Type `y` and press Enter
6. Contract deploys!

### 6. Verify on Etherscan (Optional)

If you have an Etherscan API key:

```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url https://rpc.sepolia.org \
    --chain sepolia \
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    --verify \
    --etherscan-api-key YOUR_API_KEY \
    -vvvv
```

Or verify after deployment:

```bash
forge verify-contract \
    <CONTRACT_ADDRESS> \
    src/PegMonitor.sol:PegMonitor \
    --chain-id 11155111 \
    --constructor-args $(cast abi-encode "constructor(address)" 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E) \
    --etherscan-api-key YOUR_API_KEY
```

## 📊 Expected Output

```
[⠢] Compiling...
No files changed, compilation skipped

Script ran successfully.

== Logs ==
  PegMonitor deployed to: 0x1234567890abcdef1234567890abcdef12345678
  Using price feed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
  Chain ID: 11155111
  Deployer: 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1

## Setting up 1 EVM.

==========================

Chain 11155111

Estimated gas price: 1.000000007 gwei

Estimated total gas used for script: 842356

Estimated amount required: 0.000842356005896492 ETH

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
Total Paid: 0.00080... ETH

✅ Sequence #1 on sepolia | Total Paid: 0.00080... ETH
```

## 🎯 Post-Deployment

### 1. Save Your Contract Address

```bash
# From the output above
export CONTRACT_ADDRESS=0x1234567890abcdef1234567890abcdef12345678
```

### 2. Verify Deployment

```bash
# Check the contract exists
cast code $CONTRACT_ADDRESS --rpc-url https://rpc.sepolia.org
```

Should return bytecode (long hex string).

### 3. Test the Contract

```bash
# Get latest price
cast call $CONTRACT_ADDRESS "getLatestPrice()" --rpc-url https://rpc.sepolia.org

# Manual heartbeat (costs gas)
cast send $CONTRACT_ADDRESS "checkHeartbeat()" \
    --account liamDeploy \
    --rpc-url https://rpc.sepolia.org
```

### 4. View on Sepolia Etherscan

Visit: `https://sepolia.etherscan.io/address/<CONTRACT_ADDRESS>`

## 🔧 Troubleshooting

### Error: "Device not configured"
This is normal when checking wallet address. Your wallet is secure and requires password.

### Error: "Insufficient funds"
Get more Sepolia ETH from https://sepoliafaucet.com

### Error: "Nonce too high"
Your wallet might have pending transactions. Check on Sepolia Etherscan.

### Error: "Simulation failed"
Check that:
- You have enough ETH
- RPC URL is correct
- Network is not congested

### Password Prompt Not Showing
Make sure you're using the correct account name:
```bash
cast wallet list  # Check your account names
```

## 🆚 Alternative: Import Existing Private Key

If you have a private key you want to import into Foundry:

```bash
cast wallet import myNewWallet --interactive
# Enter private key when prompted
# Set a strong password
```

Then use:
```bash
--account myNewWallet \
--sender <YOUR_ADDRESS>
```

## 📝 Complete Example Script

```bash
#!/bin/bash

# Set variables
ACCOUNT_NAME="liamDeploy"
DEPLOYER_ADDRESS="0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1"
RPC_URL="https://rpc.sepolia.org"

# Check balance
echo "Checking balance..."
cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL

# Build
echo "Building contracts..."
forge build

# Test (optional)
echo "Running tests..."
forge test --offline

# Deploy
echo "Deploying to Sepolia..."
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $RPC_URL \
    --chain sepolia \
    --account $ACCOUNT_NAME \
    --sender $DEPLOYER_ADDRESS \
    --broadcast \
    -vvvv

echo "✅ Deployment complete!"
```

Save this as `deploy.sh`, make it executable:
```bash
chmod +x deploy.sh
./deploy.sh
```

## 🎉 Success!

Once deployed, you'll have:
- ✅ PegMonitor contract on Sepolia
- ✅ Secure deployment (no private keys exposed)
- ✅ Ready for Chainlink Automation setup
- ✅ Your wallet remains encrypted

## 🔜 Next Steps

1. **Set up Chainlink Automation**
   - Go to https://automation.chain.link
   - Register time-based upkeep
   - Point to your contract address
   - Fund with LINK

2. **Configure Envio.dev Indexer**
   - Monitor PriceUpdate events
   - Create GraphQL queries

3. **Monitor Your Contract**
   - Watch events on Sepolia Etherscan
   - Check Chainlink Automation dashboard

---

**Need Help?** 
- Foundry Book: https://book.getfoundry.sh/
- Sepolia Etherscan: https://sepolia.etherscan.io
- Chainlink Docs: https://docs.chain.link

