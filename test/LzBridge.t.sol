// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {MessagingFee} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";
import {OptionsBuilder} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/libs/OptionsBuilder.sol";
import {TestHelper} from "./TestHelper.sol";
import {ERC20Mock} from "./mocks/ERC20Mock.sol";
import {LzBridge} from "src/LzBridge.sol";

contract LzBridgeTest is TestHelper {
    using OptionsBuilder for bytes;

    uint32 aEid = 1;
    uint32 bEid = 2;
    uint32 cEid = 3;

    LzBridge bridgeA;
    LzBridge bridgeB;
    LzBridge bridgeC;

    address public owner = address(0xf);
    address public userA = address(0x1);
    address public userB = address(0x2);
    address public userC = address(0x3);
    uint256 public initialBalance = 100 ether;
    IERC20 cERC20Mock;

    function setUp() public override {
        vm.deal(userA, 1000 ether);
        vm.deal(userB, 1000 ether);
        vm.deal(userC, 1000 ether);
        super.setUp();
        setUpEndpoints(3, LibraryType.UltraLightNode);

        bridgeA = LzBridge(_deployOApp(type(LzBridge).creationCode, abi.encode(address(endpoints[aEid]), owner)));
        bridgeB = LzBridge(_deployOApp(type(LzBridge).creationCode, abi.encode(address(endpoints[bEid]), owner)));
        bridgeC = LzBridge(_deployOApp(type(LzBridge).creationCode, abi.encode(address(endpoints[cEid]), owner)));

        cERC20Mock = new ERC20Mock("cToken", "cToken");

        address[] memory ofts = new address[](3);
        ofts[0] = address(bridgeA);
        ofts[1] = address(bridgeB);
        ofts[2] = address(bridgeC);
        this.wireOApps(ofts);
    }

    function test_constructor() external {
        assertEq(bridgeA.owner(), owner);
        assertEq(bridgeB.owner(), owner);
        assertEq(bridgeC.owner(), owner);

        // assertEq(aOFT.balanceOf(userA), initialBalance);
        // assertEq(bOFT.balanceOf(userB), initialBalance);
        // assertEq(IERC20(cOFTAdapter.token()).balanceOf(userC), initialBalance);

        // assertEq(aOFT.token(), address(aOFT));
        // assertEq(bOFT.token(), address(bOFT));
        // assertEq(cOFTAdapter.token(), address(cERC20Mock));
    }

    function test_send() external {
        uint256 tokensToSend = 1 ether;
        // SendParam memory sendParam = SendParam(bEid, addressToBytes32(userB), tokensToSend, tokensToSend);

        string memory message = "hello world!";
        bytes memory options = OptionsBuilder.newOptions().addExecutorLzReceiveOption(200000, 0);

        MessagingFee memory fee = bridgeA.quote(bEid, message, options, false);
        console2.log("fee:", fee.nativeFee);
        vm.prank(userA);
        bridgeA.send{value: fee.nativeFee}(bEid, message, options);
        verifyPackets(bEid, addressToBytes32(address(bridgeB)));
    }
}
