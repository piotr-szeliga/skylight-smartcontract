/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const ShadowFiPresale = await hre.ethers.getContractFactory("ShadowFiPresale");
  const contract = await ShadowFiPresale.deploy(
    "0xb7dE241d7E6f64CcBea73eECDbD91E949A7461dd"
  );

  await contract.deployed();
  console.log("ShadowFiPresale deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
