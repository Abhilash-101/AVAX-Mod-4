// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DegenToken is ERC20, Ownable {

    enum ItemType { IRON , DIAMOND, NETHERITE }

    // Item prices in AVAX
    mapping(ItemType => uint256) public itemPrices;

    // Item quantities
    mapping(ItemType => uint256) public itemQuantities;

    // Item quantities owned by each account
    mapping(address => mapping(ItemType => uint256)) public accountItems;

    constructor(address initialOwner) Ownable(initialOwner) ERC20("Degen", "DGN") {
        itemPrices[ItemType.IRON] = 100;
        itemPrices[ItemType.DIAMOND] = 200;
        itemPrices[ItemType.NETHERITE] = 500;

        itemQuantities[ItemType.IRON] = 100;
        itemQuantities[ItemType.DIAMOND] = 100;
        itemQuantities[ItemType.NETHERITE] = 100;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function transferTokens(address recipient, uint256 amount) external {
        _transfer(msg.sender, recipient, amount);
    }

    function redeemTokens(ItemType itemType, uint256 quantity) external {
        require(balanceOf(msg.sender) >= itemPrices[itemType] * quantity, "Insufficient balance for redemption");
        require(itemQuantities[itemType] >= quantity, "Insufficient quantity of the item");

        // Update account items
        accountItems[msg.sender][itemType] += quantity;

        _burn(msg.sender, itemPrices[itemType] * quantity);
        itemQuantities[itemType] -= quantity;
    }


    function burnTokens(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    function viewInStoreItems() external view returns (string memory output) {
        uint256[3] memory quantities;
        quantities[0] = itemQuantities[ItemType.IRON];
        quantities[1] = itemQuantities[ItemType.DIAMOND];
        quantities[2] = itemQuantities[ItemType.NETHERITE];

        output = string(abi.encodePacked(
            "IRON: ", toString(quantities[0]),
            ", DIAMOND: ", toString(quantities[1]),
            ", NETHERITE: ", toString(quantities[2])
        ));

        return output;
    }

    // View items owned by an account
    function viewOwnedItems(address account) external view returns (string memory output) {
        uint256[3] memory ownedQuantities;
        ownedQuantities[0] = accountItems[account][ItemType.IRON];
        ownedQuantities[1] = accountItems[account][ItemType.DIAMOND];
        ownedQuantities[2] = accountItems[account][ItemType.NETHERITE];

        output = string(abi.encodePacked(
            " IRON: ", toString(ownedQuantities[0]),
            ", DIAMOND: ", toString(ownedQuantities[1]),
            ", NETHERITE: ", toString(ownedQuantities[2])
        ));

        return output;
    }

    // Helper function to convert uint256 to string
    function toString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }
}