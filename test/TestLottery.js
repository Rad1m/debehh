const { expect } = require("chai");

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

  describe("Get entrance fee", function () {
    it("Should check the betting amount", async function () {
      const betAmount = await lottery.getEntranceFee(100);
      expect(betAmount).to.equal(200);
      
    });
  });
});