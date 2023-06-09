const { ethers } = require("hardhat");
async function main() {
  //deploying Escrow.sol
  const MyContract = await ethers.getContractFactory("Escrow");
  const myContract = await MyContract.deploy();
  // await myContract.deployed();
  console.log("Escrow contract deployed to the address: ", myContract.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
