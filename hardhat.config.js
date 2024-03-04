require("@nomicfoundation/hardhat-ethers");
const { alchemyApiKey, privateKey } = require("./secrets.json");

module.exports = {
  solidity: "0.8.19",
  networks: {
    hardhat: {
      chainId: 1337,
    },
    sepolia: {
      url: "https://eth-sepolia.g.alchemy.com/v2/" + alchemyApiKey,
      accounts: [privateKey],
    },
  },
};