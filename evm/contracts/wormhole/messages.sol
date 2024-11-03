// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

import "solidity-bytes-utils/contracts/BytesLib.sol";
import "./structs.sol";

contract Messages is Structs {
    using BytesLib for bytes;

    /**
     * @notice Encodes the HelloWorldMessage struct into bytes
     * @param parsedMessage HelloWorldMessage struct with arbitrary HelloWorld message
     * @return encodedMessage HelloWorldMessage encoded into bytes
     */
    function encodeMessage(
        Message memory parsedMessage
    ) public pure returns (bytes memory encodedMessage) {
        // Convert message string to bytes so that we can use the .length attribute.
        // The length of the arbitrary messages needs to be encoded in the message
        // so that the corresponding decode function can decode the message properly.
        bytes memory encodedMessagePayload = abi.encodePacked(
            parsedMessage.message
        );

        // return the encoded message
        encodedMessage = abi.encodePacked(
            parsedMessage.payloadID,
            uint16(encodedMessagePayload.length),
            encodedMessagePayload
        );
    }

    /**
     * @notice Decodes bytes into HelloWorldMessage struct
     * @dev Verifies the payloadID
     * @param encodedMessage encoded arbitrary HelloWorld message
     * @return parsedMessage HelloWorldMessage struct with arbitrary HelloWorld message
     */
    function decodeMessage(
        bytes memory encodedMessage
    ) public pure returns (Message memory parsedMessage) {
        // starting index for byte parsing
        uint256 index = 0;

        // parse and verify the payloadID
        parsedMessage.payloadID = encodedMessage.toUint8(index);
        require(parsedMessage.payloadID == 1, "invalid payloadID");
        index += 1;

        // parse the message string length
        uint256 messageLength = encodedMessage.toUint16(index);
        index += 2;

        // parse the message string
        bytes memory messageBytes = encodedMessage.slice(index, messageLength);
        parsedMessage.message = string(messageBytes);
        index += messageLength;

        // confirm that the message was the expected length
        require(index == encodedMessage.length, "invalid message length");
    }
}
