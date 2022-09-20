const hre = require('hardhat');

const main = async () => {
  const domainContractFactory = await hre.ethers.getContractFactory('HogwartsStudentsService');
  const domainContract = await domainContractFactory.deploy();
  await domainContract.deployed();

  console.log('Contract deployed to:', domainContract.address);S
}

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

export {};
