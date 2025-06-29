// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./flare/IFlareContractRegistry.sol";
import "./flare/ftso/userInterfaces/IFtso.sol";
import "./flare/ftso/userInterfaces/IFtsoRegistry.sol";
import "./flare/stateConnector/userInterfaces/IStateConnector.sol";
import "./BasicAgent.sol";

interface ISuperAgentBuilder {
    function createAgent(address client, string memory task) external returns (address);
    function getAgent(address client) external view returns (address);
}

contract SuperAgentBuilder is ISuperAgentBuilder {
    IFlareContractRegistry public contractRegistry;
    IStateConnector public stateConnector;
    IFtso public ftso;
    IFtsoRegistry public ftsoRegistry;
    mapping(address => address) public clientToAgent;
    address public owner;

    // Precomputed keccak256 hashes for contract names
    bytes32 private constant STATE_CONNECTOR_HASH = keccak256("StateConnector");
    bytes32 private constant FTSO_V2_HASH = keccak256("FtsoV2");

    event AgentCreated(address indexed client, address agent, string task);

    constructor(address _contractRegistry) {
        contractRegistry = IFlareContractRegistry(_contractRegistry);
        // Batch fetch StateConnector and FtsoV2 addresses
        bytes32[] memory nameHashes = new bytes32[](2);
        nameHashes[0] = STATE_CONNECTOR_HASH;
        nameHashes[1] = FTSO_V2_HASH;
        address[] memory addresses = contractRegistry.getContractAddressesByHash(nameHashes);
        stateConnector = IStateConnector(addresses[0]);
        ftsoRegistry = IFtsoRegistry(addresses[1]);
        ftso = IFtso(ftsoRegistry.getFtsoBySymbol("SGB/USD")); // Songbird SGB/USD feed
        owner = msg.sender;
    }

    function createAgent(address client, string memory task) external override returns (address) {
        require(clientToAgent[client] == address(0), "Agent already exists for client");
        BasicAgent newAgent = new BasicAgent(address(this), client, task);
        clientToAgent[client] = address(newAgent);
        emit AgentCreated(client, address(newAgent), task);
        return address(newAgent);
    }

    function getAgent(address client) external view override returns (address) {
        return clientToAgent[client];
    }

    function fetchExternalData(string memory query) public returns (bytes memory) {
        return stateConnector.requestAttestation(abi.encode(query));
    }

    function getPriceFeed(address asset) public view returns (uint256) {
        (uint256 price, uint256 timestamp) = ftso.getCurrentPrice(asset);
        return price;
    }
}
