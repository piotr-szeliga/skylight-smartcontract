/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const Whitelist = await hre.ethers.getContractFactory("Whitelist");
  const contract = await Whitelist.deploy();

  await contract.deployed();
  console.log("Whitelist deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
