/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const ShadowFiLiquidityLock = await hre.ethers.getContractFactory(
    "ShadowFiLiquidityLock"
  );
  const contract = await ShadowFiLiquidityLock.deploy(
    "0x9ac64cc6e4415144c455bd8e4837fea55603e5c3",
    "0x6ac5BE595D791e6a547Ae8753000bC3b2731E5cA",
    1661147602
  );

  await contract.deployed();
  console.log("ShadowFiLiquidityLock deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
