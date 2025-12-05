// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {PegMonitor} from "../src/PegMonitor.sol";

/**
 * @title DeployPegMonitor
 * @notice Deployment script for PegMonitor contract
 * @dev Use with forge script command
 */
contract DeployPegMonitor is Script {
    // Chainlink USDC/USD Price Feed Addresses
    
    // Sepolia Testnet USDC/USD Feed
    address constant SEPOLIA_USDC_USD = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
    
    // Polygon Amoy Testnet USDC/USD Feed
    // Note: Verify the exact address from Chainlink docs for Amoy
    address constant AMOY_USDC_USD = 0x1b8739bB4CdF0089d07097A9Ae5Bd274b29C6F16;

    function run() external returns (PegMonitor) {
        // Determine which price feed to use based on chain ID
        address priceFeedAddress = getPriceFeedForChain(block.chainid);
        
        // Start broadcasting transactions
        // Note: This will use the account specified with --account flag
        // or fall back to PRIVATE_KEY env var
        vm.startBroadcast();
        
        // Deploy PegMonitor contract
        PegMonitor pegMonitor = new PegMonitor(priceFeedAddress);
        
        // Stop broadcasting
        vm.stopBroadcast();
        
        // Log deployment info
        console.log("PegMonitor deployed to:", address(pegMonitor));
        console.log("Using price feed:", priceFeedAddress);
        console.log("Chain ID:", block.chainid);
        console.log("Deployer:", msg.sender);
        
        return pegMonitor;
    }

    /**
     * @notice Get the appropriate price feed address based on chain ID
     * @param chainId The chain ID to deploy on
     * @return priceFeed The Chainlink price feed address
     */
    function getPriceFeedForChain(uint256 chainId) internal pure returns (address priceFeed) {
        if (chainId == 11155111) {
            // Sepolia
            return SEPOLIA_USDC_USD;
        } else if (chainId == 80002) {
            // Polygon Amoy
            return AMOY_USDC_USD;
        } else {
            // Default to Sepolia for local testing
            revert("Unsupported chain ID. Please use Sepolia (11155111) or Amoy (80002)");
        }
    }

    // Helper function for local testing without private key
    function deployForTesting(address priceFeed) external returns (PegMonitor) {
        vm.startBroadcast();
        PegMonitor pegMonitor = new PegMonitor(priceFeed);
        vm.stopBroadcast();
        return pegMonitor;
    }
}

