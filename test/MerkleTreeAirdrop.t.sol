// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {MerkleTreeAirdrop} from "src/MerkleTreeAirdrop.sol";

contract MerkleTreeAirdropTest is Test {
    MerkleTreeAirdrop mta;
    bytes32[] proof;

    function setUp() public {
        mta = new MerkleTreeAirdrop();
        mta.commit(bytes32(0x2e35b61278fbcec3f3b0bb361d928e373e089a61758af09690ce0a5391078ff2));
        proof.push(bytes32(0x702d0f86c1baf15ac2b8aae489113b59d27419b751fbf7da0ef0bae4688abc7a));
        proof.push(bytes32(0xb159efe4c3ee94e91cc5740b9dbb26fc5ef48a14b53ad84d591d0eb3d65891ab));
    }

    function testClaim() public {
        address user = 0xdD870fA1b7C4700F2BD7f44238821C26f7392148;
        assertFalse(mta.claimed(user));
        vm.prank(user);
        mta.claim(proof);
        assertTrue(mta.claimed(user));
    }

    function testFail() public {
        address user = address(1);
        vm.startPrank(user);
        vm.expectRevert("assertion failed");
        mta.claim(proof);
        assertFalse(mta.claimed(user));
    }
}
