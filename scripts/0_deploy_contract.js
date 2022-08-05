/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const Moodies = await hre.ethers.getContractFactory("Moodies");
  const contract = await Moodies.deploy(
    "Moodies",
    "MDS",
    100000000000000,
    7401,
    "ipfs://bafybeifv2jje4fwjru7iqiphj2h5lpeoqq6zjsz4czpzojq7w7tvo4hi3m/",
    "0xb7dE241d7E6f64CcBea73eECDbD91E949A7461dd"
  );

  await contract.deployed();
  console.log("Moodies deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
