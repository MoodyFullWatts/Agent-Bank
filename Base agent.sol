pragma solidity 0.8.0;

contract BaseAgent {
    string public agentName;

    constructor(string memory name) {
        agentName = name;
    }

    function updateName(string memory newName) public {
        agentName = newName;
    }
}

b
