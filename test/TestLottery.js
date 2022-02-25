const { expect } = require("chai");
const { ethers } = require("hardhat");
const {web3} = require("@nomiclabs/hardhat-web3");


describe.only("Betting Contract", function () {
  // A common pattern is to declare some variables, and assign them in the
  // `before` and `beforeEach` callbacks.
  let Lottery;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;

  beforeEach(async function(){
    // Get the ContractFactory and Signers here.
    Lottery = await ethers.getContractFactory("Lottery");
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    lottery = await Lottery.deploy();
    await lottery.deployed();
  });

  describe("Enter lottery", function(){
    it("Should return staker info", async function(){
    //lottery.enter({"from": get_account(), "value": lottery.getEntranceFee()})
    await lottery.enterLottery(addr2.address, 50, "ARSENAL");
    const stakedAmount = await lottery.balances(addr2.address);
    // Assert
    expect(stakedAmount.stakedAmount).to.equal(48); // there is 5% fee
    expect(stakedAmount.betOnThis).to.equal("ARSENAL");
    });
  });

  // tested and works
  describe("Get entrance fee", function () {
    it("Should check the betting amount", async function () {
      const fee = await lottery.getEntranceFee(250);
      expect(fee).to.equal(12);
    });
  });

  describe("Calculate prize", function (){    
    it("Should get total value locked divided amongst all winners proportionally", async function(){
      // arrange
      await lottery.enterLottery(addr1.address, 500*10**9, "ARSENAL");
      await lottery.enterLottery(addr2.address, 500*10**9, "ARSENAL");
      await lottery.enterLottery(addr3.address, 1000*10**9, "ARSENAL");
      await lottery.getWinners(addr3.address);
      await lottery.getWinners(addr2.address);
      // Act
      const prize = await lottery.calculatePrize(addr3.address);
      
      // Assert
      console.log("Calculated prize as share of pool: ", prize);
      // expect(prize).to.equal(24);
    })

    it.skip("Should get 0 as there are no winners", async function(){
      //Arrange
      await lottery.enterLottery(addr1.address, 500*10**9, "ARSENAL");
      await lottery.enterLottery(addr2.address, 750*10**9, "ARSENAL");
      await lottery.enterLottery(addr3.address, 1750*10**9, "ARSENAL");
           
      // Act
      const prize = await lottery.calculatePrize(addr2.address);
      
      // Assert
      // expect 0 as there are no winners
      // test transaction --> prize will go to treasury
       expect(prize).to.equal(0);
    })
  })

});