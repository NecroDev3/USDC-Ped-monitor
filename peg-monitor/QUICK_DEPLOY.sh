#!/bin/bash
# Quick deployment script for PegMonitor to Sepolia

echo "🚀 Deploying PegMonitor to Sepolia..."
echo ""

# Configuration
ACCOUNT_NAME="liamDeploy"
DEPLOYER_ADDRESS="0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1"

# RPC URL - Use one of these (in order of preference):
# 1. Your own Alchemy/Infura URL (most reliable)
# 2. Set via environment variable: export SEPOLIA_RPC_URL="your-url"
# 3. Falls back to public RPC (less reliable)

if [ ! -z "$SEPOLIA_RPC_URL" ]; then
    RPC_URL="$SEPOLIA_RPC_URL"
    echo "✅ Using RPC from environment: $SEPOLIA_RPC_URL"
else
    # Try alternative public RPCs in order
    RPC_URL="https://rpc2.sepolia.org"
    echo "⚠️  Using public RPC (may be unreliable)"
    echo "   For better reliability, get a free RPC from:"
    echo "   - Alchemy: https://www.alchemy.com/"
    echo "   - Infura: https://www.infura.io/"
fi

# Check if we have the RPC URL
if [ -z "$RPC_URL" ]; then
    echo "❌ Error: RPC_URL not set"
    exit 1
fi

echo "📋 Configuration:"
echo "   Account: $ACCOUNT_NAME"
echo "   Deployer: $DEPLOYER_ADDRESS"
echo "   Network: Sepolia"
echo "   RPC: $RPC_URL"
echo ""

# Check balance
echo "💰 Checking balance..."
cast balance $DEPLOYER_ADDRESS --rpc-url $RPC_URL

echo ""
echo "🔨 Building contracts..."
forge build

if [ $? -ne 0 ]; then
    echo "❌ Build failed"
    exit 1
fi

echo ""
echo "📤 Deploying to Sepolia..."
echo "   (You will be prompted for your wallet password)"
echo ""

forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url $RPC_URL \
    --chain sepolia \
    --account $ACCOUNT_NAME \
    --sender $DEPLOYER_ADDRESS \
    --broadcast \
    -vvvv

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Deployment successful!"
    echo ""
    echo "🔗 Next steps:"
    echo "   1. Check your contract on Sepolia Etherscan"
    echo "   2. Set up Chainlink Automation at https://automation.chain.link"
    echo "   3. Fund the automation with LINK tokens"
else
    echo ""
    echo "❌ Deployment failed. Check the error above."
    exit 1
fi

