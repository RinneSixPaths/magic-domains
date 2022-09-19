const hre = require("hardhat");

const main = async () => {
  const domainContractFactory = await hre.ethers.getContractFactory('HogwartsStudentsService');
  const domainContract = await domainContractFactory.deploy();
  await domainContract.deployed();

  console.log("Contract deployed to:", domainContract.address);

  let txn = await domainContract.register('RonWeasley',  { value: hre.ethers.utils.parseEther('0.1') });
  await txn.wait();

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log("Contract balance:", hre.ethers.utils.formatEther(balance));
};

const runMain = async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
};

runMain();
