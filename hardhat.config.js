require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-web3");
require('@nomiclabs/hardhat-ethers');
require('hardhat-deploy');
require('@nomiclabs/hardhat-etherscan');
require('dotenv').config()


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: { },
    // rinkeby: { },
    // polygon: { }
  },
  etherscan: {
    apiKey: ''
  },
  namedAccounts: {
    deployer: {
      default: 0
    }
  },
  solidity: {
    compilers: [
      {version: "0.8.1"},
      {version: "0.8.0"},
      {version: "0.7.0"},
      {version: "0.6.6"},
      {version: "0.4.24"}
    ]
  }
};
