// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint256 amountADesired,
        uint256 amountBDesired,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    )
        external
        returns (
            uint256 amountA,
            uint256 amountB,
            uint256 liquidity
        );

    function addLiquidityETH(
        address token,
        uint256 amountTokenDesired,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    )
        external
        payable
        returns (
            uint256 amountToken,
            uint256 amountETH,
            uint256 liquidity
        );

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountToken, uint256 amountETH);

    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256 amountAMin,
        uint256 amountBMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountA, uint256 amountB);

    function removeLiquidityETHWithPermit(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountToken, uint256 amountETH);

    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapTokensForExactTokens(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactETHForTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function swapTokensForExactETH(
        uint256 amountOut,
        uint256 amountInMax,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapExactTokensForETH(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);

    function swapETHForExactTokens(
        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function quote(
        uint256 amountA,
        uint256 reserveA,
        uint256 reserveB
    ) external pure returns (uint256 amountB);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline
    ) external returns (uint256 amountETH);

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint256 liquidity,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address to,
        uint256 deadline,
        bool approveMax,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external returns (uint256 amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable;

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
}

interface IPancakePair {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external pure returns (string memory);

    function symbol() external pure returns (string memory);

    function decimals() external pure returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transfer(address to, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);

    function PERMIT_TYPEHASH() external pure returns (bytes32);

    function nonces(address owner) external view returns (uint256);

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    event Mint(address indexed sender, uint256 amount0, uint256 amount1);
    event Burn(
        address indexed sender,
        uint256 amount0,
        uint256 amount1,
        address indexed to
    );
    event Swap(
        address indexed sender,
        uint256 amount0In,
        uint256 amount1In,
        uint256 amount0Out,
        uint256 amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint256);

    function factory() external view returns (address);

    function token0() external view returns (address);

    function token1() external view returns (address);

    function getReserves()
        external
        view
        returns (
            uint112 reserve0,
            uint112 reserve1,
            uint32 blockTimestampLast
        );

    function price0CumulativeLast() external view returns (uint256);

    function price1CumulativeLast() external view returns (uint256);

    function kLast() external view returns (uint256);

    function mint(address to) external returns (uint256 liquidity);

    function burn(address to)
        external
        returns (uint256 amount0, uint256 amount1);

    function swap(
        uint256 amount0Out,
        uint256 amount1Out,
        address to,
        bytes calldata data
    ) external;

    function skim(address to) external;

    function sync() external;

    function initialize(address, address) external;
}

interface IShadowFiToken {
    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 amount) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function airdropped(address account) external view returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    function decimals() external view returns (uint8);

    function burn(address account, uint256 amount) external;
}

contract ShadowFiLiquidityLock is Ownable, ReentrancyGuard {
    IPancakePair private pancakePairToken;
    IPancakeRouter private pancakeRouter;
    IShadowFiToken private shadowFiToken;
    uint256 private lockTime;
    bool private lockEnded;

    event burntShadowFi(
        uint256 removedAmountFromLiquidity,
        uint256 totalAmountBurnt
    );
    event addedLiquidity(uint256 liquidity);

    constructor(
        address _pancakePairToken,
        address _pancakeRouter,
        address _shadowFiToken,
        uint256 _lockTime
    ) {
        pancakePairToken = IPancakePair(_pancakePairToken);
        pancakeRouter = IPancakeRouter(_pancakeRouter);
        shadowFiToken = IShadowFiToken(_shadowFiToken);
        lockTime = _lockTime;
        lockEnded = false;
    }

    /*******************************************************************************************************/
    /************************************* Admin Functions *************************************************/
    /*******************************************************************************************************/
    function endLock() public onlyOwner {
        require(!lockEnded, "You already claimed all LP tokens.");
        require(block.timestamp >= lockTime, "LP tokens are still locked.");

        pancakePairToken.transfer(
            owner(),
            pancakePairToken.balanceOf(address(this))
        );
        lockEnded = true;
    }

    function extendLockTime(uint256 _extraLockTime) public onlyOwner {
        require(!lockEnded, "You already claimed all LP tokens.");
        require(_extraLockTime > 0, "Invalid extra lock time is provided.");

        lockTime += _extraLockTime;
    }

    function buyAndBurnExcess(
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address wBNBAddress
    ) public onlyOwner {
        uint256 lpOwnershipPercent = (pancakePairToken.balanceOf(
            address(this)
        ) * 10000) / pancakePairToken.totalSupply();
        uint256 liquidTokens = (shadowFiToken.balanceOf(
            address(pancakeRouter)
        ) * lpOwnershipPercent) / 10000;
        uint256 liquidPercent = ((liquidTokens * 10000) /
            shadowFiToken.totalSupply());

        require(
            liquidPercent > 800,
            "The amount of ShadowFi tokens in liquidity should be 8%+ of the totalSupply."
        );

        uint256 removeAmount = (liquidPercent - 800) *
            pancakePairToken.balanceOf(address(this));
        (uint256 amountToken, uint256 amountBNB) = pancakeRouter
            .removeLiquidityETH(
                address(shadowFiToken),
                removeAmount,
                amountTokenMin,
                amountETHMin,
                address(this),
                block.timestamp + 120
            );

        address[] memory path = new address[](2);
        path[0] = address(shadowFiToken);
        path[1] = wBNBAddress;
        uint256[] memory amounts = pancakeRouter.swapExactETHForTokens{
            value: amountBNB
        }(amountTokenMin, path, address(this), block.timestamp + 120);

        uint256 sumAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            sumAmount += amounts[i];
        }
        sumAmount += amountToken;
        shadowFiToken.burn(address(this), sumAmount);

        emit burntShadowFi(amountToken, sumAmount);
    }

    function buyAndBurnExcessAmount(
        uint256 percent,
        uint256 amountTokenMin,
        uint256 amountETHMin,
        address wBNBAddress
    ) public onlyOwner {
        uint256 lpOwnershipPercent = (pancakePairToken.balanceOf(
            address(this)
        ) * 10000) / pancakePairToken.totalSupply();
        uint256 liquidTokens = (shadowFiToken.balanceOf(
            address(pancakeRouter)
        ) * lpOwnershipPercent) / 10000;
        uint256 liquidPercent = ((liquidTokens * 10000) /
            shadowFiToken.totalSupply());

        require(
            liquidPercent > 800,
            "The amount of ShadowFi tokens in liquidity should be 8%+ of the totalSupply."
        );
        require(
            percent - liquidPercent <= 800,
            "The amount compared to liquidi tokens should be less than 8% of the totalSupply."
        );

        uint256 removeAmount = (percent - liquidPercent) *
            pancakePairToken.balanceOf(address(this));
        (uint256 amountToken, uint256 amountBNB) = pancakeRouter
            .removeLiquidityETH(
                address(shadowFiToken),
                removeAmount,
                amountTokenMin,
                amountETHMin,
                address(this),
                block.timestamp + 120
            );

        address[] memory path = new address[](2);
        path[0] = address(shadowFiToken);
        path[1] = wBNBAddress;
        uint256[] memory amounts = pancakeRouter.swapExactETHForTokens{
            value: amountBNB
        }(amountTokenMin, path, address(this), block.timestamp + 120);

        uint256 sumAmount = 0;
        for (uint256 i = 0; i < amounts.length; i++) {
            sumAmount += amounts[i];
        }
        sumAmount += amountToken;
        shadowFiToken.burn(address(this), sumAmount);

        emit burntShadowFi(amountToken, sumAmount);
    }

    /*******************************************************************************************************/
    /************************************* Public Functions ************************************************/
    /*******************************************************************************************************/
    function addLiquidity(uint256 amountToken, uint256 amountTokenMin, uint256 amountETHMin)
        external
        payable
    {
        require(amountToken > 0, "Invalid parameter is provided.");
        require(msg.value > 0, "You should fund this contract with BNB.");

        shadowFiToken.transferFrom(
            address(msg.sender),
            address(this),
            amountToken
        );        

        shadowFiToken.approve(address(pancakeRouter), amountToken);

        (, , uint256 liquidity) = pancakeRouter.addLiquidityETH{
            value: msg.value
        }(
            address(shadowFiToken),
            amountToken,
            amountTokenMin,
            amountETHMin,
            address(this),
            block.timestamp + 120
        );

        emit addedLiquidity(liquidity);
    }
}
