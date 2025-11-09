// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AIRDROPTOKEN.sol";

contract AIRDROPTOKENTest is Test {
    AIRDROPTOKEN public token;
    address public owner;
    address public user1;
    address public user2;
    address public user3;

    event AirdropClaimed(address indexed recipient, uint256 amount);
    event AirdropStatusChanged(bool active);
    event BatchAirdropCompleted(uint256 recipientCount, uint256 totalAmount);

    function setUp() public {
        owner = address(this);
        user1 = address(0x1);
        user2 = address(0x2);
        user3 = address(0x3);
        
        token = new AIRDROPTOKEN();
    }

    function testInitialState() public view {
        assertEq(token.name(), "AIRDROPTOKEN");
        assertEq(token.symbol(), "ADT");
        assertEq(token.decimals(), 18);
        assertEq(token.MINT_AMOUNT(), 100 * 10**18);
        assertTrue(token.airdropActive());
        assertEq(token.owner(), owner);
    }

    function testClaimAirdrop() public {
        vm.expectEmit(true, true, true, true);
        emit AirdropClaimed(user1, token.MINT_AMOUNT());
        
        vm.prank(user1);
        token.claimAirdrop();
        
        assertEq(token.balanceOf(user1), token.MINT_AMOUNT());
        assertTrue(token.hasClaimedAirdrop(user1));
    }

    function testCannotClaimAirdropTwice() public {
        vm.startPrank(user1);
        token.claimAirdrop();
        
        vm.expectRevert("Airdrop already claimed");
        token.claimAirdrop();
        vm.stopPrank();
    }

    function testCannotClaimWhenAirdropInactive() public {
        token.setAirdropActive(false);
        
        vm.prank(user1);
        vm.expectRevert("Airdrop is not active");
        token.claimAirdrop();
    }

    function testBatchAirdrop() public {
        address[] memory recipients = new address[](3);
        recipients[0] = user1;
        recipients[1] = user2;
        recipients[2] = user3;
        
        vm.expectEmit(true, true, true, true);
        emit BatchAirdropCompleted(3, 300 * 10**18);
        
        token.batchAirdrop(recipients);
        
        assertEq(token.balanceOf(user1), 100 * 10**18);
        assertEq(token.balanceOf(user2), 100 * 10**18);
        assertEq(token.balanceOf(user3), 100 * 10**18);
        assertTrue(token.hasClaimedAirdrop(user1));
        assertTrue(token.hasClaimedAirdrop(user2));
        assertTrue(token.hasClaimedAirdrop(user3));
    }

    function testBatchAirdropSkipsDuplicates() public {
        vm.prank(user1);
        token.claimAirdrop();
        
        address[] memory recipients = new address[](2);
        recipients[0] = user1;
        recipients[1] = user2;
        
        token.batchAirdrop(recipients);
        
        assertEq(token.balanceOf(user1), 100 * 10**18);
        assertEq(token.balanceOf(user2), 100 * 10**18);
    }

    function testBatchAirdropOnlyOwner() public {
        address[] memory recipients = new address[](1);
        recipients[0] = user1;
        
        vm.prank(user2);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user2));
        token.batchAirdrop(recipients);
    }

    function testBatchAirdropEmptyArray() public {
        address[] memory recipients = new address[](0);
        
        vm.expectRevert("No recipients provided");
        token.batchAirdrop(recipients);
    }

    function testSetAirdropActive() public {
        vm.expectEmit(true, true, true, true);
        emit AirdropStatusChanged(false);
        
        token.setAirdropActive(false);
        assertFalse(token.airdropActive());
        
        vm.expectEmit(true, true, true, true);
        emit AirdropStatusChanged(true);
        
        token.setAirdropActive(true);
        assertTrue(token.airdropActive());
    }

    function testSetAirdropActiveOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.setAirdropActive(false);
    }

    function testMint() public {
        token.mint(user1, 500 * 10**18);
        assertEq(token.balanceOf(user1), 500 * 10**18);
    }

    function testMintOnlyOwner() public {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)", user1));
        token.mint(user1, 500 * 10**18);
    }

    function testHasClaimedAirdropView() public {
        assertFalse(token.hasClaimedAirdropView(user1));
        
        vm.prank(user1);
        token.claimAirdrop();
        
        assertTrue(token.hasClaimedAirdropView(user1));
    }

    function testTransferTokens() public {
        vm.prank(user1);
        token.claimAirdrop();
        
        vm.prank(user1);
        token.transfer(user2, 50 * 10**18);
        
        assertEq(token.balanceOf(user1), 50 * 10**18);
        assertEq(token.balanceOf(user2), 50 * 10**18);
    }

    function testTotalSupplyAfterClaims() public {
        vm.prank(user1);
        token.claimAirdrop();
        
        vm.prank(user2);
        token.claimAirdrop();
        
        assertEq(token.totalSupply(), 200 * 10**18);
    }
}