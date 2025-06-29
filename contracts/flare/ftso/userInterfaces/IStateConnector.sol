// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

interface IStateConnector {
    function requestAttestation(bytes calldata _data) external returns (bytes memory);
}
