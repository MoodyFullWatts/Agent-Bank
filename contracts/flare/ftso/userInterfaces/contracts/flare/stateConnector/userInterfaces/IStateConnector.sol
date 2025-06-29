// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IStateConnector {
    function requestAttestation(string calldata _data) external returns (bytes memory);
    // Additional State Connector functions can be added as needed
}
