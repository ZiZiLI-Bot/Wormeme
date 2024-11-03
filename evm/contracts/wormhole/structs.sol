// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.27;

contract Structs {
    struct Message {
        // unique identifier for this message type
        uint8 payloadID;
        // arbitrary message string
        string message;
    }
}
