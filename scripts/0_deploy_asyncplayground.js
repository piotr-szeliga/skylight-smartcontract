/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const AsyncPlayground = await hre.ethers.getContractFactory(
    "AsyncPlayground"
  );
  const contract = await AsyncPlayground.deploy(
    100,
    "ipfs://QmSCFe5vvoPsSpyHZpGAW78GJ4bAuDcySCV9UnMm7B69iS/"
  );

  await contract.deployed();
  console.log("AsyncPlayground deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
