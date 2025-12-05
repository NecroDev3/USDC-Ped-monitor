# Getting a Reliable Sepolia RPC URL 🌐

## Problem

Public RPC endpoints like `https://rpc.sepolia.org` can be:
- ❌ Down/timing out
- ❌ Rate-limited
- ❌ Slow
- ❌ Unreliable

## Solution: Use a Provider (Free!)

Get a free RPC from a reliable provider. Takes 2 minutes!

---

## 🥇 Option 1: Alchemy (Recommended)

**Why Alchemy?**
- ✅ Free tier: 300M compute units/month
- ✅ Very reliable and fast
- ✅ Great dashboard
- ✅ No credit card required

### Setup Steps:

1. **Sign up**: https://www.alchemy.com/
2. **Create an app**:
   - Click "Create new app"
   - Name: `PegMonitor`
   - Chain: `Ethereum`
   - Network: `Ethereum Sepolia`
3. **Get your URL**:
   - Click on your app
   - Click "View Key"
   - Copy the HTTPS URL
   
Your URL will look like:
```
https://eth-sepolia.g.alchemy.com/v2/abcd1234efgh5678ijkl
```

### Deploy with Alchemy:

```bash
# Set your RPC URL
export SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR-API-KEY"

# Deploy
./QUICK_DEPLOY.sh
```

---

## 🥈 Option 2: Infura (Alternative)

**Why Infura?**
- ✅ Free tier: 100k requests/day
- ✅ Industry standard
- ✅ Reliable
- ✅ No credit card required

### Setup Steps:

1. **Sign up**: https://www.infura.io/
2. **Create a project**:
   - Click "Create New API Key"
   - Select "Web3 API"
   - Name: `PegMonitor`
3. **Enable Sepolia**:
   - Go to your project
   - Network Endpoints → Enable Sepolia
4. **Get your URL**:
   - Copy the Sepolia endpoint

Your URL will look like:
```
https://sepolia.infura.io/v3/abcd1234efgh5678ijkl9012
```

### Deploy with Infura:

```bash
# Set your RPC URL
export SEPOLIA_RPC_URL="https://sepolia.infura.io/v3/YOUR-PROJECT-ID"

# Deploy
./QUICK_DEPLOY.sh
```

---

## 🥉 Option 3: Other Providers

### Ankr (Free, Public)
```bash
export SEPOLIA_RPC_URL="https://rpc.ankr.com/eth_sepolia"
```

### Public Node
```bash
export SEPOLIA_RPC_URL="https://ethereum-sepolia-rpc.publicnode.com"
```

### Chainstack
```bash
export SEPOLIA_RPC_URL="https://ethereum-sepolia.rpc.subquery.network/public"
```

---

## 🚀 Quick Deploy Once You Have RPC

### Method 1: Using the Script (Easiest)

```bash
# 1. Set your RPC URL
export SEPOLIA_RPC_URL="YOUR-RPC-URL-HERE"

# 2. Run the deployment script
cd /Users/linumlabs/USDC-Ped-monitor/peg-monitor
./QUICK_DEPLOY.sh
```

### Method 2: Direct Command

```bash
forge script script/DeployPegMonitor.s.sol:DeployPegMonitor \
    --rpc-url "YOUR-RPC-URL-HERE" \
    --chain sepolia \
    --account liamDeploy \
    --sender 0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1 \
    --broadcast \
    -vvvv
```

---

## ✅ Test Your RPC First

Before deploying, test that your RPC works:

```bash
# Test connection
cast block-number --rpc-url "$SEPOLIA_RPC_URL"

# Should return a number like: 5234567
```

If you get a number, your RPC is working! ✅

If you get an error, try a different provider.

---

## 📊 Comparison

| Provider | Free Tier | Signup | Reliability | Speed |
|----------|-----------|--------|-------------|-------|
| **Alchemy** | 300M CU/mo | Required | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Infura** | 100k req/day | Required | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Ankr** | Unlimited | None | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| **PublicNode** | Unlimited | None | ⭐⭐⭐ | ⭐⭐⭐ |
| **rpc.sepolia.org** | Unlimited | None | ⭐ | ⭐ |

**Recommendation**: Use Alchemy or Infura for deployment. They're free and much more reliable.

---

## 🔒 Security Note

Your RPC URL contains an API key. Don't commit it to git!

```bash
# Good ✅
export SEPOLIA_RPC_URL="..."  # Temporary, in terminal only

# Bad ❌
# Don't put it directly in scripts that get committed
```

If using `.env` file:
```bash
# Add to .gitignore
echo ".env" >> .gitignore
```

---

## 🆘 Troubleshooting

### "HTTP error 522" or "Connection timed out"
→ The RPC is down. Try a different provider.

### "Rate limit exceeded"
→ You've hit the free tier limit. Try:
  - Wait an hour
  - Use a different provider
  - Upgrade to paid tier (usually not needed for testnet)

### "Invalid response"
→ Check your RPC URL is correct:
  - Should start with `https://`
  - Should end with your API key
  - No extra spaces

### Still having issues?
Try all the providers in order until one works:
```bash
# Try Ankr
export SEPOLIA_RPC_URL="https://rpc.ankr.com/eth_sepolia"
cast block-number --rpc-url "$SEPOLIA_RPC_URL"

# If that fails, try PublicNode
export SEPOLIA_RPC_URL="https://ethereum-sepolia-rpc.publicnode.com"
cast block-number --rpc-url "$SEPOLIA_RPC_URL"
```

---

## 🎯 Complete Example

```bash
# 1. Sign up at Alchemy (2 minutes)
# 2. Create app, get your URL
# 3. Set it in your terminal:

export SEPOLIA_RPC_URL="https://eth-sepolia.g.alchemy.com/v2/YOUR-KEY"

# 4. Test it works
cast block-number --rpc-url "$SEPOLIA_RPC_URL"

# 5. Deploy!
cd /Users/linumlabs/USDC-Ped-monitor/peg-monitor
./QUICK_DEPLOY.sh

# Done! ✅
```

---

**Time to complete**: 5 minutes (including signup)  
**Cost**: $0 (all free tiers are sufficient)  
**Recommendation**: Alchemy is the fastest and most reliable 🏆

