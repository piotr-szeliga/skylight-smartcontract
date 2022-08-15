/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const ShadowFiToken = await hre.ethers.getContractFactory("ShadowFiToken");
  const contract = await ShadowFiToken.deploy();

  await contract.deployed();
  console.log("ShadowFiToken deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
