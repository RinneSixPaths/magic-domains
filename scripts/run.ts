const hre = require("hardhat");

const main = async () => {
  const [owner, randomPerson] = await hre.ethers.getSigners();

  const domainContractFactory = await hre.ethers.getContractFactory('Domains');
  const domainContract = await domainContractFactory.deploy();
  await domainContract.deployed();
  console.log("Contract deployed to:", domainContract.address);
  console.log("Contract deployed by:", owner.address);
  
  let txn = await domainContract.register("google.com");
  await txn.wait();

  const domainOwner = await domainContract.getAddress("google.com");
  console.log("Owner of domain:", domainOwner);

  // txn = await domainContract.connect(randomPerson).setRecord("google.com", "Haha my domain now!");
  // await txn.wait();
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
