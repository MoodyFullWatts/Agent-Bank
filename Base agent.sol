pragma solidity 0.8.0;

contract BaseAgent {
    string public agentName;
    address public owner;
    mapping(uint => string) public agentData;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(string memory name) {
        owner = msg.sender;
        agentName = name;
    }

    function updateName(string memory newName) public only owner {
        agentName = newName;
    }

    function createNewAgent(string memory newAgentName) public returns (address) {
        BaseAgent newAgent = new BaseAgent(newAgentName);
        return address(newAgent);
    }

    function storeAgentData(uint id, string memory data) public only owner {
        agentData[id] = data;
    }

    function callTool(string memory toolName, string memory input) public returns (string memory) {
        return string(abi.encodePacked("Calling ", toolName, " with ", input));
    }
}
