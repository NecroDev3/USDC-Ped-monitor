// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "../../lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

/**
 * @title MockAggregatorV3
 * @notice Mock Chainlink Aggregator for testing
 */
contract MockAggregatorV3 is AggregatorV3Interface {
    int256 private price;
    uint256 private updatedAtTimestamp;
    uint8 private _decimals;

    constructor(int256 _initialPrice, uint8 __decimals) {
        price = _initialPrice;
        _decimals = __decimals;
        updatedAtTimestamp = block.timestamp;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function description() external pure override returns (string memory) {
        return "Mock USDC/USD";
    }

    function version() external pure override returns (uint256) {
        return 1;
    }

    function getRoundData(uint80 _roundId)
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (_roundId, price, block.timestamp, updatedAtTimestamp, _roundId);
    }

    function latestRoundData()
        external
        view
        override
        returns (
            uint80 roundId,
            int256 answer,
            uint256 startedAt,
            uint256 updatedAt,
            uint80 answeredInRound
        )
    {
        return (1, price, block.timestamp, updatedAtTimestamp, 1);
    }

    // Helper functions for testing
    function updatePrice(int256 _price) external {
        price = _price;
        updatedAtTimestamp = block.timestamp;
    }

    function updateTimestamp(uint256 _timestamp) external {
        updatedAtTimestamp = _timestamp;
    }
}

