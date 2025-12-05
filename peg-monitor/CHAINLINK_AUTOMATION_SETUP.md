# Chainlink Automation Setup Guide 🤖

## Your Contract Details

- **Contract Address**: `0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750`
- **Network**: Sepolia
- **Function to Call**: `checkHeartbeat()`
- **Frequency**: Every 5 minutes

---

## 📋 Prerequisites

1. **Get Sepolia LINK tokens** (free from faucet)
   - Go to: https://faucets.chain.link/sepolia
   - Amount needed: 5-10 LINK

---

## 🚀 Setup Steps

### 1. Go to Chainlink Automation

Visit: https://automation.chain.link/

### 2. Connect Your Wallet

- Click "Connect Wallet" (top right)
- Connect the wallet: `0xd9c0bb3476ce2ad2102d3ac07287bb802eea98f1`
- Switch network to **Sepolia**

### 3. Register New Upkeep

Click **"Register new Upkeep"** button

### 4. Select Trigger Type

Choose: **"Time-based"** trigger

### 5. Fill in the Details

#### **Target Contract Address**
```
0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750
```

#### **ABI / Function Selection**
The interface should auto-detect the contract ABI (it's verified).

Select function: `checkHeartbeat()`

#### **Time Schedule (Cron Expression)**
For every 5 minutes:
```
*/5 * * * *
```

**Breakdown**:
- `*/5` = Every 5 minutes
- `*` = Every hour
- `*` = Every day
- `*` = Every month
- `*` = Every day of week

#### **Upkeep Name**
```
USDC Peg Monitor - Heartbeat
```

#### **Gas Limit**
```
200000
```
(The function uses ~25,000-30,000 gas, so 200k provides a safety margin)

#### **Starting Balance (LINK)**
```
5 LINK
```
This should last for thousands of executions.

#### **Your Email** (optional)
Add your email for notifications.

### 6. Review and Confirm

- Review all details
- Click **"Register Upkeep"**
- Confirm the transaction in MetaMask
- Wait for transaction confirmation

### 7. Fund the Upkeep

After registration:
- Your upkeep will appear in the dashboard
- It should already have the LINK you specified
- If needed, you can add more LINK anytime

---

## ✅ Verification

### Check Upkeep Status

1. Go to: https://automation.chain.link/sepolia
2. Find your upkeep: "USDC Peg Monitor - Heartbeat"
3. You should see:
   - ✅ Status: Active
   - ✅ Balance: ~5 LINK
   - ✅ Last Execution: (will show after first run)

### Check Contract Events

After 5 minutes, verify events are being emitted:

```bash
# Check recent PriceUpdate events
cast logs \
    --address 0x80bf808902D4dAbEddBDd9EdaDfed3064Aa0B750 \
    --from-block 9766160 \
    "PriceUpdate(uint256,int256,bool)" \
    --rpc-url $SEPOLIA_RPC_URL
```

Or view on Etherscan:
```
https://sepolia.etherscan.io/address/0x80bf808902d4dabeddbdd9edadfed3064aa0b750#events
```

---

## 📊 What Happens Now

Every 5 minutes, Chainlink Automation will:

1. ✅ Call `checkHeartbeat()` on your contract
2. ✅ Contract fetches USDC/USD price from Chainlink
3. ✅ Contract checks if price is within $0.99-$1.01 range
4. ✅ Contract emits `PriceUpdate` event with:
   - `timestamp`: Block timestamp
   - `price`: USDC price (8 decimals)
   - `isPegged`: true/false

These events will be visible on Etherscan and can be indexed by Envio.dev!

---

## 💰 Cost Estimation

- **Gas per execution**: ~30,000 gas
- **Sepolia gas price**: ~0.001 gwei (essentially free)
- **LINK per execution**: ~0.001 LINK
- **5 LINK lasts**: ~5,000 executions = ~17 days at 5-minute intervals

When balance gets low, you'll get an email notification (if you provided one).

---

## 🔧 Troubleshooting

### Upkeep Not Executing

**Check**:
1. Is status "Active"? (not paused)
2. Is LINK balance > 0?
3. Is the cron expression correct?
4. Check "History" tab for error messages

**Solution**: Make sure contract has gas and LINK balance is sufficient.

### "Simulation Failed"

**Possible causes**:
1. Contract reverted (price feed issue)
2. Not enough gas limit

**Solution**: 
- Increase gas limit to 300,000
- Check Chainlink price feed is working

### No Events Appearing

**Wait**: First execution happens on the next cron schedule (within 5 minutes of registration).

**Check**: View transaction history in Automation dashboard.

---

## 🎯 Alternative Schedules

If you want different frequencies:

**Every 1 minute** (for testing):
```
* * * * *
```

**Every 10 minutes**:
```
*/10 * * * *
```

**Every 30 minutes**:
```
*/30 * * * *
```

**Every hour**:
```
0 * * * *
```

You can update the schedule anytime in the Automation dashboard.

---

## 📚 Resources

- [Chainlink Automation Docs](https://docs.chain.link/chainlink-automation/introduction)
- [Cron Expression Guide](https://crontab.guru/)
- [Sepolia LINK Faucet](https://faucets.chain.link/sepolia)
- [Automation Dashboard](https://automation.chain.link/sepolia)

---

## ✨ Success Checklist

After setup, verify:

- [ ] Upkeep registered and active
- [ ] LINK balance sufficient (5+ LINK)
- [ ] First execution completed (check History)
- [ ] Events visible on Etherscan
- [ ] Ready for Envio.dev indexer setup

Once you see events on Etherscan, you're ready for Step 2: Envio.dev! 🎉

