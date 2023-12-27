// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// File contracts/TeloToken.sol


contract TeloToken is Ownable,ERC20, ReentrancyGuard {
    uint256 public constant MAX_SUPPLY = 808808808808808 ether;
    bool public limited;
    uint256 public maxHoldingAmount = MAX_SUPPLY/100;
    uint256 public minHoldingAmount;
    address public pancakeSwapPair;
    mapping(address => bool) public blacklists;
    address public receiver; // Receiver of 0.5% of every transaction
    
    constructor() ERC20("Telo Token", "TELO") Ownable(msg.sender) {
        receiver = 0x2546E3468eC42849169E9109CEE6EE7A3695F4e6; // Assign the receiver address first
        require(receiver != address(0), "Receiver cannot be the zero address"); // Then check if it's not the zero address
        _mint(msg.sender, MAX_SUPPLY); // Mint the max supply to msg.sender
}


    function blacklist(address _address, bool _isBlacklisting) external onlyOwner {
        blacklists[_address] = _isBlacklisting;
    }

    function setRule(bool _limited, address _pancakeSwapPair, uint256 _maxHoldingAmount, uint256 _minHoldingAmount) external onlyOwner {
        require(_pancakeSwapPair != address(0), "PancakeSwap pair cannot be the zero address");
        require(_maxHoldingAmount <= MAX_SUPPLY, "Max holding amount exceeds supply");
        require(_minHoldingAmount >= 0, "Min holding amount cannot be negative");
    
        limited = _limited;
        pancakeSwapPair = _pancakeSwapPair; // Renamed variable
        maxHoldingAmount = _maxHoldingAmount;
        minHoldingAmount = _minHoldingAmount;
}

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
    require(!blacklists[to] && !blacklists[from], "Blacklisted");

    if (limited && from == pancakeSwapPair) {
        require(super.balanceOf(to) + amount <= maxHoldingAmount && super.balanceOf(to) + amount >= minHoldingAmount, "Forbid");
    }

    uint256 transferTax = amount * 5 / 1000; // 0.5% of the value
    _transfer(from, receiver, transferTax);

    burnOnTransfer(from, amount);
    }

    function burnOnTransfer(address from, uint256 value) internal {
     uint256 burnAmount = value * 5 / 1000; // 0.5% of the value
        _burn(from, burnAmount);
    }


    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }

    function buyTokens(uint256 amount) external nonReentrant {
        require(amount <= MAX_SUPPLY / 1000, "Exceeds 1% of the total supply");
        _transfer(address(this), msg.sender, amount);
}

    function renounceOwnership() public virtual onlyOwner override{
        renounceOwnership();
    }
}