/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const TestToken = await hre.ethers.getContractFactory("TestToken");
  const contract = await TestToken.deploy();

  await contract.deployed();
  console.log("TestToken deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
