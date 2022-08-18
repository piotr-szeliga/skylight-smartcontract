/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const ShadowFiLiquidityLock = await hre.ethers.getContractFactory(
    "ShadowFiLiquidityLock"
  );
  const contract = await ShadowFiLiquidityLock.deploy(
    "0xa7fc129b0706a60554F93C78E44bD37f7B3c1552",
    "0x9ac64cc6e4415144c455bd8e4837fea55603e5c3",
    "0xdCd8271a7C3Dd07866228d058Da2A50d7eCD2be3",
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
