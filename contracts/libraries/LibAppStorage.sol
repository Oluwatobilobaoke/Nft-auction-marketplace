// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LibERC20} from "./LibERC20.sol";

library LibAppStorage {


    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 indexed _tokenId
    );


    struct AppStorage {
        //ERC20
        string name;
        string symbol;
        uint256 totalSupply;
        uint8 decimals;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;

        //ERC721
        // Token name
        string private _name;
        // Token symbol
        string private _symbol;
        mapping(uint256 tokenId => address) private _owners;
        mapping(address owner => uint256) private _balances;
        mapping(uint256 tokenId => address) private _tokenApprovals;
        mapping(uint256 tokenId => string) tokenURI;
        mapping(address owner => mapping(address operator => bool)) private _operatorApprovals;

        //ERC 1155

    }

  
    function _transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) internal {
        _transfer(_from, _to, _tokenId);
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        AppStorage storage l = getStorage();
        require(
            _from != address(0),
            "ERC721: transfer of token that is not own"
        );
        require(_to != address(0), "ERC721: transfer to the zero address");
        require(
            l.owners[_tokenId] == msg.sender ||
                l.tokenApprovals[_tokenId] == msg.sender,
            "ERC721: transfer caller is not owner nor approved"
        );
        require(
            l.owners[_tokenId] == _from,
            "ERC721: transfer of token that is not own"
        );
        l.tokenApprovals[_tokenId] = address(0);
        l.owners[_tokenId] = _to;
        l.balances[_from]--;
        l.balances[_to]++;
        emit Transfer(_from, _to, _tokenId);
    }

    // ERC20
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        AppStorage storage l = getStorage();
        uint256 _allowance = l.allowances[_from][msg.sender];
        if (msg.sender != _from || _allowance < _value) {
            revert("LibAppStorage: transfer amount exceeds allowance");
        }
        l.allowances[_from][msg.sender] = _allowance - _value;
        transfer(_from, _to, _value);
    }

    function transfer(
        address _to,
        uint256 _value
    ) internal {
        AppStorage storage s = getStorage();
        require(s.balances[msg.sender] >= _value, "LibAppStorage: transfer amount exceeds balance");
        l.balances[msg.sender] -= _value;
        l.balances[_to] += _value;
        emit LibERC20.Transfer(_from, _to, _amount);
    }

    function getStorage() internal pure returns (AppStorage storage l) {
        assembly {
            l.slot := 0
        }
    }
}
