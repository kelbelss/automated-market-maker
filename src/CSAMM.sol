// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./IERC20.sol";

contract CSAMM {
    IERC20 public immutable token0;
    IERC20 public immutable token1;

    // STATE VARIABLES START

    // keep track of token0
    uint256 public reserve0;

    // keep track of token1
    uint256 public reserve1;

    // keep track of total supplies
    uint256 public totalSupply;

    // shares per user
    mapping(address => uint256) public balanceOf;

    // STATE VARIABLES END

    // initialise variables
    constructor(address _token0, address _token1) {
        token0 = IERC20(_token0);
        token1 = IERC20(_token1);
    }

    // Internal Functions - to mint and to burn
    function _mint(address _to, uint256 _amount) private {
        balanceOf[_to] += _amount;
        totalSupply += _amount;
    }

    function _burn(address _from, uint256 _amount) private {
        balanceOf[_from] -= _amount;
        totalSupply -= _amount;
    }

    // Function to update reserves
    function _update(uint256 _res0, uint256 _res1) private {
        reserve0 = _res0;
        reserve1 = _res1;
    }

    // Function to swop - trade one token for another
    function swap(address _tokenIn, uint256 _amountIn) external returns (uint256 amountOut) {
        require(_tokenIn == address(token0) || _tokenIn == address(token1), "invalid token");

        // optimise for gas costs
        bool isToken0 = _tokenIn == address(token0);
        (IERC20 tokenIn, IERC20 tokenOut, uint resIn, uint resOut) = isToken0 ? (token0, token1, reserve0, reserve1) : (token1, token0, reserve1, reserve0);

        // transfer token in
        tokenIn.transferFrom(msg.sender, address(this), _amountIn);
        uint amountIn = tokenIn.balanceOf(address(this)) - resIn;

        // calculate amount out (include fees) fee = 0.3%
        amountOut = (amountIn * 997) / 1000;

        // update reserve0 and reserve1
        (uint res0, uint res1) = isToken0 ? (resIn + _amountIn, resOut - amountOut) : (resOut - amountOut, resIn + _amountIn);
        _update(res0, res1);

        // transfer token out
        tokenOut.transfer(msg.sender, amountOut);
    }

    function addLiquidity() external {}

    function removeLiquidity() external {}
}
