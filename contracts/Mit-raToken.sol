pragma solidity ^0.4.23;

import 'zeppelin-solidity/contracts/token/ERC20/DetailedERC20.sol';
import 'zeppelin-solidity/contracts/token/ERC20/BurnableToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/StandardToken.sol';
import 'zeppelin-solidity/contracts/token/ERC20/PausableToken.sol';

/**
 * @title Mit-raToken
 * @dev MIT-RA Token Smart Contract
 */
contract Mit-raToken is DetailedERC20, StandardToken, BurnableToken, PausableToken {

    /**
    * Init token by setting its total supply
    *
    * @param totalSupply total token supply
    */
    function Mit-raToken(
        uint256 totalSupply
    ) DetailedERC20(
        "MIT-RA Token",
        "MIT-RA",
        18
    ) {
        totalSupply_ = totalSupply;
        balances[msg.sender] = totalSupply;
    }
}
