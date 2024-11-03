// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "lib/wormhole-solidity-sdk/src/interfaces/IWormhole.sol";
import "solidity-bytes-utils/contracts/BytesLib.sol";

import "./wormhole/getters.sol";
import "./wormhole/messages.sol";

contract Wormeme is Getters, Messages {
    using BytesLib for bytes;

    event DepositedETH(address indexed sender, uint256 amount);
    event DepositedToken(
        address indexed sender,
        address indexed token,
        uint256 amount
    );
    event WithdrawnETH(uint256 amount);
    event WithdrawnToken(address indexed token, uint256 amount);
    event WormholeMessageSent(uint64 sequence);

    modifier onlyOwner() {
        require(msg.sender == owner(), "Ownable: caller is not the owner");
        _;
    }

    constructor(address wormhole_, uint16 chainId_, uint8 wormholeFinality_) {
        require(wormhole_ != address(0), "invalid Wormhole address");
        require(chainId_ > 0, "invalid chainId");
        require(wormholeFinality_ > 0, "invalid wormholeFinality");

        setOwner(msg.sender);
        setWormhole(wormhole_);
        setChainId(chainId_);
        setWormholeFinality(wormholeFinality_);
    }

    function depositETH() external payable {
        require(msg.value > 0, "Must send ETH to deposit");
        emit DepositedETH(msg.sender, msg.value);
    }

    function depositToken(address token, uint256 amount) external {
        require(amount > 0, "Must deposit a positive amount");
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        emit DepositedToken(msg.sender, token, amount);
    }

    function withdrawETH(uint256 amount) external onlyOwner {
        require(address(this).balance >= amount, "Not enough ETH in contract");
        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "ETH withdrawal failed");
        emit WithdrawnETH(amount);
    }

    function withdrawToken(address token, uint256 amount) external onlyOwner {
        IERC20(token).transfer(msg.sender, amount);
        emit WithdrawnToken(token, amount);
    }

    function sendMessage(
        string memory MessageContent
    ) public payable returns (uint64 messageSequence) {
        require(
            abi.encodePacked(MessageContent).length < type(uint16).max,
            "message too large"
        );

        IWormhole wormhole = wormhole();
        uint256 wormholeFee = wormhole.messageFee();

        require(msg.value == wormholeFee, "insufficient value");

        Message memory parsedMessage = Message({
            payloadID: uint8(1),
            message: MessageContent
        });

        bytes memory encodedMessage = encodeMessage(parsedMessage);

        messageSequence = wormhole.publishMessage{value: wormholeFee}(
            0, // batchID
            encodedMessage,
            wormholeFinality()
        );
    }
}
