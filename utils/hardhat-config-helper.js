const networkConfig = {
    11155111: {
      name: "sepolia",
      ethUsdPriceFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306",
      vrfCoordinator: "0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B",
      keyHash: "0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae" // gasLane
    },
  };
  
  const developmentChains = [31337];
  const developmentChainsNames = ["hardhat", "localhost"];
  
  module.exports = { developmentChainsNames, networkConfig, developmentChains };
  