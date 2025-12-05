// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title PegMonitor
 * @notice Monitors USDC/USD peg stability using Chainlink Data Feeds
 * @dev Designed to work with Chainlink Automation for periodic price checks
 */
contract PegMonitor is Ownable {
    // Chainlink price feed interface
    AggregatorV3Interface internal priceFeed;

    // Peg boundaries (with 8 decimals matching Chainlink price feed)
    int256 public constant LOWER_BOUND = 99000000; // $0.99
    int256 public constant UPPER_BOUND = 101000000; // $1.01

    // Price feed decimals
    uint8 public immutable DECIMALS;

    // Event emitted on each price check
    event PriceUpdate(
        uint256 indexed timestamp,
        int256 price,
        bool isPegged
    );

    // Event emitted when price feed is updated
    event PriceFeedUpdated(address indexed newPriceFeed);

    /**
     * @notice Constructor to initialize the price feed
     * @param _priceFeed Address of the Chainlink USDC/USD price feed
     * @dev Sepolia USDC/USD: 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
     * @dev Amoy (Polygon) USDC/USD: Would need to be provided based on network
     */
    constructor(address _priceFeed) Ownable(msg.sender) {
        require(_priceFeed != address(0), "Invalid price feed address");
        priceFeed = AggregatorV3Interface(_priceFeed);
        DECIMALS = priceFeed.decimals();
    }

    /**
     * @notice Main function to check USDC price and determine peg status
     * @dev This function is designed to be called by Chainlink Automation
     * @return price The latest USDC/USD price
     * @return isPegged Boolean indicating if price is within stable range
     */
    function checkHeartbeat() external returns (int256 price, bool isPegged) {
        // Fetch latest price data from Chainlink
        (
            /* uint80 roundId */,
            int256 answer,
            /* uint256 startedAt */,
            uint256 updatedAt,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();

        require(answer > 0, "Invalid price data");
        require(updatedAt > 0, "Invalid timestamp");

        price = answer;
        
        // Check if price is within the peg range ($0.99 - $1.01)
        isPegged = (price >= LOWER_BOUND && price <= UPPER_BOUND);

        // Emit event with price data
        emit PriceUpdate(block.timestamp, price, isPegged);

        return (price, isPegged);
    }

    /**
     * @notice View function to get the latest price without emitting an event
     * @return price The latest USDC/USD price
     * @return isPegged Boolean indicating if price is within stable range
     * @return updatedAt Timestamp of the last price update
     */
    function getLatestPrice() external view returns (
        int256 price,
        bool isPegged,
        uint256 updatedAt
    ) {
        (
            /* uint80 roundId */,
            int256 answer,
            /* uint256 startedAt */,
            uint256 timestamp,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();

        require(answer > 0, "Invalid price data");
        
        price = answer;
        isPegged = (price >= LOWER_BOUND && price <= UPPER_BOUND);
        updatedAt = timestamp;

        return (price, isPegged, updatedAt);
    }

    /**
     * @notice Update the price feed address
     * @param _newPriceFeed New Chainlink price feed address
     * @dev Only callable by owner, useful for testing or network changes
     */
    function updatePriceFeed(address _newPriceFeed) external onlyOwner {
        require(_newPriceFeed != address(0), "Invalid price feed address");
        priceFeed = AggregatorV3Interface(_newPriceFeed);
        emit PriceFeedUpdated(_newPriceFeed);
    }

    /**
     * @notice Get the current price feed address
     * @return Address of the Chainlink price feed being used
     */
    function getPriceFeedAddress() external view returns (address) {
        return address(priceFeed);
    }

    /**
     * @notice Get peg boundaries
     * @return lowerBound Lower price boundary
     * @return upperBound Upper price boundary
     */
    function getPegBounds() external pure returns (int256 lowerBound, int256 upperBound) {
        return (LOWER_BOUND, UPPER_BOUND);
    }
}

