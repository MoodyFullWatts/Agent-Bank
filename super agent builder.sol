// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

contract SuperAgentBuilder {
    string public agentName;
    address public owner;
    mapping(uint => string) public agentData; // Stores tool or agent configs
    mapping(address => string) public agentMessages; // Stores messages for agents or clients
    mapping(string => address) public createdAgents; // Tracks created agents by name

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized(address caller) {
        require(caller == owner || caller == address(this) || createdAgents[agentName] != address(0), "Not authorized");
        _;
    }

    constructor(string memory _agentName) {
        agentName = _agentName;
        owner = msg.sender;
    }

    function createNewAgent(string memory newAgentName) public onlyOwner returns (address) {
        SuperAgentBuilder newAgent = new SuperAgentBuilder(newAgentName);
        createdAgents[newAgentName] = address(newAgent);
        return address(newAgent);
    }

    function addTool(uint toolId, string memory toolDetails) public onlyAuthorized(msg.sender) {
        agentData[toolId] = toolDetails;
    }

    function sendMessage(address recipient, string memory message) public onlyAuthorized(msg.sender) {
        agentMessages[recipient] = message;
    }
}