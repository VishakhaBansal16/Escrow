const { ethers } = require("hardhat");
const web3 = require("web3");
const { expect } = require("chai");
let escrowInstance;
let buyer;
let seller;
let arbitrator;
const amountInEther = 1;
const amount = web3.utils.toWei("1", "ether");

describe("Escrow", function () {
  beforeEach(async () => {
    const [Buyer, Seller, Arbitrator] = await ethers.getSigners();
    buyer = Buyer;
    seller = Seller;
    arbitrator = Arbitrator;
    //deploying Escrow.sol
    const escrowContract = await ethers.getContractFactory("Escrow");
    escrowInstance = await escrowContract.deploy();
    //await escrowInstance.deployed();
  });

  it("should create a new escrow", async function () {
    const transactionId = await escrowInstance.transactionCount();

    await escrowInstance.createEscrow(seller, arbitrator, {
      from: buyer,
      value: amount,
    });

    const transaction = await escrowInstance.transactions(transactionId);

    await expect(transaction.buyer).to.equal(buyer, "Buyer address mismatch");
    await expect(transaction.seller).to.equal(
      seller,
      "Seller address mismatch"
    );
    await expect(transaction.arbitrator).to.equal(
      arbitrator,
      "Arbitrator address mismatch"
    );
    await expect(transaction.amount).to.equal(amount, "Escrow amount mismatch");
    await expect(transaction.status).to.equal(
      "InProgress",
      "Escrow status mismatch"
    );
    await expect(transaction.buyerApproved).to.equal(
      false,
      "Buyer approval flag mismatch"
    );
    await expect(transaction.sellerApproved).to.equal(
      false,
      "Seller approval flag mismatch"
    );
  });

  it("should deposit funds into an existing escrow", async function () {
    const transactionId = await escrowInstance.transactionCount();

    await escrowInstance.depositFunds(transactionId.toNumber(), {
      from: buyer,
      value: amount,
    });

    const transaction = await escrowInstance.transactions(
      transactionId.toNumber()
    );

    const expectedAmount = web3.utils
      .toBN(amount)
      .mul(web3.utils.toBN(2))
      .toString();
    await expect(transaction.amount).to.equal(
      expectedAmount,
      "Escrow amount mismatch"
    );
  });

  it("should release funds from an escrow to the seller", async function () {
    const transactionId = await escrowInstance.transactionCount();

    await escrowInstance.approveRelease(transactionId.toNumber(), {
      from: buyer,
    });

    await escrowInstance.approveRelease(transactionId.toNumber(), {
      from: seller,
    });

    const transaction = await escrowInstance.transactions(
      transactionId.toNumber()
    );

    await expect(transaction.status).to.equal(
      "Completed",
      "Escrow status mismatch"
    );

    const sellerBalance = await web3.eth.getBalance(seller);
    await expect(sellerBalance).to.equal(amount, "Seller balance mismatch");
  });

  it("should initiate a dispute for an escrow", async function () {
    const transactionId = await escrowInstance.transactionCount();

    await escrowInstance.initiateDispute(transactionId.toNumber(), {
      from: buyer,
    });

    const transaction = await escrowInstance.transactions(
      transactionId.toNumber()
    );

    await expect(transaction.status).to.equal(
      "Disputed",
      "Escrow status mismatch"
    );
  });

  it("should resolve a dispute for an escrow", async function () {
    const transactionId = await escrowInstance.transactionCount();

    await escrowInstance.resolveDispute(transactionId.toNumber(), seller, {
      from: arbitrator,
    });

    const transaction = await escrowInstance.transactions(
      transactionId.toNumber()
    );

    await expect(transaction.status).to.equal(
      "Completed",
      "Escrow status mismatch"
    );

    const sellerBalance = await web3.eth.getBalance(seller);
    await expect(sellerBalance).to.equal(amount, "Seller balance mismatch");
  });
});
