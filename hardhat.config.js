// hardhat.config.js
require("@nomiclabs/hardhat-ethers");

module.exports = {
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {
      // Configuration specific to the Hardhat network
    },
    rinkeby: {
      url: "https://rinkeby.infura.io/v3/YOUR_PROJECT_ID",
      accounts: {
        mnemonic: "test test test test test test test test test test test junk",
      },
    },
  },
  solidity: "0.8.9",
};
