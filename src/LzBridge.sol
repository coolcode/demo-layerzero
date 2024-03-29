// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {console2} from "forge-std/console2.sol";
import {OApp, MessagingFee, Origin} from "@layerzerolabs/lz-evm-oapp-v2/contracts/oapp/OApp.sol";

/*
    LayerZero Optimism Goerli
      lzChainId:10132 lzEndpoint:0xae92d5aD7583AD66E49A0c67BAd18F6ba52dDDc1
      contract: 0x22063bC54243d5cc0B66269C0d15449C95e8eA6c
    LayerZero Goerli
      lzChainId:10121 lzEndpoint:0xbfD2135BFfbb0B5378b56643c2Df8a87552Bfa23
      contract: 0xb8C2e35437295315244c2c747b7D18f0749011fA
*/
contract LzBridge is OApp {
    event MessageSent(string message, uint32 dstEid);
    event MessageReceive(string message, uint32 srcEid, address _executor);

    constructor(address _endpoint, address _owner) OApp(_endpoint, _owner) {}

    function quote(uint32 _dstEid, string memory _message, bytes memory _options, bool _payInLzToken)
        public
        view
        returns (MessagingFee memory fee)
    {
        bytes memory payload = abi.encode(_message);
        fee = _quote(_dstEid, payload, _options, _payInLzToken);
    }

    function send(uint32 _dstEid, string calldata _message, bytes calldata _options) external payable {
        // Encodes the message before invoking _lzSend.
        bytes memory _payload = abi.encode(_message);
        _lzSend(
            _dstEid,
            _payload,
            _options,
            // Fee in native gas and ZRO token.
            MessagingFee(msg.value, 0),
            // Refund address in case of failed source message.
            payable(msg.sender)
        );

        emit MessageSent(_message, _dstEid);
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address _executor,
        bytes calldata _extraData
    ) internal override {
        console2.log("receive msg:", string(_message));
        emit MessageReceive(string(_message), _origin.srcEid, _executor);
    }
}
