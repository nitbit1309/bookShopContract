//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

// import "hardhat/console.sol";

contract BookManager {
	struct Book {
		string name;
		string author;
		uint price; //Price in wei
	}

	Book[] public books;
	uint private nextBookId = 1;	//No book Id with 0 //index will be (bookId-1)

	mapping(uint => address) private mapBookToOwner;	//BookId=>Owner

	mapping(address=>uint[]) private mapOwnersToBooks;	//Owner=>BookIds[]
	mapping(address=>mapping(uint=>uint)) private mapOwnersToBooksToIndex;	//Owner=>BookId=>Index 
	//Array Index = Index - 1

	modifier _validBook(uint id) {
		require(id !=0 && id <= books.length, "Not a valid book id");
		_;
	}

	function _addBook(string memory name, string memory author, uint price) internal returns(uint id) {
		address self = address(this);
		// console.log("Inside bookManager, this Address: %s", self);
		books.push(Book(name, author, price));
		mapBookToOwner[nextBookId] = self;
		mapOwnersToBooks[self].push(nextBookId);
		mapOwnersToBooksToIndex[self][nextBookId] = mapOwnersToBooks[self].length;

		// console.log('New book added. id: %d, books_len: %d, owner: %s', nextBookId, books.length, mapBookToOwner[nextBookId]);
		return nextBookId++;
	}

	function _transfer_book(address from, address to, uint bookId) internal _validBook(bookId) {
		require(mapBookToOwner[bookId] == from, "Book must be owned by transferee");

		uint index = 0;
		
		//Update global book to owner mapping
		mapBookToOwner[bookId] = to;

		//Update new owner specific mapping for the bookId
		mapOwnersToBooks[to].push(bookId);
		mapOwnersToBooksToIndex[to][bookId] = mapOwnersToBooks[to].length;

		//Update old owner specific mapping
		index = mapOwnersToBooksToIndex[from][bookId];
		uint listSize = mapOwnersToBooks[from].length;

		assert(index != 0); //Always must be greater than 0 if the book was owned by {from}

		mapOwnersToBooksToIndex[from][bookId] = 0;
		mapOwnersToBooks[from][index-1] = 0;
		if(listSize != 1 && index != listSize) {
			mapOwnersToBooks[from][index-1] = mapOwnersToBooks[from][listSize-1];
			// mapOwnersToBooks[from][listSize-1] = 0;
			uint id = mapOwnersToBooks[from][index-1];
			mapOwnersToBooksToIndex[from][id] = index;
		}
		mapOwnersToBooks[from].pop();
	}

	function getAllBooks() external view returns(uint[] memory) {
		// console.log("books array length: %s", books.length);
		uint[] memory bookIds = new uint[](books.length);
		for (uint i = 0; i<books.length; i++) {
			bookIds[i] = i+1;
		}
		return bookIds;
	}

	function getBookName(uint bookId) external view _validBook(bookId) returns(string memory bookName) {
		return books[bookId-1].name;
	}

	function getBookAuthorName(uint bookId) external view _validBook(bookId) returns(string memory bookAuthor) {
		return books[bookId-1].author;
	}

	function getBookPrice(uint bookId) public view _validBook(bookId) returns(uint bookPrice) {
		return books[bookId-1].price;
	}

	function getBookOwner(uint bookId) public view _validBook(bookId) returns(address bookOwner) {
		return mapBookToOwner[bookId];
	}
}