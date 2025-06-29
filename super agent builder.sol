// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

// Flare-specific imports for State Connector and FTSO
import "@flarenetwork/flare-periphery-contracts/contracts/stateConnector/IStateConnector.sol";
import "@flarenetwork/flare-periphery-contracts/contracts/ftso/interfaces/IFtso.sol";

// Interface to avoid circular dependency
interface ISuperAgentBuilder {
    function registerAgent(string memory agentName, address agentAddress) external;
    function sendMessage(address recipient, string memory message) external;
    function getAgentData(address agent, uint toolId) external view returns (string memory);
}

// BasicAgent contract for task-specific agents
contract BasicAgent {
    string public agentName;
    address public owner;
    address public immutable creator; // SuperAgentBuilder address
    mapping(uint => string) public agentData; // Tool or task configurations
    mapping(address => string) public agentMessages; // Messages for agents or clients
    IStateConnector public stateConnector; // Flare State Connector for external data

    // Events for tracking
    event ToolAdded(uint indexed toolId, string toolDetails);
    event MessageSent(address indexed sender, address indexed recipient, string message);
    event ExternalDataRequested(bytes32 indexed requestId, string data);

    modifier onlyAuthorized() {
        require(msg.sender == owner || msg.sender == creator, "Not authorized");
        _;
    }

    constructor(
        string memory _agentName,
        address _owner,
        address _creator,
        address _stateConnector
    ) {
        agentName = _agentName;
        owner = _owner;
        creator = _creator;
        stateConnector = IStateConnector(_stateConnector);

        // Register with SuperAgentBuilder
        ISuperAgentBuilder(_creator).registerAgent(_agentName, address(this));
    }

    // Add tool or task configuration
    function addTool(uint toolId, string memory toolDetails) external onlyAuthorized {
        require(bytes(toolDetails).length > 0, "Tool details cannot be empty");
        agentData[toolId] = toolDetails;
        emit ToolAdded(toolId, toolDetails);
    }

    // Send message to another agent or SuperAgentBuilder
    function sendMessage(address recipient, string memory message) external onlyAuthorized {
        require(recipient != address(0), "Invalid recipient");
        agentMessages[recipient] = message;
        emit MessageSent(msg.sender, recipient, message);

        // Notify SuperAgentBuilder if recipient is creator
        if (recipient == creator) {
            ISuperAgentBuilder(creator).sendMessage(address(this), message);
        }
    }

    // Request external data via Flare State Connector
    function requestExternalData(string memory dataQuery) external onlyAuthorized returns (bytes32) {
        bytes32 requestId = stateConnector.requestAttestation(dataQuery);
        emit ExternalDataRequested(requestId, dataQuery);
        return requestId;
    }

    // Retrieve data from another agent via SuperAgentBuilder
    function getAgentData(address agent, uint toolId) external view returns (string memory) {
        return ISuperAgentBuilder(creator).getAgentData(agent, toolId);
    }
}

// Factory contract to manage BasicAgent instances
contract SuperAgentBuilder {
    string public agentName;
    address public owner;
    mapping(uint => string) public agentData; // Tool or config storage
    mapping(address => string) public agentMessages; // Messages for agents or clients
    mapping(string => address) public createdAgents; // Tracks agents by name
    IStateConnector public stateConnector; // Flare State Connector
    IFtso public ftso; // Flare FTSO for price feeds
    uint256 public agentCount; // Track number of agents

    // Events for tracking
    event AgentCreated(string indexed agentName, address indexed agentAddress);
    event ToolAdded(uint indexed toolId, string toolDetails);
    event MessageSent(address indexed sender, address indexed recipient, string message);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier onlyAuthorized(address caller) {
        require(
            caller == owner ||
            caller == address(this) ||
            createdAgents[agentName] != address(0),
            "Not authorized"
        );
        _;
    }

    constructor(
        string memory _agentName,
        address _stateConnector,
        address _ftso
    ) {
        agentName = _agentName;
        owner = msg.sender;
        stateConnector = IStateConnector(_stateConnector);
        ftso = IFtso(_ftso);
        agentCount = 0;
    }

    // Create a new BasicAgent
    function createNewAgent(string memory newAgentName) external onlyOwner returns (address) {
        require(createdAgents[newAgentName] == address(0), "Agent name exists");
        BasicAgent newAgent = new BasicAgent(
            newAgentName,
            owner,
            address(this),
            address(stateConnector)
        );
        createdAgents[newAgentName] = address(newAgent);
        agentCount++;
        emit AgentCreated(newAgentName, address(newAgent));
        return address(newAgent);
    }

    // Register an agent
    function registerAgent(string memory agentName, address agentAddress) external {
        require(msg.sender == agentAddress, "Only agent can register");
        require(createdAgents[agentName] == agentAddress, "Agent not created by factory");
    }

    // Add tool or configuration
    function addTool(uint toolId, string memory toolDetails) external onlyAuthorized(msg.sender) {
        require(bytes(toolDetails).length > 0, "Tool details cannot be empty");
        agentData[toolId] = toolDetails;
        emit ToolAdded(toolId, toolDetails);
    }

    // Send message to an agent
    function sendMessage(address recipient, string memory message) external onlyAuthorized(msg.sender) {
        require(recipient != address(0), "Invalid recipient");
        agentMessages[recipient] = message;
        emit MessageSent(msg.sender, recipient, message);
    }

    // Get price feed from FTSO (e.g., for cost estimation)
    function getPriceFeed(address ftsoAsset) external view returns (uint256, uint256) {
        (uint256 price, uint256 timestamp) = ftso.getCurrentPrice(ftsoAsset);
        return (price, timestamp);
    }

    // Retrieve data from an agent
    function getAgentData(address agent, uint toolId) external view returns (string memory) {
        require(createdAgents[agentName] == agent, "Invalid agent");
        return BasicAgent(agent).agentData(toolId);
    }
}