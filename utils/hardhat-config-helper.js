const networkConfig = {
    11155111: {
      name: "sepolia",
      ethUsdPriceFeed: "0x694AA1769357215DE4FAC081bf1f309aDC325306",
      vrfCoordinator: "0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625"
    },
  };
  
  const developmentChains = [31337];
  const developmentChainsNames = ["hardhat", "localhost"];
  
  module.exports = { developmentChainsNames, networkConfig, developmentChains };
  