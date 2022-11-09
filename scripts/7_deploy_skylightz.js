/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const Skylightz = await hre.ethers.getContractFactory("Skylightz");
  const contract = await Skylightz.deploy("", "");

  await contract.deployed();
  console.log("Skylightz deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
