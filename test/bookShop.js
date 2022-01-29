const {expect} = require("chai");

describe("BookShop Contract Basic", function() {
	let owner, addr1;
	let BookShop;
	let bc;

	beforeEach(async function() {
		BookShop = await ethers.getContractFactory("BookShop");
		[owner, addr1] = await ethers.getSigners();
		bc = await BookShop.deploy();
	});

	it("Deployment should assign owner to the contract deployer", async function() {
		expect(await bc.owner()).to.equals(owner.address);
	});

	it("AddBook should add new book with all the attributes", async function() {
		await bc.addBook("MyBook", "Nitin", 500000000);
		var name = await bc.getBookName(1);
		var author = await bc.getBookAuthorName(1);
		var price = await bc.getBookPrice(1);

		expect(name).to.equals("MyBook");
		expect(author).to.equals("Nitin");
		expect(price).to.equals(500000000);

	})
	it("AddBook should add book with book owner as contract address", async function () {
		// arraySize = bc.books().length;
		await bc.addBook("MyBook", "Nitin", 500000000);
		var bookOwner = await bc.getBookOwner(1);
		expect(bookOwner).to.equals(bc.address);
	});

	it("BuyBook should transfer the book to caller if value is equal to the price of book", async function() {
		await bc.addBook("MyBook1", "Nitin", 500000000);

		await bc.connect(addr1).buyBook(1, {value: 500000000});
		// console.log(await bc.getBookOwner(1));
		expect(await bc.getBookOwner(1)).to.equals(addr1.address);
	});

	it("BuyBook should increase the contract balance by the deposited amount.", async function() {
		await bc.addBook("MyBook1", "Nitin", 500000000);
		await bc.connect(addr1).buyBook(1, {value: 500000000});

		expect(await bc.provider.getBalance(bc.address)).to.equals(500000000);
	})
});

describe("BookShop contract Advanced", function() {
	let owner, addr1, addr2;
	let BookShop;
	let bc;

	beforeEach(async function() {
		[owner, addr1, addr2] = await ethers.getSigners();
		BookShop = await ethers.getContractFactory("BookShop");
		bs = await BookShop.deploy();

		await bs.addBook("Book1", "Author1", 50000000);
		await bs.addBook("Book2", "Author2", 55000000);
		await bs.addBook("Book3", "Author3", 55500000);
		await bs.addBook("Book4", "Author4", 55550000);
		await bs.addBook("Book5", "Author5", 101);
	});

	it("Owner Should withdraw half of the sale", async function() {
		let ownerInitialBal = await bs.provider.getBalance(owner.address);
		// await bs.connect(addr1).buyBook(1);
		// await bs.connect(addr1).buyBook(2);
		// await bs.connect(addr1).buyBook(3);
		console.log("ownerInitialBal: ", ownerInitialBal);
		await bs.connect(addr1).buyBook(5, {value: 101});
		console.log(await bs.provider.getBalance(bs.address));

		let txn = await bs.withdrawAmount(0);
		console.log("Transaction: ", txn);

		txnReceipt = await txn.wait();
		
		console.log("Transaction Receipt: ", txnReceipt);

		console.log(txnReceipt.gasUsed);

		console.log("Owner updated bal: ", await bs.provider.getBalance(owner.address));
		console.log("Contract updated bal: ", await bs.provider.getBalance(bs.address));
		expect(await bs.provider.getBalance(owner.address)).to.
			equals((ethers.BigNumber.from(ownerInitialBal)+ 50 + txnReceipt.gasUsed).toString());
			
	});
});