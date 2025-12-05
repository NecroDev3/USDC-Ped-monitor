# Fix Applied - Chain ID Issue ✅

## Problem

The deployment was failing with:
```
Error: script failed: Unsupported chain ID. Please use Sepolia (11155111) or Amoy (80002)
```

## Root Cause

When running `forge script`, it defaults to using a **local simulation** with anvil's chain ID (31337) before broadcasting to the actual network. The deployment script was checking `block.chainid` during simulation and rejecting it because it wasn't 11155111 (Sepolia) or 80002 (Amoy).

## Solution

Added the `--chain sepolia` flag to tell forge to **simulate on Sepolia's chain ID** during the dry run.

### Fixed Command

```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url https://rpc.sepolia.org \
    --chain sepolia \                    # ← This was missing!
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    -vvvv
```

## Quick Deploy Option

Created `QUICK_DEPLOY.sh` script for easy deployment:

```bash
./QUICK_DEPLOY.sh
```

This script includes:
- ✅ Balance check
- ✅ Build verification
- ✅ Correct chain flag
- ✅ Clear success/error messages

## Additional Fixes

1. **Cleaned build artifacts**: Removed old Counter.sol artifacts
   ```bash
   forge clean
   ```

2. **Updated all documentation**: Added `--chain sepolia` to:
   - DEPLOY_WITH_FOUNDRY_WALLET.md
   - DEPLOYMENT.md
   - QUICK_START.md

## Try Again

Now run:

```bash
cd /Users/linumlabs/USDC-Ped-monitor/peg-monitor

# Option 1: Use the quick deploy script
./QUICK_DEPLOY.sh

# Option 2: Use the full command
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url https://rpc.sepolia.org \
    --chain sepolia \
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    -vvvv
```

## Expected Output

```
[⠊] Compiling...
No files changed, compilation skipped

Script ran successfully.

== Logs ==
  PegMonitor deployed to: 0x...
  Using price feed: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
  Chain ID: 11155111
  Deployer: 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1

## Setting up 1 EVM.
Chain 11155111

✅ Sequence #1 on sepolia | Total Paid: 0.000... ETH
```

## Verification

After successful deployment:

```bash
# Save contract address from output
export CONTRACT_ADDRESS=0x...

# Verify it exists
cast code $CONTRACT_ADDRESS --rpc-url https://rpc.sepolia.org

# View on Etherscan
open https://sepolia.etherscan.io/address/$CONTRACT_ADDRESS
```

---

**Status**: ✅ Fixed and ready to deploy!

