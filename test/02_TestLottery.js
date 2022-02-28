const { expect } = require("chai");
const { ethers } = require("hardhat");
const {web3} = require("@nomiclabs/hardhat-web3");


describe.only("Betting Contract", function () {
  // A common pattern is to declare some variables, and assign them in the
  // `before` and `beforeEach` callbacks.
  let Lottery;
  let Token;
  let token;
  let owner;
  let addr1;
  let addr2;
  let addr3;
  let addrs;

  beforeEach(async function(){    
    // Get the ContractFactory and Signers here.
    Token = await ethers.getContractFactory("DeBeToken");
    token = await Token.deploy();
    await token.deployed();
    
    Lottery = await ethers.getContractFactory("Lottery");
    [owner, addr1, addr2, addr3, ...addrs] = await ethers.getSigners();
    lottery = await Lottery.deploy(token.address);
    await lottery.deployed();
  });

  describe.skip("Get user TVL", function(){
    it("Should get user's staked amount", async function(){
      // ARRANGE
      token.transfer(addr2.address, ethers.utils.parseEther("0.5"));
      await token.connect(addr2).approve(lottery.address, ethers.utils.parseEther("0.05"));
      // ACT
      await lottery.connect(addr2).enterLottery("ARSENAL", {value: ethers.utils.parseEther("0.05") });
      const userTVL = await lottery.getUserTVL(addr2.address);

      // ASSERT
      console.log("Winner prize is %s", userTVL);
    })
  })

  describe.skip("Mint and Burn reward", function(){
    it("Should mint tokens for winner", async function(){
      // ARRANGE
      token.transfer(addr2.address, ethers.utils.parseEther("0.5"));
      await token.connect(addr2).approve(lottery.address, ethers.utils.parseEther("0.05"));
      await lottery.connect(addr2).enterLottery("ARSENAL", {value: ethers.utils.parseEther("0.05") });
      // ACT
      await lottery.connect(addr2).mintAndBurnPrize(true);
      // ASSERT
      expect(await token.balanceOf(addr2.address)).to.equal(ethers.utils.parseEther("0.545"))
    })
  })

  describe.skip("Enter lottery", function(){
    it("Should return staker info", async function(){
    // ARRANGE
    token.transfer(addr2.address, ethers.utils.parseEther("0.5"));
    console.log("Owner is %s", owner.address);
    console.log("Addr2 is %s", addr2.address);

    // ACT
    await token.connect(addr2).approve(lottery.address, ethers.utils.parseEther("0.05"));
    await lottery.connect(addr2).enterLottery("ARSENAL", {value: ethers.utils.parseEther("0.01") });

    const stakedAmount = await lottery.balances(addr2.address);
    
    // Assert
    // expect(stakedAmount.stakedAmount).to.equal(0); // there is 5% fee
    console.log("Staked amount is %s", stakedAmount.stakedAmount);
    expect(stakedAmount.betOnThis).to.equal("ARSENAL");
    });
  });

  // tested and works
  describe.skip("Get entrance fee", function () {
    it("Should check the betting amount", async function () {
      // ARRANGE
      await deBeToken.transfer(addr2.address, 500);

      // ACT
      const fee = await lottery.getEntranceFee(250);
      
      // ASSERT
      expect(fee).to.equal(12);
    });
  });

  describe("Calculate prize", function (){    
    it("Should get winning amount", async function(){
      // arrange
      token.transfer(addr1.address, ethers.utils.parseEther("0.05"));
      token.transfer(addr2.address, ethers.utils.parseEther("0.05"));
      token.transfer(addr3.address, ethers.utils.parseEther("0.05"));

      await token.connect(addr1).approve(lottery.address, ethers.utils.parseEther("0.05"));
      await token.connect(addr2).approve(lottery.address, ethers.utils.parseEther("0.05"));
      await token.connect(addr3).approve(lottery.address, ethers.utils.parseEther("0.05"));
      
      await lottery.connect(addr1).enterLottery("BARCELONA", {value: ethers.utils.parseEther("0.01") });
      await lottery.connect(addr2).enterLottery("ARSENAL", {value: ethers.utils.parseEther("0.01") });
      await lottery.connect(addr3).enterLottery("ARSENAL", {value: ethers.utils.parseEther("0.04") });
      
      await lottery.connect(owner).endLottery();
      await lottery.connect(owner).getWinners("BARCELONA");
      
      // Act
      const prize = await lottery.connect(addr2).calculatePrize();
      
      // Assert
      console.log("Calculated prize as share of pool: ", prize);
      // expect(prize).to.equal(24);
    })

    it.skip("Should get 0 as there are no winners", async function(){
      //Arrange
      await lottery.enterLottery("ARSENAL");

           
      // Act
      const prize = await lottery.calculatePrize(addr2.address);
      
      // Assert
      // expect 0 as there are no winners
      // test transaction --> prize will go to treasury
       expect(prize).to.equal(0);
    })
  })

});