/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const Moodies = await hre.ethers.getContractFactory(
    "Moodies"
  );
  const contract = await Moodies.deploy("Moodies", "MDS", 100000000000000, 1000, "ipfs://QmTubr1R1AMgWJgQpzakZTScHbdjbHtC7Sj6sSbr25Muhf/", "0xcd3b766ccdd6ae721141f452c550ca635964ce71");

  await contract.deployed();
  console.log("Moodies deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
