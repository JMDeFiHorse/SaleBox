// SPDX-License-Identifier: MIT

pragma solidity ^0.8.2;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./lib/IPancakeRouter.sol";
import "./lib/Withdrawable.sol";

contract EventBuyBox is Pausable, Ownable, ReentrancyGuard, Withdrawable {
    address public erc20;
    address public erc721;
    uint256 public start;
    uint256 public end;
    uint256 public maxUserSupply = 50;
    uint256 public boxPrice = 2000;

    address private pancakeRouterV2Contract = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address private bnbContract = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address private busdContract = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    event BuyingBox(address indexed user,uint256 amount);
    event EditMaxUserSupply(uint256 amount);

    uint256 public totalSellBox = 0;

    constructor(address _erc20, address _contractBox, uint256 _start, uint256 _duration) {
        erc20 = _erc20;
        erc721 = _contractBox;
        start = _start;
        end = _start + _duration;
    }

    function editMaxUserSupply(uint256 _maxUserSupply) public onlyOwner {
        maxUserSupply = _maxUserSupply;
        emit EditMaxUserSupply(_maxUserSupply);
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function buyBox(uint256 _amountBox) public whenNotPaused nonReentrant {
        require(start <= block.timestamp,"This Event Not Yet Start Time" );
        require(block.timestamp <= end,"This Event Is Time Out" );
        require(_amountBox <= maxUserSupply, "Exceeded the limit on the number of boxes");
        require(_amountBox > 0, "Number of box have to be greater than 0");
        require(IERC721(erc721).balanceOf(address(this)) >= _amountBox, "Not Enough Boxes");

        uint256 _amountTokenToBuyBox = calcTokenAmount();

        _amountTokenToBuyBox = _amountTokenToBuyBox * _amountBox;
        
        IERC20(erc20).transferFrom(msg.sender, address(this), _amountTokenToBuyBox);

        for (uint256 i = 0; i < _amountBox; i++) {
            uint256 _tokenId = IERC721Enumerable(erc721).tokenOfOwnerByIndex(address(this), 0);
            IERC721(erc721).safeTransferFrom(address(this), msg.sender, _tokenId);
            totalSellBox++;
        }
        emit BuyingBox(msg.sender,_amountBox);
    }

    function calcTokenAmount()
        public
        view
        returns(uint256)
    {
        uint256 _curPriceToken = calcCurPriceToken();
        return boxPrice * (10**18) * (10**18) / _curPriceToken;
    }

    function calcCurPriceToken()
        public
        view 
        returns(uint256)
    {
        address[] memory path;
        path  = new address[](2);
        path[0] = erc20;
        path[1] = bnbContract;
        uint256[] memory _oneTokenWithBNBArr = IPancakeRouter01(pancakeRouterV2Contract).getAmountsOut(1*(10**18), path);

        path  = new address[](2);
        path[0] = bnbContract;
        path[1] = busdContract;
        uint256[] memory _oneBNBWithBusdArr = IPancakeRouter01(pancakeRouterV2Contract).getAmountsOut(1*(10**18), path);

        uint256 _oneTokenWithBNB = _oneTokenWithBNBArr[1];
        uint256 _oneBNBWithBusd = _oneBNBWithBusdArr[1];
        uint256 _curPriceToken = (_oneTokenWithBNB * _oneBNBWithBusd) / (10**18);

        return _curPriceToken;
    }

    event Received(address, uint);
    receive () external payable {
        emit Received(msg.sender, msg.value);
    }

}
