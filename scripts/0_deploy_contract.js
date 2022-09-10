/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const Ambush = await hre.ethers.getContractFactory("Ambush");
  const contract = await Ambush.deploy(
    100000000000000,
    "ipfs://bafybeifv2jje4fwjru7iqiphj2h5lpeoqq6zjsz4czpzojq7w7tvo4hi3m/",
  );

  await contract.deployed();
  console.log("Ambush deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
