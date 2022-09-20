// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import { StringUtils } from "./libraries/StringUtils.sol";
import { Base64 } from "./libraries/Base64.sol";

contract HogwartsStudentsService is ERC721URIStorage {

  using Counters for Counters.Counter;
  Counters.Counter private _tokenIds;

  string public constant tld = "hgwrts";

  string public constant gryffindorSld = "gryffindor";
  string public constant slytherinSld = "slytherin";
  string public constant hufflepuffSld = "hufflepuff";
  string public constant ravenclawSld = "ravenclaw";

  string public constant gryffindorID = 'Qmbu5wVX4yrmxT8FPGpBvtVbGb4JqdMvqWGYmb111EAUvu';
  string public constant slytherinID = "QmdEvQwRwAhZEmWaYUegwcJs5tyVUWQ3EazKx1CT6da5Uz";
  string public constant hufflepuffID = "QmZLwrMpzUAu4gJE9rYZSrs17NvuH2E9iXYeRyXDeAaDDM";
  string public constant ravenclawID = "QmZEZ1Ep5wgCUkVz31A3GLTRkRK4WfpAn3ZCXZfM6vsAHh";

  // string public constant gryffindorColor = '#FF8C8C';
  // string public constant slytherinColor = "#8CFFB3";
  // string public constant hufflepuffColor = "#FDFF8C";
  // string public constant ravenclawColor = "#8CBAFF";

  uint private price = 0.001 ether;
  address payable private headmaster;

  struct HogwartsStudent {
    string domain;
    uint applicationDate;
    string faculty;
    string patronus;
    address applicant;
  }

  mapping (string => address) public domains;
  mapping (string => HogwartsStudent) public records;
  mapping (address => bool) public domainTracker;

  mapping (uint => string) public names;

  event WelcomeToHogwarts(address indexed newcomer, string name, string faculty);

  modifier onlyHeadmaster() {
    require(isOwner());
    _;
  }

  constructor() payable ERC721("Hogwarts Students Service", "HSS") {
    headmaster = payable(msg.sender);
  }

  function isOwner() public view returns (bool) {
    return msg.sender == headmaster;
  }

  function valid(string calldata name) public pure returns(bool) {
    return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 20;
  }

  function _getPseudoRand(uint nonce) private view returns(uint randomNumber) {
    randomNumber = uint(uint256(keccak256(abi.encodePacked(block.timestamp, nonce, block.difficulty, msg.sender))) % 100);
  }

  function _getSortingHatDecision(uint magicNumber) private pure returns (string memory faculty, string memory ipfsID) {
    if (magicNumber >= 0 && magicNumber <= 25) {
      faculty = gryffindorSld;
      // color = gryffindorColor;
      ipfsID = gryffindorID;
    } else if (magicNumber >= 26 && magicNumber <= 50) {
      faculty = slytherinSld;
      // color = slytherinColor;
      ipfsID = slytherinID;
    } else if (magicNumber >= 51 && magicNumber <= 75) {
      faculty = hufflepuffSld;
      // color = hufflepuffColor;
      ipfsID = hufflepuffID;
    } else if (magicNumber >= 76 && magicNumber <= 100) {
      faculty = ravenclawSld;
      // color = ravenclawColor;
      ipfsID = ravenclawID;
    }
  }

  function applyToHogwarts(string calldata name, string calldata patronus, uint nonce) public payable {

    require(domains[name] == address(0), "Name already exists");
    require(valid(name), "Invalid name");
    require(!domainTracker[msg.sender], "Address already applied");
    require(msg.value >= price, "Not enough Matic paid");

    uint magicNumber = _getPseudoRand(nonce);
    (string memory faculty, string memory ipfsID) = _getSortingHatDecision(magicNumber);

    string memory domain = string(abi.encodePacked(name, ".", faculty, ".", tld));

    uint256 newRecordId = _tokenIds.current();

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, string(abi.encodePacked("ipfs://", ipfsID)));
    domains[domain] = msg.sender;
    domainTracker[msg.sender] = true;
    names[newRecordId] = domain;

    _setRecord(domain, patronus, faculty);
    _tokenIds.increment();

    emit WelcomeToHogwarts(msg.sender, name, faculty);
  }

  function getAddress(string calldata name) public view returns (address) {
      return domains[name];
  }

  function _setRecord(string memory domain, string calldata patronus, string memory faculty) private {
      require(msg.sender == domains[domain], "No permission to modify the record");

      records[domain] = HogwartsStudent(
        domain,
        block.timestamp,
        faculty,
        patronus,
        msg.sender
      );
  }

  function getRecord(string calldata name) public view returns(HogwartsStudent memory) {
      return records[name];
  }

  function getAllNames() public view returns (string[] memory) {
    string[] memory allNames = new string[](_tokenIds.current());

    for (uint i = 0; i < _tokenIds.current(); i++) {
      allNames[i] = names[i];
    }

    return allNames;
  }

  function withdraw() public onlyHeadmaster {
    uint amount = address(this).balance;
    
    (bool success, ) = msg.sender.call{ value: amount }("");
    require(success, "Failed to withdraw Matic");
  }
}
