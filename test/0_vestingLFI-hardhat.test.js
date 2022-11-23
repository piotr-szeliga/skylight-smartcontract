/* eslint-disable no-console */
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { time } = require("@openzeppelin/test-helpers");

require("@nomiclabs/hardhat-ethers");
// eslint-disable-next-line node/no-unsupported-features/node-builtins
const assert = require("assert").strict;

const { formatNumberFromBN, getBNFromNumber } = require("../utils/helper");

const NumArray = (s, e) => {
  const ret = [];
  for (let i = s; i < e; i += 1) ret.push(i);
  return ret;
};

describe("Vesting", () => {
  let token;
  let dec;
  let VestingContract;
  let Vesting;
  let vestingScheduleCounter;
  let vestingScheduleData;
  let accounts = [];
  let owner;
  const MINUTES_IN_DAY = 24 * 60; // 24 * 60 for mainnet, 1 for testnet

  before(async () => {
    [owner, ...accounts] = await ethers.getSigners();

    vestingScheduleData = [
      [accounts[0].address.toString(), 666666.6667, 30, 360, 0],
      [accounts[1].address.toString(), 333333.3333, 30, 360, 0],
      [accounts[2].address.toString(), 220000, 30, 360, 0],
      [accounts[3].address.toString(), 3333333.333, 30, 360, 90],
      [accounts[4].address.toString(), 10000000, 30, 360, 90],
      [accounts[5].address.toString(), 2500000, 30, 360, 90],
      [accounts[6].address.toString(), 115000000, 30, 720, 180],
      [accounts[7].address.toString(), 10000000, 30, 720, 180],
      [accounts[8].address.toString(), 5000000, 30, 720, 180],
      [accounts[9].address.toString(), 2000000, 30, 720, 180],
      [accounts[10].address.toString(), 10000000, 30, 1080, 60],
      [accounts[11].address.toString(), 10000000, 30, 1080, 90],
    ];

    const Erc20 = await ethers.getContractFactory("UvwToken");
    token = await Erc20.deploy();
    dec = await token.decimals();

    await token.deployed();
    console.log("UvwToken deployed to:", token.address);

    VestingContract = await ethers.getContractFactory("VestingLFI");
    Vesting = await VestingContract.deploy(token.address);

    await Vesting.deployed();
    console.log("VestingLFI contract deployed to:", Vesting.address);
  });

  it("Check balance of owner before vesting", async () => {
    console.log("\n");
    const ownerBalance = await token.balanceOf(owner.address);
    console.log(`Owner balance before vesting : ${formatNumberFromBN(ownerBalance, dec)}`);

    await token.approve(Vesting.address, ownerBalance);
  });

  it("Deposit token from manager to contract", async () => {
    console.log("\n");
    console.log("Balance of owner and contract");
    console.log("Before deposit: ");
    let ownerBalance = await token.balanceOf(owner.address);
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`owner : ${formatNumberFromBN(ownerBalance, dec)}`);
    console.log(`contract : ${formatNumberFromBN(contractBalance, dec)}`);

    await expect(Vesting.connect(owner).depositVestingAmount(getBNFromNumber(169053334, dec))).to.be.not.reverted;
    console.log(`Deposit 169,053,334 tokens to vesting contract`);

    console.log("After deposit");
    ownerBalance = await token.balanceOf(owner.address);
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`owner : ${formatNumberFromBN(ownerBalance, dec)}`);
    console.log(`contract : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Should success to create vesting schedules.", async () => {
    console.log("\n");
    console.log("Balance of owner and contract");
    console.log("Before creating: ");
    let ownerBalance = await token.balanceOf(owner.address);
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`owner : ${formatNumberFromBN(ownerBalance, dec)}`);
    console.log(`contract : ${formatNumberFromBN(contractBalance, dec)}`);

    const blockNumber = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNumber);
    const timenow = block.timestamp;

    await Vesting.addVestingSchedules(
      vestingScheduleData.map((row) => row[0]),
      vestingScheduleData.map((row) => row[2]),
      vestingScheduleData.map((row) => row[3]),
      vestingScheduleData.map((row) => row[4]),
      vestingScheduleData.map((row) => getBNFromNumber(row[1], dec))
    );

    console.log("After creating");
    ownerBalance = await token.balanceOf(owner.address);
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`owner : ${formatNumberFromBN(ownerBalance, dec)}`);
    console.log(`contract : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Check vesting status", async () => {
    console.log("\n");
    vestingScheduleCounter = await Vesting.getVestingAccountsCount();
    console.log(`Vesting counts : ${vestingScheduleCounter.toNumber()}`);

    const vestingToken = await Vesting.getToken();
    assert(vestingToken.toString() === token.address.toString());

    console.log("\n");
    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        const vestingSchedule =
          i < 5
            ? await Vesting.getVestingScheduleByAddress(accounts[i].address)
            : await Vesting.getVestingScheduleById(i + 1);

        const recipient = await Vesting.getVestingAccountById(i + 1);
        assert(recipient.toString() === vestingSchedule.recipient.toString());

        console.log("\tVesting ID: ", vestingSchedule.vestingId.toNumber());
        console.log("\tRecipient: ", recipient.toString());
        console.log("\tStart: ", vestingSchedule.startTime.toNumber());
        console.log("\tPeriod: ", vestingSchedule.vestingPeriod.toNumber() / MINUTES_IN_DAY / 60);
        console.log("\tCliff: ", vestingSchedule.vestingCliff.toNumber() / MINUTES_IN_DAY / 60);
        console.log("\tAmount: ", formatNumberFromBN(vestingSchedule.allocatedAmount, dec));
      })
    );
    console.log("\n");
  });

  it("Check Account Balances Before Vesting", async () => {
    console.log("\n");
    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`account${i}, ${accounts[i].address} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(10 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 10 days -----------------------------");
  });

  it("Account0 should fail to claim before started", async () => {
    console.log("\n");

    const blockNumber = await ethers.provider.getBlockNumber();
    const block = await ethers.provider.getBlock(blockNumber);
    const timenow = block.timestamp;
    console.log("timenow", timenow);

    const i = 0;
    let balanceOfAccount = await token.balanceOf(accounts[i].address);
    console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.reverted;

    balanceOfAccount = await token.balanceOf(accounts[i].address);
    console.log(`After claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(50 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 50 days -----------------------------"); // 60
  });

  it("Account11 should fail to claim before cliff", async () => {
    console.log("\n");
    const i = 11;
    let balanceOfAccount = await token.balanceOf(accounts[i].address);
    console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.reverted;

    balanceOfAccount = await token.balanceOf(accounts[i].address);
    console.log(`After claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(30 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 30 days -----------------------------"); // 90
  });

  it("Account0 should success to claim and to redirect the transfer", async () => {
    console.log("\n");
    let balanceOfAccount0 = await token.balanceOf(accounts[0].address);
    console.log(`Before claiming, account0 : ${formatNumberFromBN(balanceOfAccount0, dec)}`);
    let balanceOfAccount12 = await token.balanceOf(accounts[12].address);
    console.log(`Before claiming, account12 : ${formatNumberFromBN(balanceOfAccount12, dec)}`);
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
    const claimableAmount = await Vesting.getClaimable(accounts[0].address);
    console.log(`Claimable Amount : ${formatNumberFromBN(claimableAmount, dec)}`);

    await expect(Vesting.connect(accounts[0]).claimVestedTokensTo(accounts[12].address)).to.be.not.reverted;

    balanceOfAccount0 = await token.balanceOf(accounts[0].address);
    console.log(`After claiming, account0 : ${formatNumberFromBN(balanceOfAccount0, dec)}`);
    balanceOfAccount12 = await token.balanceOf(accounts[12].address);
    console.log(`After claiming, account12 : ${formatNumberFromBN(balanceOfAccount12, dec)}`);
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Account12 should fail to claim", async () => {
    console.log("\n");
    const i = 12;
    let balanceOfAccount = await token.balanceOf(accounts[i].address);
    console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.reverted;

    balanceOfAccount = await token.balanceOf(accounts[i].address);
    console.log(`After claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(120 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 120 days -----------------------------"); // 210
  });

  it("Accounts should success to claim", async () => {
    console.log("\n");
    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );

    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.not.reverted;
      })
    );
    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(180 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 180 days -----------------------------"); // 390
  });

  it("Accounts should success to claim", async () => {
    console.log("\n");
    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.not.reverted;
      })
    );
    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(360 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 360 days -----------------------------"); // 750
  });

  it("Accounts should success to claim", async () => {
    console.log("\n");
    await Promise.all(
      NumArray(6, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await Promise.all(
      NumArray(6, vestingScheduleCounter).map(async (i) => {
        await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.not.reverted;
      })
    );
    await Promise.all(
      NumArray(6, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(360 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 360 days -----------------------------"); // 1110
  });

  it("Accounts should success to claim", async () => {
    console.log("\n");
    await Promise.all(
      NumArray(10, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await Promise.all(
      NumArray(10, vestingScheduleCounter).map(async (i) => {
        await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.not.reverted;
      })
    );
    await Promise.all(
      NumArray(10, vestingScheduleCounter).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });

  it("Time increased", async () => {
    console.log("\n");
    await time.increase(10 * MINUTES_IN_DAY * 60);
    console.log("----------------------------- 10 days -----------------------------"); // 1120
  });

  it("Accounts should fail to claim after vesting ended", async () => {
    console.log("\n");
    await Promise.all(
      NumArray(0, 13).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    let contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);

    await Promise.all(
      NumArray(0, vestingScheduleCounter).map(async (i) => {
        await expect(Vesting.connect(accounts[i]).claimVestedTokens()).to.be.reverted;
      })
    );
    await Promise.all(
      NumArray(0, 13).map(async (i) => {
        const balanceOfAccount = await token.balanceOf(accounts[i].address);
        console.log(`Before claiming, account${i} : ${formatNumberFromBN(balanceOfAccount, dec)}`);
      })
    );
    contractBalance = await token.balanceOf(Vesting.address);
    console.log(`Contract balance : ${formatNumberFromBN(contractBalance, dec)}`);
  });
});
