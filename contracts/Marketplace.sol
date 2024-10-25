// SPDX-License-Identifier: MIT
pragma solidity ^0.8.27;

contract Marketplace {
    address public owner;
    
    struct Item {
        string name;
        uint256 price;
        address seller;
        bool isAvailable;
    }
    
    Item[] public items;
    
    event ItemListed(uint256 indexed itemId, string name, uint256 price, address seller);
    event ItemSold(uint256 indexed itemId, string name, uint256 price, address seller, address buyer);
    
    constructor() {
        owner = msg.sender;
    }
    
    function listItem(string memory _name, uint256 _price) external {
        require(_price > 0, "Price must be greater than 0");
        require(bytes(_name).length > 0, "Name cannot be empty");
        
        items.push(Item({
            name: _name,
            price: _price,
            seller: msg.sender,
            isAvailable: true
        }));
        
        emit ItemListed(items.length - 1, _name, _price, msg.sender);
    }
    
    function buyItem(uint256 _itemId) external payable {
        require(_itemId < items.length, "Item does not exist");
        Item storage item = items[_itemId];
        require(item.isAvailable, "Item is not available");
        require(msg.value == item.price, "Incorrect payment amount");
        require(msg.sender != item.seller, "Seller cannot buy their own item");
        
        item.isAvailable = false;
        
        // Transfer payment to seller
        (bool success, ) = payable(item.seller).call{value: msg.value}("");
        require(success, "Transfer failed");
        
        emit ItemSold(_itemId, item.name, item.price, item.seller, msg.sender);
    }
    
    function getItem(uint256 _itemId) external view returns (
        string memory name,
        uint256 price,
        address seller,
        bool isAvailable
    ) {
        require(_itemId < items.length, "Item does not exist");
        Item storage item = items[_itemId];
        return (item.name, item.price, item.seller, item.isAvailable);
    }
    
    function getItemCount() external view returns (uint256) {
        return items.length;
    }
    
    function getAvailableItems() external view returns (uint256[] memory) {
        uint256 availableCount = 0;
        
        // First count available items
        for (uint256 i = 0; i < items.length; i++) {
            if (items[i].isAvailable) {
                availableCount++;
            }
        }
        
        // Create array of available item IDs
        uint256[] memory availableItems = new uint256[](availableCount);
        uint256 currentIndex = 0;
        
        for (uint256 i = 0; i < items.length; i++) {
            if (items[i].isAvailable) {
                availableItems[currentIndex] = i;
                currentIndex++;
            }
        }
        
        return availableItems;
    }
}