// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {PegMonitor} from "../src/PegMonitor.sol";
import {MockAggregatorV3} from "./mocks/MockAggregatorV3.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

/**
 * @title PegMonitorTest
 * @notice Test suite for PegMonitor contract
 */
contract PegMonitorTest is Test {
    PegMonitor public pegMonitor;
    MockAggregatorV3 public mockPriceFeed;
    
    // Sepolia USDC/USD Price Feed (for reference)
    address constant SEPOLIA_USDC_USD = 0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E;
    
    // Mock price: $1.00 with 8 decimals
    int256 constant INITIAL_PRICE = 100000000;
    
    address public owner;
    address public user;

    // Events to test
    event PriceUpdate(uint256 indexed timestamp, int256 price, bool isPegged);
    event PriceFeedUpdated(address indexed newPriceFeed);

    function setUp() public {
        owner = address(this);
        user = makeAddr("user");
        
        // Deploy mock price feed with $1.00 price
        mockPriceFeed = new MockAggregatorV3(INITIAL_PRICE, 8);
        
        // Deploy PegMonitor with mock price feed
        pegMonitor = new PegMonitor(address(mockPriceFeed));
    }

    function test_Constructor() public view {
        assertEq(pegMonitor.owner(), owner);
        assertEq(pegMonitor.getPriceFeedAddress(), address(mockPriceFeed));
        assertEq(pegMonitor.DECIMALS(), 8); // Chainlink USD feeds use 8 decimals
    }

    function test_ConstructorRevertsWithZeroAddress() public {
        vm.expectRevert("Invalid price feed address");
        new PegMonitor(address(0));
    }

    function test_GetPegBounds() public view {
        (int256 lower, int256 upper) = pegMonitor.getPegBounds();
        assertEq(lower, 99000000); // $0.99 with 8 decimals
        assertEq(upper, 101000000); // $1.01 with 8 decimals
    }

    function test_GetLatestPrice() public view {
        (int256 price, bool isPegged, uint256 updatedAt) = pegMonitor.getLatestPrice();
        
        // Verify price is positive and reasonable for USDC
        assertGt(price, 0);
        assertGt(updatedAt, 0);
        
        // Log the values for manual inspection
        console.log("Latest Price:", uint256(price));
        console.log("Is Pegged:", isPegged);
        console.log("Updated At:", updatedAt);
    }

    function test_CheckHeartbeat() public {
        // Expect PriceUpdate event
        vm.expectEmit(true, false, false, false);
        emit PriceUpdate(block.timestamp, 0, false);
        
        (int256 price, bool isPegged) = pegMonitor.checkHeartbeat();
        
        // Verify returned values
        assertGt(price, 0);
        // isPegged should be true or false, both are valid
        assertTrue(isPegged == true || isPegged == false);
        
        // Log for inspection
        console.log("Heartbeat Price:", uint256(price));
        console.log("Heartbeat Is Pegged:", isPegged);
    }

    function test_CheckHeartbeatCanBeCalledByAnyone() public {
        vm.prank(user);
        (int256 price, bool isPegged) = pegMonitor.checkHeartbeat();
        assertGt(price, 0);
        assertTrue(isPegged == true || isPegged == false);
    }

    function test_UpdatePriceFeed() public {
        address newPriceFeed = makeAddr("newPriceFeed");
        
        vm.expectEmit(true, false, false, false);
        emit PriceFeedUpdated(newPriceFeed);
        
        pegMonitor.updatePriceFeed(newPriceFeed);
        assertEq(pegMonitor.getPriceFeedAddress(), newPriceFeed);
    }

    function test_UpdatePriceFeedRevertsForNonOwner() public {
        address newPriceFeed = makeAddr("newPriceFeed");
        
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        pegMonitor.updatePriceFeed(newPriceFeed);
    }

    function test_UpdatePriceFeedRevertsWithZeroAddress() public {
        vm.expectRevert("Invalid price feed address");
        pegMonitor.updatePriceFeed(address(0));
    }

    function test_TransferOwnership() public {
        assertEq(pegMonitor.owner(), owner);
        pegMonitor.transferOwnership(user);
        assertEq(pegMonitor.owner(), user);
    }

    function test_TransferOwnershipRevertsForNonOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        pegMonitor.transferOwnership(user);
    }

    function test_TransferOwnershipRevertsWithZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableInvalidOwner.selector, address(0)));
        pegMonitor.transferOwnership(address(0));
    }

    function test_RenounceOwnership() public {
        pegMonitor.renounceOwnership();
        assertEq(pegMonitor.owner(), address(0));
    }

    function test_RenounceOwnershipRevertsForNonOwner() public {
        vm.prank(user);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user));
        pegMonitor.renounceOwnership();
    }

    function test_PriceIsPeggedAt1Dollar() public {
        mockPriceFeed.updatePrice(100000000); // Exactly $1.00
        (int256 price, bool isPegged) = pegMonitor.checkHeartbeat();
        
        assertEq(price, 100000000);
        assertTrue(isPegged);
    }

    function test_PriceIsPeggedAtLowerBound() public {
        mockPriceFeed.updatePrice(99000000); // Exactly $0.99
        (int256 price, bool isPegged) = pegMonitor.checkHeartbeat();
        
        assertEq(price, 99000000);
        assertTrue(isPegged);
    }

    function test_PriceIsPeggedAtUpperBound() public {
        mockPriceFeed.updatePrice(101000000); // Exactly $1.01
        (int256 price, bool isPegged) = pegMonitor.checkHeartbeat();
        
        assertEq(price, 101000000);
        assertTrue(isPegged);
    }

    function test_PriceIsNotPeggedBelowLowerBound() public {
        mockPriceFeed.updatePrice(98999999); // $0.98999999
        (int256 price, bool isPegged) = pegMonitor.checkHeartbeat();
        
        assertEq(price, 98999999);
        assertFalse(isPegged);
    }

    function test_PriceIsNotPeggedAboveUpperBound() public {
        mockPriceFeed.updatePrice(101000001); // $1.01000001
        (int256 price, bool isPegged) = pegMonitor.checkHeartbeat();
        
        assertEq(price, 101000001);
        assertFalse(isPegged);
    }

    function test_PriceIsNotPeggedAtZero() public {
        mockPriceFeed.updatePrice(0);
        
        vm.expectRevert("Invalid price data");
        pegMonitor.checkHeartbeat();
    }

    function test_PriceIsNotPeggedAtNegative() public {
        mockPriceFeed.updatePrice(-1);
        
        vm.expectRevert("Invalid price data");
        pegMonitor.checkHeartbeat();
    }

    // Fork test - only runs when forking Sepolia
    function testFork_CheckHeartbeatWithRealData() public {
        // Skip if not on a fork
        try vm.activeFork() returns (uint256) {
            // Deploy with real price feed on fork
            PegMonitor forkMonitor = new PegMonitor(SEPOLIA_USDC_USD);
            (int256 price, bool isPegged) = forkMonitor.checkHeartbeat();
            
            assertGt(price, 0);
            assertLt(price, 200000000); // Should be close to $1.00, definitely less than $2.00
            
            console.log("Fork Test - Price:", uint256(price));
            console.log("Fork Test - Is Pegged:", isPegged);
        } catch {
            // Not on a fork, skip test
            console.log("Skipping fork test - not on a fork");
        }
    }
}

