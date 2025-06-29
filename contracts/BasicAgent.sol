// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./SuperAgentBuilder.sol";

contract BasicAgent {
    ISuperAgentBuilder public superAgentBuilder;
    address public client;
    string public task;
    bool public isActive;

    event TaskExecuted(address indexed client, string task, bytes result);

    constructor(address _superAgentBuilder, address _client, string memory _task) {
        superAgentBuilder = ISuperAgentBuilder(_superAgentBuilder);
        client = _client;
        task = _task;
        isActive = true;
    }

    function executeTask(string memory query) external {
        require(msg.sender == client, "Only client can execute");
        require(isActive, "Agent is inactive");
        
        bytes memory result = superAgentBuilder.fetchExternalData(query);
        emit TaskExecuted(client, task, result);
    }

    function deactivate() external {
        require(msg.sender == client, "Only client can deactivate");
        isActive = false;
    }
}
