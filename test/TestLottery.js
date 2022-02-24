const { expect } = require("chai");
const { ethers } = require("hardhat");

describe.only("Betting Contract", function () {
  // A common pattern is to declare some variables, and assign them in the
  // `before` and `beforeEach` callbacks.
  let Lottery;
  let owner;
  let addr1;
  let addr2;
  let addrs;

  beforeEach(async function(){
    // Get the ContractFactory and Signers here.
    Lottery = await ethers.getContractFactory("Lottery");
    [owner, addr1, addr2, ...addrs] = await ethers.getSigners();
    lottery = await Lottery.deploy();
    await lottery.deployed();
  });

  describe("Enter lottery", function(){
    it("Should return staker info", async function(){
    //lottery.enter({"from": get_account(), "value": lottery.getEntranceFee()})
    await lottery.enterLottery(addr2.address, 50, "ARSENAL");
    const stakedAmount = await lottery.balances(addr2.address);
    const playersArray = await lottery.players;
    expect(stakedAmount.amount).to.equal(50);
    expect(stakedAmount.betOnThis).to.equal("ARSENAL");
    });
  });

  describe("Get entrance fee", function () {
    it("Should check the betting amount", async function () {
      const betAmount = await lottery.getEntranceFee(100);
      expect(betAmount).to.equal(100);
    });
  });

  describe("Get winners", function(){
    it("Should get winner's amount", async function(){
      await lottery.enterLottery(addr2.address, 50, "ARSENAL");
      const winningAmount =  await lottery.getWinners(addr2.address);
      console.log("Receiving:", winningAmount );
      //expect(winningAmount).to.equal(50);
    })
  })
});