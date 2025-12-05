/*
 * USDC Peg Monitor Event Handlers
 * Processes PriceUpdate events from PegMonitor contract
 */
import {
  PegMonitor,
} from "generated";

/**
 * Helper function to format price from 8 decimals to human-readable string
 * @param price - BigInt price with 8 decimals (e.g., 100000000 = $1.00)
 * @returns Formatted string (e.g., "1.00000000")
 */
function formatPrice(price: bigint): string {
  const priceNum = Number(price) / 100000000;
  return priceNum.toFixed(8);
}

/**
 * Handler for PriceUpdate events
 * Creates PriceCheck entities and updates global statistics
 */
PegMonitor.PriceUpdate.handler(async ({ event, context }) => {
  const { timestamp, price, isPegged } = event.params;
  
  // ==========================================
  // 1. CREATE PRICE CHECK ENTITY
  // ==========================================
  
  const id = `${event.chainId}_${event.block.number}_${event.logIndex}`;
  
  const priceCheck = {
    id,
    timestamp: timestamp,
    price: price,
    priceFormatted: formatPrice(price),
    isPegged: isPegged,
    blockNumber: BigInt(event.block.number),
    transactionHash: event.transaction.hash,
  };

  context.PriceCheck.set(priceCheck);

  // ==========================================
  // 2. UPDATE GLOBAL STATISTICS
  // ==========================================
  
  const statsId = "global";
  let stats = await context.PegStats.get(statsId);

  if (!stats) {
    // First check - initialize global stats
    stats = {
      id: statsId,
      totalChecks: BigInt(1),
      peggedCount: isPegged ? BigInt(1) : BigInt(0),
      unpeggedCount: isPegged ? BigInt(0) : BigInt(1),
      lastCheckTimestamp: timestamp,
      lastPrice: price,
      lastPriceFormatted: formatPrice(price),
      lastIsPegged: isPegged,
    };
  } else {
    // Update existing stats using spread operator (objects are immutable)
    const updatedStats = {
      ...stats,
      totalChecks: stats.totalChecks + BigInt(1),
      peggedCount: isPegged ? stats.peggedCount + BigInt(1) : stats.peggedCount,
      unpeggedCount: isPegged ? stats.unpeggedCount : stats.unpeggedCount + BigInt(1),
      lastCheckTimestamp: timestamp,
      lastPrice: price,
      lastPriceFormatted: formatPrice(price),
      lastIsPegged: isPegged,
    };
    
    stats = updatedStats;
  }

  context.PegStats.set(stats);
});
