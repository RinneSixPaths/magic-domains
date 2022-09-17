// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;

import "hardhat/console.sol";

contract Domains {
  // A "mapping" data type to store their names
  mapping(string => address) public domains;

  mapping(string => string) public records;

  constructor() {
    console.log("THIS IS A MAGIC DOMAINS CONTRACT!");
  }

  // A register function that adds their names to our mapping
  function register(string calldata name) public {
      require(domains[name] == address(0));
      domains[name] = msg.sender;
      console.log("%s has registered a domain!", msg.sender);
  }

  // This will give us the domain owners' address
  function getAddress(string calldata name) public view returns (address) {
      return domains[name];
  }

  function setRecord(string calldata name, string calldata record) public {
      require(domains[name] == msg.sender);
      records[name] = record;
  }

  function getRecord(string calldata name) public view returns(string memory) {
      return records[name];
  }
}
