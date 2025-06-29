// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

interface IFtsoRegistry {
    function getFtsoBySymbol(string calldata _symbol) external view returns (address);
    // Additional registry functions can be added as needed
}
