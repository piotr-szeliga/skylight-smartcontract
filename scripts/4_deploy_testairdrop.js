/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const TestAirdrop = await hre.ethers.getContractFactory("TestAirdrop");
  const contract = await TestAirdrop.deploy();

  await contract.deployed();
  console.log("TestAirdrop deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
