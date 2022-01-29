# bookShopContract
======================
Ethereum based smart contract for book shop
======================
Key highlights
-------------------
1. Only owner of the smart contract (Book Shop Owner) can add new books to contract.
2. Books will have below properties
	1. name: Name of the book (Mandatory)
	2. author: Author of the book (Optional)
	3. Price: Price of the book (Optional i.e. Free books)

3. Any one can buy the book by paying the amount equal to price of the book.
4. Owner of the contract can withdraw the amount from contract.
4. Users can return their books to the Shop Owner at half the price. Upon returning the book, amount will get credited to the customer's account. 
	 [P.S: This condition is interesting one. It enforces that Owner will never be able to withdraw full balance. Half of the amount of all the sale needs to be in the contract.]

---------------------------------------------
Development notes
---------------------------------------------
	Public/External:
		View:
			getAllBooks() view public returns(string[] memory bookIds);
			getBookName(uint bookId) view public returns(string memory name);
			getBookAuthor(uint bookId) view public returns(string memory author);
			getBookPrice(uint bookId) view public returns(uint price);
			getBookOwner(uint bookId) view public returns(address owner);
			getAvailableWithdrawAmount() view public returns(uint amount);

		Transactions:

			addNewBook(string memory name, string memory author, uint amount) public onlyOwner returns(uint);
				Conditions:
					1. Caller must be the Owner of the contract.
				Functionaltiy:
					1. Owner of the new book will be contract itself.
					2. BookId will be returned.

			buyBook(uint bookId) public payable ();
				Conditions:
					1. Contract must be the owner of this book.
					2. Input amount(msg.value) must be grater than or equal to book price
					3. bookId must be valid
				Functionality:
					1. Book will be owned by the caller
					2. Contract balance will be increased by the amount sent with the function call.

			withdraw(address payable to, uint amount) public onlyOwner();
				condition:
					1. Only owner can withdraw the funds
					2. Only half of the NET sale amount can be withdrawn at any moment.
					3. to address must not be 0x00
				Functionality:
					1. Owner's account will get funded by the 'amount'
					2. Contract balance will get decreased bt 'amount'

			returnBook(uint bookId) public ();
				conditions:
					1. bookId must be valid.
					2. Only owner of this book can return the book.
				Functionality:
					1. The amount equal to half the price of the book, will get transferred to msg.sender account.
					2. The contract balance will get decreased by half the price of the book.
					3. Owner's withdrawable balance will get increased by half the price of the book.


	Internals:
		Data Structures:
			struct Book {
				string name,
				string author,
				uint price	//Price in wei
			}
			uint totalSale	//Need to track how much sale has been done to enforce the withdraw amount for owner
			Mapping(address=>uint[])	//Customer Address => booksId array
			Mapping (uint => address)	//BookId => Customer Address
			mapping(address => mapping(uint=>uint)) // Customer Address to BookId to Index in customer's bookId Array
				//This mapping enables us not to use any loops in customer's book array while removing the book from array
				//TODO Need to do cost profiling between storage and computation for above approach


