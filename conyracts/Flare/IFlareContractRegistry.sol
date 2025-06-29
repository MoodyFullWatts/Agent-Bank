// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;

interface IFlareContractRegistry {
    function getContractAddressByName(string calldata _name) external view returns (address);
    function getContractAddressByHash(bytes32 _nameHash) external view returns (address);
    function getContractAddressesByHash(bytes32[] calldata _nameHashes) external view returns (address[] memory);
}
