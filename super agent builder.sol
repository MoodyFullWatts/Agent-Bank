// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import "./flare/ftso/userInterfaces/IFtso.sol";
import "./flare/ftso/userInterfaces/IFtsoRegistry.sol";
import "./flare/stateConnector/userInterfaces/IStateConnector.sol";
import "./BasicAgent.sol";

interface ISuperAgentBuilder {
    function createAgent(address client, string memory task) external returns (address);
    function getAgent(address client) external view returns (address);
}

contract SuperAgentBuilder is ISuperAgentBuilder {
    IStateConnector public stateConnector;
    IFtso public ftso;
    IFtsoRegistry public ftsoRegistry;
    mapping(address => address) public clientToAgent;
    address public owner;

    event AgentCreated(address indexed client, address agent, string task);

    constructor() {
        stateConnector = IStateConnector(0x0c13aDA1C7143Cf0a0795FFaB93eEBb6FAD6e4e3); // Songbird State Connector
        ftsoRegistry = IFtsoRegistry(0x45eD00B4B23e666Aef72B9730e56095AC7157F62); // Songbird FTSO Registry
        ftso = IFtso(ftsoRegistry.getFtsoBySymbol("SGB/USD")); // Use SGB/USD for Songbird
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
        return stateConnector.requestAttestation(query);
    }

    function getPriceFeed(address asset) public view returns (uint256) {
        (uint256 price, uint256 timestamp) = ftso.getCurrentPrice(asset);
        return price;
    }
}
