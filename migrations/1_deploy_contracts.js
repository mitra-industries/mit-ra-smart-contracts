var Mit-raStorage = artifacts.require("./Mit-raStorage.sol");
var AdamCoefficients = artifacts.require("./AdamCoefficients.sol");
var SystemOwner = artifacts.require("./SystemOwner.sol");
var Mit-raExchange = artifacts.require("./Mit-raExchange.sol");

module.exports = function(deployer, network, accounts) {
  if (network === 'development') {
    deployer.deploy(SystemOwner).then(function () {
      return deployer.deploy(AdamCoefficients, SystemOwner.address)
    }).then(function () {
      return deployer.deploy(Mit-raStorage, SystemOwner.address);
    }).then(function () {
      return deployer.deploy(Mit-raExchange, Mit-raStorage.address, AdamCoefficients.address, SystemOwner.address);
    });
  } else {
    // production
  }
};
