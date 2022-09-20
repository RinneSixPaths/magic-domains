import { HardhatUserConfig } from 'hardhat/config';
import '@nomicfoundation/hardhat-toolbox';

// https://cloudflare-ipfs.com/ipfs/INSERT_YOUR_CID_HERE
// npx hardhat run scripts/deploy.ts --network mumbai

const config: HardhatUserConfig = {
  solidity: '0.8.17',
  // networks: {
  //   mumbai: {
  //     url: '',
  //     accounts: [''],
  //   }
  // }
};

export default config;
