module.exports = {
  contracts_directory: "contracts/test/", //"contracts",
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost
      port: 8545,            // Ganache/Ganache-cli default port
      network_id: "*"        // Any network ID
    },
    sepolia: {
      host: "",
      port: 8545,
      network_id: "",
      from: "",
      gas: 6000000,          // Adjust this value based on your contract's gas requirements
    },
  },
  compilers: {
    solc: {
      version: "0.8.0",     // Solidity compiler version
    },
  },
};

