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

  string public constant gryffindorColor = '#FF8C8C';
  string public constant slytherinColor = "#8CFFB3";
  string public constant hufflepuffColor = "#FDFF8C";
  string public constant ravenclawColor = "#8CBAFF";

  string private svgBeforeColor = '<svg xmlns="http://www.w3.org/2000/svg" width="270" height="270" fill="none"><g clip-path="url(#clip0_2_4)"><rect width="270" height="270" fill="white"/><rect width="270" height="270" fill="';
  string private svgAfterColorBeforeText = '"/><rect x="113" y="127" width="57" height="46" fill="url(#pattern0)"/><rect x="99" y="97" width="54" height="48" fill="url(#pattern1)"/></g><defs><pattern id="pattern0" patternContentUnits="objectBoundingBox" width="1" height="1"><use href="#image0_2_4" transform="translate(0.0964912) scale(0.00840643 0.0104167)"/></pattern><pattern id="pattern1" patternContentUnits="objectBoundingBox" width="1" height="1"><use href="#image1_2_4" transform="translate(0.0555556) scale(0.00925926 0.0104167)"/></pattern><clipPath id="clip0_2_4"><rect width="270" height="270" fill="white"/></clipPath><image id="image0_2_4" width="96" height="96" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAABmJLR0QA/wD/AP+gvaeTAAADqElEQVR4nO2dOWgVURRAz8TEDQVRUQRBI1jERkEhBDdU0MJWEJt0BtTe0l0TCws3BG0sFRUsBAUllYiphICFAa0SU8WfTSJiHIuXjzHO/7O+d2e5B271YebecydvJu+9Px8UF3QAz4FxYAZ4BWwXzahCdAI1wF8QU2gTrNOJueoXyq/HS7nUyk+YfB8zHCkWiCLfB75LJVhmosr3gWdCOZaWOPJrwBaZNMvJTuAb0eSPY5qlZITKF0TlC6LyBVH5gqh8QVS+ICpfEJUviMoXROULovIFUfmCqHxBthK8hqvyHfEQlS/KECpflAlUvihhDdgjl1o1mKJ5A1ZkebKWLA9WEryQz/0sT6YN+J8wJ79dnqyK6F+AME4b0JrlwQpAK7CywWe1iMfItAFVYRtmT/4vov2X2yzaHOdeeOJsF4wSi9ymX2zizGpGjbB7hDKHDfk6/kck62GnHhMuiygqtuT7wFOHdRQSm/LHMIs1SgPiyP+JuT/Uo9kE3DjwGNjorpTioWu4gqh8QVS+Q5YDezES24g35qv8lPQA0/wVOkL40qHKz4gLJH90VPkpUfmCVEK+y5m9pcA+4Cjm6WU9sGHus69z8RZ4AxwAziU8zwRwBBhIk2yZWAv0ApPYmSIo5JXvghbgLOH7bLKMEaq3zBrIOswSoCvx82OXg/pyzWFgFBn5PrDbfon5ZAlwA7NxSUr+JLDMdqF5pAP4gJz4epy0XWge6ebfaQKpOG+70LyxCniEvPhKyj8IDCMvvnLyFwPXgVnkxfvARbvl5ot24B3y0ufHfqsVOyDq7uhuYBDosphLEg5JJ2Cb1cAT5K/0RtFvr3R5uoAvyEtuFkPWqhfEwzxZ5OVG2yymLDkQ5RTyYqPGtCUHonxCXmzU+GzJgTOCnoLanWeRnFHpBNIS1IAi3djeSyeQlqAG9DnPIjmvpROwxRXkx/ewGKPkc/+XkZfcLCoxD3QNedFBMY1Zd64EeRyOzlitOIf0IS+9Hv1U9KuiV5GXXwM22S40z0jfE47bLzH/SDXhnoviikIvbuV/xHxDRpmHqybMoD962RAXT0ennVVTQDzgJvbkv6Cij5xxsNWEYWCNwzoKjQfcIjv5s5jNX0oMsmzCJce5lwYPuE06+QPoe9lS4QF3SCa/Bmx2n3L5SNqEExLJlhUPuEt0+fdl0iw3UZswRMZvJVf+EtaEH8AOsewqQgvwgOAG9AjmVSk8zFLiIOZ1Av3AMdGMFEVRFEWQP6wuftOeiDntAAAAAElFTkSuQmCC"/><image id="image1_2_4" width="96" height="96" href="data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAGAAAABgCAYAAADimHc4AAAABmJLR0QA/wD/AP+gvaeTAAAEV0lEQVR4nO2dSYsVSRCAP22nsUEd2tZxxV0PKq4g6rjg0nr1IjNe1H/g0asiKM5h8DBzmF8gqODdBUVQPAyouCAKCoJLi9BttzIy3doe4hWI9vK6KjMjqio+CB40r7MiMioiMyOz6oHjOI7jOI7jOE549gNvgcFA8gF4AJwBVia0o9RMB84RzgmZfAb+BlrTmVJuQkdDJldxJzRNrGj4K6URVSB0NAwAK5JaUAHagX8I54Q/06pfHUJFw/3UileJENHQm1zrClI0ChalVzk/47UViMBubQXGQhUdsEtbgbJTNAW9o5o3VjKOUtwJ65NrnZMWbQWG4CbwiWK5/FmjHacARSLhkoK+lSSvE/4D2hT0rRzzyB8FpZiOWp8t/Frgf0sxHa2yA0oRAda5Q/4U9BmYll7l6jAZqfEXWQ/sT671GLGcgjZRfJ1ifhyw7IAi+T9jb4A2assVipckzJenrUZAC7AhUFumZ0NWHbAaGYRDYHocsOqAEPk/Yxd27TSrWEgHdABrA7YXFKsO2By4PdPjgDWKFOC8PB2AA4R3gNnytMUUFDL/Z0yM1G5hLDpgS6R2TU9HrTCF4gW44eTfhHaUlj3E6Xyz5WlrKShmnh4P7IjYfi7q5ADwcWBEWpDTzbFS0CDwPJk1JWQdcTs/E1PlaUspKNU83VRZoo4O8HFgGF6QJgX56ekhmE+azs/EzOlpK3dC6jqNmXHAHeAAcJe0KchseVqDmAW4kcREFFhIQRvReVLHxHTUggO0Nko6la5rjlAn4MYqJsrT2hEQ8gTcWDFRntZ2wBrCnYDLg/o4oO0A7Y1y9dPTdXfAApTL09oOCH0CLg+q6wFNB8wH5ipeP6O2DtBOPxk7UeyHCQmvNRN50epK5OV66jOQBh3AbeAe8PAbeZXi4uMitTsB2ePdDGxF7vYZka4Vi9fICz9uAreQR2b7VTUahQ7gIHAB6ENndRtTeoHzDRvVV9AZrcDvyJtrNSqaWjKAlFB+Q+mNvdOAU0BXE8pWXbqAk0gGiE4rcAToTmRcmaQPOEbEjZ6lyOxA21Dr8hhYnrOPh6UTeG/AuLJIDwEXeMuo5qwmtvQCS3L09w/EeNV8XeTsaJ3bzEKsB/i5ie85P9INTB3pC83UQP4Po0stGXXl3IwDLgdQpK4EeT55KT4DyiM9wOIc/T0kncjPR2kbVRbpI0K1dzXw1IBx1uUJsCpnH49KG3AC+GjAUGvyETiOPJUfnV+AP/Ca0GCjD043+iQ5bcBh4Dr1K0dfAw5RsPgWckdsJrAPGbC3YWjTIhDvgBvItPwiUoYuTKwtyXHIvu/2hmyjfFuSb5AOv4FE+CPk7g9KLAcMRTtyCGoFUq7NPhcm1uN7upHOffjN57OGREfT8IzJwBxkEJuNRMoMYFbjb+3IRtBEJN/+BExCVvFZjeo98AVZq/QjT8B8Qsoo3ciPxL1G0kYXcuLhLfASmbM7juM4juM4juMk4yuQG2t+5imTSgAAAABJRU5ErkJggg=="/></defs><text x="50%" y="80%" dominant-baseline="middle" text-anchor="middle" font-size="15" fill="black" font-family="Plus Jakarta Sans,DejaVu Sans,Noto Color Emoji,Apple Color Emoji,sans-serif" font-weight="bold">';
  string private lastAfterText = '</text></svg>';

  uint private price = 0.001 ether;
  address payable private headmaster;

  mapping (string => address) public domains;
  mapping (string => string) public records;
  mapping (address => bool) public domainTracker;

  mapping (uint => string) public names;

  event WelcomeToHogwarts(address indexed newcomer, string name, string faculty);

  // TODO fill up record with some meaningfull info

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
    return StringUtils.strlen(name) >= 3 && StringUtils.strlen(name) <= 10;
  }

  function _getPseudoRand(uint nonce) private view returns(uint randomNumber) {
    randomNumber = uint(uint256(keccak256(abi.encodePacked(block.timestamp, nonce, block.difficulty, msg.sender))) % 100);
  }

  function _getSortingHatDecision(uint magicNumber) private pure returns(string memory faculty, string memory color) {
    if (magicNumber >= 0 && magicNumber <= 25) {
      faculty = gryffindorSld;
      color = gryffindorColor;
    } else if (magicNumber >= 26 && magicNumber <= 50) {
      faculty = slytherinSld;
      color = slytherinColor;
    } else if (magicNumber >= 51 && magicNumber <= 75) {
      faculty = hufflepuffSld;
      color = hufflepuffColor;
    } else if (magicNumber >= 76 && magicNumber <= 100) {
      faculty = ravenclawSld;
      color = ravenclawColor;
    }
  }

  function applyToHogwarts(string calldata name, uint nonce) public payable {

    require(domains[name] == address(0), "Name already exists");
    require(valid(name), "Invalid name");
    require(!domainTracker[msg.sender], "Address already applied");
    require(msg.value >= price, "Not enough Matic paid");

    uint magicNumber = _getPseudoRand(nonce);
    (string memory faculty, string memory color) = _getSortingHatDecision(magicNumber);

    // Combine the name passed into the function  with the TLD
    string memory _name = string(abi.encodePacked(name, ".", faculty, ".", tld));

    // Create the SVG (image) for the NFT with the name
    string memory finalSvg = string(abi.encodePacked(svgBeforeColor, color, svgAfterColorBeforeText, _name, lastAfterText));
    uint256 newRecordId = _tokenIds.current();
    uint256 length = StringUtils.strlen(name);
    string memory strLen = Strings.toString(length);

    // TODO: store at IPFS
    string memory json = Base64.encode(
      abi.encodePacked(
        '{"name": "',
        _name,
        '", "description": "A student at Hogwarts", "image": "data:image/svg+xml;base64,',
        Base64.encode(bytes(finalSvg)),
        '","length":"',
        strLen,
        '"}'
      )
    );

    string memory finalTokenUri = string(abi.encodePacked("data:application/json;base64,", json));

    _safeMint(msg.sender, newRecordId);
    _setTokenURI(newRecordId, finalTokenUri);
    domains[name] = msg.sender;
    domainTracker[msg.sender] = true;
    names[newRecordId] = _name;

    _tokenIds.increment();

    emit WelcomeToHogwarts(msg.sender, name, faculty);
  }

  function getAddress(string calldata name) public view returns (address) {
      return domains[name];
  }

  function setRecord(string calldata name, string calldata record) public {
      require(msg.sender == domains[name], "No permission to modify the record");

      records[name] = record;
  }

  function getRecord(string calldata name) public view returns(string memory) {
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
