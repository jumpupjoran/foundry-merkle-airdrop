// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {BagelToken} from "../src/BagelToken.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "../script/DeployMerkleAirdrop.s.sol";
import {SplitSignature} from "../script/SplitSignature.s.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    BagelToken public token;
    MerkleAirdrop public airdrop;
    SplitSignature public splitSignatureContract;

    bytes32 public ROOT = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
    uint256 public AMOUNT_TO_CLAIM = 25 * 1e18;
    uint256 public AMOUNT_TO_SEND = AMOUNT_TO_CLAIM * 4;
    // not sure if folloing is correct, copilot suggested it
    bytes32[] public PROOF = [
        bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];
    bytes32[] public FALSE_PROOF = [
        bytes32(0x0fd0c000d00bece00f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a),
        bytes32(0xe0ebd0e0b0a0000a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)
    ];
    address gasPayer;
    address user;
    uint256 userPrivateKey;

    event Claim(address account, uint256 amount);

    function setUp() public {
        // if (!isZkSyncChain()) {
        //     //deploy with the script
        //     DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
        //     (airdrop, token) = deployer.deployMerkleAirdrop();
        // } else {
        token = new BagelToken();
        airdrop = new MerkleAirdrop(ROOT, token);
        splitSignatureContract = new SplitSignature();
        token.mint(token.owner(), AMOUNT_TO_SEND); // owner of token contract is this test contract itself, because we deployed it here
        token.transfer(address(airdrop), AMOUNT_TO_SEND);
        (user, userPrivateKey) = makeAddrAndKey("user");
        gasPayer = makeAddr("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        // sign a message
        // vm.prank(user); we dont need to prank the user bacause we are allready giving the private key in next line, this causes an error.
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        //gasPayer calls claim using the signed message
        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("endingBalance: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testInitialization() public view {
        // Check that the Merkle root is set correctly
        assertEq(airdrop.getMerkleRoot(), ROOT);

        // Check that the token address is set correctly
        assertEq(airdrop.getTokenAddress(), address(token));
    }

    function testCanNotClaimWithInvalidProof() public {
        // Assume an invalid proof for user1
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);
        // Try to claim with the invalid proof and expect a revert
        vm.prank(gasPayer);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);
        airdrop.claim(user, AMOUNT_TO_CLAIM, FALSE_PROOF, v, r, s);
    }

    function testClaimEvent() public {
        // claim tokens
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        //gasPayer calls claim using the signed message
        vm.prank(gasPayer);
        vm.expectEmit(false, false, false, false, address(airdrop));
        emit Claim(user, AMOUNT_TO_CLAIM);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
    }

    function testCannotClaimTwice() public {
        // claim tokens
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        //gasPayer calls claim using the signed message
        vm.startPrank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        // claim tokens again
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();
    }
}
// 0x46f4c7c1c21e8a90c03949beda51d2d02d1ec75b55dd97a999d3edbafa5a1e2f
// 0x46f4c7c1c21e8a90c03949beda51d2d02d1ec75b55dd97a999d3edbafa5a1e2f
