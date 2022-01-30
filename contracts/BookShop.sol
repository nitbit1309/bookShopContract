//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "./BookManager.sol";

contract BookShop is BookManager {
	uint public totalNetSale = 0;
	uint public availableWithdrawAmt = 0;

	address payable public owner;

	event AddBook(uint indexed _id, string _name, uint _price);
	event BookBought(address indexed _buyer, uint indexed _id,  uint price);
	event BookReturned(address indexed _from, uint indexed _id);
	event AmountWithdrawn(address indexed _to, uint _amount);
	// receive() external payable {}

	constructor() payable {
		owner = payable(msg.sender);
	}

	modifier onlyOwner() {
		require(msg.sender == owner, "Caller must be owner of the constract.");
		_;
	}

	function addBook(string memory name, string memory author, uint price) external onlyOwner returns(uint) {
		uint id = _addBook(name, author, price);
		emit AddBook(id, name, price);
		return id;
	}
	function buyBook(uint id) external payable _validBookId(id) {
		require(msg.value >= getBookPrice(id), "Not enough amount.");
		require(address(this) == getBookOwner(id), "Book is already sold.");
		// (bool success, ) = address(this).call{value:msg.value}("");
		// require(success, "Not able to receive payment.");
		address self = address(this);
		// console.log("Inside bookManager, this Address: %s", self);
		_transfer_book(self, msg.sender, id);
		totalNetSale += msg.value;
		availableWithdrawAmt += (msg.value - getBookPrice(id)) + getBookPrice(id)/2;
		emit BookBought(msg.sender, id, msg.value);
	}

	function returnBook(uint id) external {
		_transfer_book(msg.sender, address(this), id);
		(bool success,) = msg.sender.call{value: getBookPrice(id)/2}("");
		require(success, "Payment to caller failed.");
		emit BookReturned(msg.sender, id);
	}

	function withdrawAmount(uint amount) external onlyOwner {
		require(amount <= availableWithdrawAmt, "Insufficient balance.");
		if(amount == 0)
			amount = availableWithdrawAmt;
			
		availableWithdrawAmt -= amount;
		(bool success,) = msg.sender.call{value: amount}("");
		require(success, "Payment to owner failed.");
		emit AmountWithdrawn(msg.sender, amount);
	}

}