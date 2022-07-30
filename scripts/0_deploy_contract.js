/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const Moodies = await hre.ethers.getContractFactory(
    "Moodies"
  );
  const contract = await Moodies.deploy("Moodies", "MDS", 100000000000000, 1000, "https://", null);

  await contract.deployed();
  console.log("Moodies deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
