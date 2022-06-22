/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const MeemosWorld = await hre.ethers.getContractFactory(
    "MeemosWorld"
  );
  const contract = await MeemosWorld.deploy();

  await contract.deployed();
  console.log("MeemosWorld deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
