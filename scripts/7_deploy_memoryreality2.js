/* eslint-disable no-console */
// eslint-disable-next-line import/no-extraneous-dependencies
const hre = require("hardhat");

async function main() {
  const MemoryReality2 = await hre.ethers.getContractFactory("MemoryReality2");
  const contract = await MemoryReality2.deploy(
    "https://skylightz.mypinata.cloud/ipfs/QmcDNFeotGGkSx2p62i3GERVvRrqzwS5vV5sU8dgRc6asb/",
    "https://skylightz.mypinata.cloud/ipfs/QmZCXTGNQpeDw8KLhT3yYfpNTk5t9YMivabssPmbgE7SGa/"
  );

  await contract.deployed();
  console.log("MemoryReality2 deployed to:", contract.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
