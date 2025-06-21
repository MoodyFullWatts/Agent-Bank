// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

contract BaseAgent {
    string public agentName;
    address public owner;
    mapping(uint => string) public agentData;
    mapping(address => string) public agentMessages;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized(address caller) {
        require(caller == owner || caller == address(this), "Not authorized");
        _;
    }

    constructor(string memory name) {
        owner = msg.sender;
        agentName = name;
    }

    function updateName(string memory newName) public onlyOwner {
        agentName = newName;
    }

    function createNewAgent(string memory newAgentName) public onlyOwner returns (address) {
        return address(new BaseAgent(newAgentName));
    }

    function storeAgentData(uint id, string memory data) public onlyOwner {
        agentData[id] = data;
    }

    function callTool(string memory toolName, string memory input) public returns (string memory) {
        return string(abi.encodePacked("Calling ", toolName, " with ", input));
    }

    function sendMessage(address targetAgent, string memory message) public onlyOwner returns (bool) {
        if (targetAgent == address(0)) {
            return false; // Fail if target address is invalid
        }
        bytes32 encryptedMessage = keccak256(abi.encodePacked(message, block.timestamp)); // Encrypt message
        agentMessages[targetAgent] = string(abi.encodePacked(encryptedMessage));
        return true; // Confirm success
    }

    function getMessages(address targetAgent) public view onlyAuthorized(msg.sender) returns (string memory) {
        return agentMessages[targetAgent];
    }

    function fetchExternalData(uint256 requestId, string memory dataSource) public onlyOwner returns (uint256) {
        // Placeholder: simulate fetching data from an oracle
        agentData[requestId] = dataSource; // Store the data under the request ID
        return requestId;
    }
}