const hre = require('hardhat');

const main = async () => {
  const [owner] = await hre.ethers.getSigners();
  const domainContractFactory = await hre.ethers.getContractFactory('HogwartsStudentsService');
  const domainContract = await domainContractFactory.deploy();
  await domainContract.deployed();

  console.log('Contract deployed to:', domainContract.address);

  let txn = await domainContract.applyToHogwarts(
    'RonWeasley',
    'Dog',
    Math.floor(Math.random() * 100), 
    { value: hre.ethers.utils.parseEther('0.001') }
  );
  await txn.wait();

  const balance = await hre.ethers.provider.getBalance(domainContract.address);
  console.log('Contract balance:', hre.ethers.utils.formatEther(balance));

  let ownerBalance = await hre.ethers.provider.getBalance(owner.address);
  console.log("Balance of owner before withdrawal:", hre.ethers.utils.formatEther(ownerBalance));

  txn = await domainContract.connect(owner).withdraw();
  await txn.wait();

  const contractBalance = await hre.ethers.provider.getBalance(domainContract.address);
  ownerBalance = await hre.ethers.provider.getBalance(owner.address);

  console.log("Contract balance after withdrawal:", hre.ethers.utils.formatEther(contractBalance));
  console.log("Balance of owner after withdrawal:", hre.ethers.utils.formatEther(ownerBalance));
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

export {};
