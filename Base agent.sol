pragma solidity 0.8.0;

contract BaseAgent {
    string public agentName;

    constructor(string memory name) {
        agentName = name;
    }

    function updateName(string memory newName) public {
        agentName = newName;
    }
function createNewAgent(string memory newAgentName) public returns (address) {
    BaseAgent newAgent = new BaseAgent(newAgentName);
    return address(newAgent);
mapping(uint => string) public agentData;

function storeAgentData(uint id, string memory data) public {
    agentData[id] = data;
}function callTool(string memory toolName, string memory input) public returns (string memory) {
    return string(abi.encodePacked("Calling ", toolName, " with ", input));
}}
