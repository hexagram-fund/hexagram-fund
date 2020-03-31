pragma solidity ^0.5.0;

contract UtilHexagram {
    uint ethWei = 1 ether;

    function getDynamicRatio(uint height) internal view returns (uint) {
        if (height == 1) {
            return 50;
        }
        if (height == 2) {
            return 30;
        }
        if (height == 3) {
            return 20;
        }
        if (height == 4) {
            return 10;
        }
        if (height >= 5 && height <= 9) {
            return 5;
        }
        if (height >= 10) {
            return 2;
        }
        return 0;
    }

    function getLineLevel(uint investAmount) internal view returns (uint) {
        if (investAmount >= 100 * ethWei && investAmount <= 400 * ethWei) {
            return 1;
        }
        if (investAmount >= 500 * ethWei && investAmount <= 900 * ethWei) {
            return 2;
        }
        if (investAmount >= 1000 * ethWei && investAmount <= 2900 * ethWei) {
            return 3;
        }
        if (investAmount >= 3000 * ethWei) {
            return 4;
        }
        return 0;
    }

    function getScByLevel(uint level) internal view returns (uint) {
        if (level == 1) {
            return 4;
        }
        if (level == 2) {
            return 7;
        }
        if (level == 3) {
            return 10;
        }
        if (level == 4) {
            return 12;
        }
        return 0;
    }

    function getFloorIndex(uint floor) internal pure returns (uint) {
        if (floor == 1) {
            return 1;
        }
        if (floor == 2) {
            return 2;
        }
        if (floor == 3) {
            return 3;
        }
        if (floor == 4) {
            return 4;
        }
        if (floor >= 5 && floor <= 9) {
            return 5;
        }
        if (floor >= 10) {
            return 6;
        }

        return 0;
    }

    function getRecommendScaleByLevelAndTim(uint floorIndex) internal pure returns (uint){
        if (floorIndex == 1) {
            return 50;
        }
        if (floorIndex == 2) {
            return 30;
        }
        if (floorIndex == 3) {
            return 20;
        }
        if (floorIndex == 4) {
            return 10;
        }
        if (floorIndex == 5) {
            return 5;
        }
        if (floorIndex >= 6) {
            return 2;
        }
        return 0;
    }

    function isEmpty(string memory str) internal pure returns (bool) {
        if (bytes(str).length == 0) {
            return true;
        }

        return false;
    }
}

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
contract Context {
    // Empty internal constructor, to prevent people from mistakenly deploying
    // an instance of this contract, which should be used via inheritance.
    constructor() internal {}
    // solhint-disable-previous-line no-empty-blocks

    function _msgSender() internal view returns (address) {
        return msg.sender;
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        _owner = _msgSender();
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return _msgSender() == _owner;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface PAXToken {
    function transfer(address _to, uint256 _value) external returns (bool);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool);
    function balanceOf(address _addr) external view returns (uint256);
}

contract Hexagram is UtilHexagram, Ownable {

    using SafeMath for *;

    string constant private name = "Hexagram Official";

    uint ethWei = 1 ether;

    PAXToken private paxToken;

    address payable private devAddr0 = address(0xF71DA70CDc964f3dc81579Ed215B6cd72C0e43af);
    address payable private devAddr1 = address(0x0FC715BC13ed6ba36300Be4f2965357B5c5FB00c);
    address payable private bigPool = address(0x5262b6fe3a6B96738D2b5DE905B02ad84058c7CF);

    struct User {
        uint id;
        address userAddress;
        string inviteCode;
        string referrer;
        bool notFirst; 
        uint staticLevel; 
        uint allInvest; 
        uint freezeAmount; 
        uint unlockAmount; 
        uint unlockAmountRedeemTime;
        uint allStaticAmount; 
        uint hisStaticAmount; 
        uint dynamicWithdrawn; 
        uint hisDynamicAmount; 
        uint staticWithdrawn; 
        Invest[] invests;
        uint staticFlag; 

        mapping(uint => mapping(uint => uint)) dynamicProfits;
        uint reInvestCount;
        uint inviteAmount;

        uint index;
        DayInvite[] dayInvites;
    }

    struct Invest {
        address userAddress;
        uint investAmount;
        uint investTime;
        uint realityInvestTime;
        uint times;
        bool isSuspendedInvest;
    }

    struct DayInvite {
        uint day;
        uint invite;
    }

    uint coefficient = 10;
    uint startTime;
    uint baseTime;
    uint investCount = 0;
    uint investMoney = 0;
    uint uid = 0;
    uint investPeriod = 3;
    uint suspendedTime = 0;
    uint suspendedDays = 0 days;
    uint lastInvestTime = 0;
    mapping(address => User) userMapping;
    mapping(string => address) addressMapping;
    mapping(uint => address) public indexMapping;
    mapping(uint => uint) private everyDayInvestMapping;
    uint baseLimit = 20000 * ethWei;

    modifier isHuman() {
        address addr = msg.sender;
        uint codeLength;

        assembly {codeLength := extcodesize(addr)}
        require(codeLength == 0, "sorry humans only");
        require(tx.origin == msg.sender, "sorry, human only");
        _;
    }

    modifier gameStarted() {
        require(gameStart(), "game not start");
        _;
    }

    modifier isSuspended() {
        require(notSuspended(), "suspended");
        _;
    }

    event LogInvestIn(address indexed who, uint indexed uid, uint amount, uint time, uint investTime, string inviteCode, string referrer, uint t);
    event LogWithdrawProfit(address indexed who, uint indexed uid, uint amount, uint time, uint t);
    event LogRedeem(address indexed who, uint indexed uid, uint amount, uint now);

    constructor () public {
        paxToken = PAXToken(0x8E870D67F660D95d5be530380D0eC0bd388289E1);
    }

    function() external payable {
    }

    function activeGame(uint time, uint _baseTime) external onlyOwner
    {
        require(time > now, "invalid game start time");
        startTime = time;

        if (baseTime == 0) {
            baseTime = _baseTime;
        }
    }

    function gameStart() private view returns (bool) {
        return startTime != 0 && now > startTime;
    }

    function investIn(string memory inviteCode, string memory referrer, uint amount)
    public
    isHuman()
    gameStarted()
    {
        require(check(amount), "invalid amount");
        require(paxToken.transferFrom(msg.sender, address(this), amount), "transferfrom pax token failed");
        uint investTime = getInvestTime(amount);
        uint investDay = getCurrentInvestDay(investTime);
        everyDayInvestMapping[investDay] = amount.add(everyDayInvestMapping[investDay]);
        User storage user = userMapping[msg.sender];
        if (user.id == 0) {
            require(!isEmpty(inviteCode), "empty invite code");
            address referrerAddr = getUserAddressByCode(referrer);
            require(uint(referrerAddr) != 0, "referer not exist");
            require(referrerAddr != msg.sender, "referrer can't be self");
            require(!isUsed(inviteCode), "invite code is used");

            registerUser(msg.sender, inviteCode, referrer);
        }

        if (user.notFirst) {
            require(user.freezeAmount == 0 && user.unlockAmount == 0, "your invest not unlocked");
        } else {
            user.notFirst = true;
        }

        user.allInvest = user.allInvest.add(amount);
        user.freezeAmount = amount;
        user.staticLevel = getLineLevel(amount);

        Invest memory invest = Invest(msg.sender, amount, investTime, now, 0, !notSuspended(investTime));
        user.invests.push(invest);
        lastInvestTime = investTime;

        investCount = investCount.add(1);
        investMoney = investMoney.add(amount);
        
        uint profitsDay = getDayForProfits(investTime);
        if (!isEmpty(user.referrer)) {
            address referrerAddr = getUserAddressByCode(user.referrer);
            userMapping[referrerAddr].inviteAmount++;

            uint currentInviteAmount = userMapping[referrerAddr].inviteAmount;
            uint currentLen = userMapping[referrerAddr].dayInvites.length;

            if (currentLen == 0 || profitsDay > userMapping[referrerAddr].dayInvites[currentLen-1].day){
                userMapping[referrerAddr].dayInvites.push(DayInvite(profitsDay, currentInviteAmount));
            } else {
                userMapping[referrerAddr].dayInvites[currentLen-1].invite = currentInviteAmount;
            }
        }

        storeDynamicPreProfits(msg.sender, profitsDay);

        sendFeetoAdmin(amount);
        sendPrizeToPool(amount);

        emit LogInvestIn(msg.sender, user.id, amount, now, investTime, user.inviteCode, user.referrer, 0);
    }

    function reInvestIn(uint appendAmount) public gameStarted() {
        require(appendAmount == 0);
        User storage user = userMapping[msg.sender];
        require(user.id > 0, "user haven't invest in round before");
        if (appendAmount > 0) {
            require(paxToken.transferFrom(msg.sender, address(this), appendAmount), "transferfrom pax token failed");
        }
        
        calStaticProfitInner(msg.sender);
        require(user.freezeAmount == 0, "user have had invest in round");
        require(user.unlockAmount > 0, "user must have unlockAmount");
        uint reInvestAmount = user.unlockAmount.add(appendAmount);
        require(check(reInvestAmount), "invalid append amount");

        bool isEnough;
        uint sendMoney;
        bool ended = sendAllProfits();
        if (ended) {
            return;
        }

        uint investTime = now;
        uint leastAmount = reInvestAmount.mul(3).div(100);
        (isEnough, sendMoney) = isEnoughBalance(leastAmount);
        if (!isEnough) {
            if (sendMoney > 0) {
                sendMoneyToUser(msg.sender, sendMoney);
            }
            endRound();
            return;
        }

        user.unlockAmount = 0;
        user.allInvest = user.allInvest.add(reInvestAmount);
        user.freezeAmount = user.freezeAmount.add(reInvestAmount);
        user.staticLevel = getLineLevel(user.freezeAmount);
        user.reInvestCount = user.reInvestCount.add(1);
        user.unlockAmountRedeemTime = 0;

        Invest memory invest = Invest(msg.sender, reInvestAmount, investTime, now, 0, !notSuspended(investTime));
        user.invests.push(invest);
        if (investTime > lastInvestTime) {
            lastInvestTime = investTime;
        }

        investCount = investCount.add(1);
        investMoney = investMoney.add(reInvestAmount);

        storeDynamicPreProfits(msg.sender, getDayForProfits(investTime));

        sendFeetoAdmin(reInvestAmount);
        sendPrizeToPool(reInvestAmount);
        emit LogInvestIn(msg.sender, user.id, reInvestAmount, now, investTime, user.inviteCode, user.referrer, 1);
    }

    function sendAllProfits() private returns(bool) {
        User storage user = userMapping[msg.sender];
        bool isEnough;
        uint sendMoney;
        uint resultMoney;
        uint index;
        (index, sendMoney) = calDynamicProfits(msg.sender);
        uint tmpDynamicAmount = calReverseDynamic(msg.sender);
        sendMoney = sendMoney.add(tmpDynamicAmount);
        if (index > userMapping[msg.sender].index) {
            userMapping[msg.sender].index = index;
        }
        if (sendMoney > 0) {
            (isEnough, sendMoney) = isEnoughBalance(sendMoney);

            if (sendMoney > 0) {
                user.dynamicWithdrawn = user.dynamicWithdrawn.add(sendMoney);
                user.hisDynamicAmount = user.hisDynamicAmount.add(sendMoney);
                sendMoneyToUser(msg.sender, sendMoney);
                emit LogWithdrawProfit(msg.sender, user.id, sendMoney, now, 2);
            }
            if (!isEnough) {
                endRound();
                return true;
            }
        }

        sendMoney = user.allStaticAmount;
        (isEnough, resultMoney) = isEnoughBalance(sendMoney);
        if (resultMoney > 0) {
            sendMoneyToUser(msg.sender, resultMoney);
        }
        user.staticWithdrawn = user.staticWithdrawn.add(sendMoney);
        user.allStaticAmount = 0;
        emit LogWithdrawProfit(msg.sender, user.id, resultMoney, now, 1);

        if (!isEnough) {
            endRound();
            return true;
        }

        return false;
    }

    function isEnoughBalance(uint sendMoney) private view returns (bool, uint){
        uint balance = paxToken.balanceOf(address(this));
        if (sendMoney >= balance) {
            return (false, balance);
        } else {
            return (true, sendMoney);
        }
    }

    function check(uint amount) private returns(bool) {
        return amount >= 100 * ethWei && amount <= 5000 * ethWei && amount == amount.div(ethWei).div(100).mul(ethWei).mul(100);
    }

    function isEnoughBalanceToRedeem(uint sendMoney, uint reInvestCount, uint profitsAmount) private view returns (bool, uint){
        uint deductedStaticAmount = getDeductedAmount(reInvestCount, profitsAmount);
        if (sendMoney <= deductedStaticAmount) {
            sendMoney = 0;
        } else {
            sendMoney = sendMoney.sub(deductedStaticAmount);
        }

        return isEnoughBalance(sendMoney);
    }

    function getDeductedAmount(uint reInvestCount, uint profitsAmount) private pure returns(uint) {
        uint deductedStaticAmount = 0;
        if (reInvestCount >= 0 && reInvestCount <= 20) {
            deductedStaticAmount = profitsAmount.mul(5).div(10);
        }
        if (reInvestCount > 20 && reInvestCount <= 30) {
            deductedStaticAmount = profitsAmount.mul(4).div(10);
        }
        if (reInvestCount > 30 && reInvestCount <= 40) {
            deductedStaticAmount = profitsAmount.mul(3).div(10);
        }
        if (reInvestCount > 40 && reInvestCount <= 50) {
            deductedStaticAmount = profitsAmount.mul(2).div(10);
        }
        if (reInvestCount > 50 && reInvestCount <= 60) {
            deductedStaticAmount = profitsAmount.mul(1).div(10);
        }
        if (reInvestCount > 60 && reInvestCount <= 70) {
            deductedStaticAmount = profitsAmount.mul(5).div(100);
        }

        return deductedStaticAmount;
    }

    function sendMoneyToUser(address userAddress, uint money) private {
        require(paxToken.transfer(userAddress, money), "transfer pax failed");
    }

    function calReverseDynamic(address userAddress) private view returns (uint){
        User memory user = userMapping[userAddress];
        if (user.id == 0 || user.freezeAmount == 0 || user.inviteAmount < 20 || isEmpty(user.referrer) || user.invests.length == 0) {
            return 0;
        }
        Invest memory invest = user.invests[user.invests.length.sub(1)];
        uint startDayOneZero = invest.investTime.sub(8 hours).div(1 days).mul(1 days).add(1 days);
        uint startDayTwoZero = startDayOneZero.add(1 days);
        uint startDayThreeZero = startDayOneZero.add(2 days);

        string memory tmpReferrer = user.referrer;
        uint totalReverseDynamic = 0;
        for(uint i = 1; i <= 20; i++){
            if (isEmpty(tmpReferrer)) {
                break;
            }
            address tmpUserAddr = addressMapping[tmpReferrer];
            uint[] memory sameDaysAmount = getAncestorSameInvestDays(startDayOneZero,startDayTwoZero,startDayThreeZero, tmpUserAddr);
            uint dynamicRatio = getDynamicRatio(i);

            for(uint j = 0; j< sameDaysAmount.length; j++){
                uint award = 0;
                uint sameAmount = sameDaysAmount[j];
                if(sameAmount == 0){
                    continue;
                }
                uint scRatio = getScByLevel(getLineLevel(sameAmount));

                uint calAmount = sameAmount;
                if(calAmount > invest.investAmount){
                    calAmount = invest.investAmount;
                }
                award = calAmount.mul(scRatio).div(1000).mul(dynamicRatio).div(100);
                totalReverseDynamic = totalReverseDynamic.add(award);
            }
            tmpReferrer = userMapping[tmpUserAddr].referrer;
        }
        return totalReverseDynamic;
    }

    function getAncestorSameInvestDays(uint startDayOneZero, uint startDayTwoZero, uint startDayThreeZero, address ancestor) private view returns (uint[] memory){
        User memory user = userMapping[ancestor];
        uint[] memory sameDaysAmount = new uint[](3);
        if(user.invests.length == 0){
            return sameDaysAmount;
        }
        uint investNum = user.invests.length;
        for(uint i=investNum ; i> 0 ; i--){
            Invest memory invest = user.invests[i-1];
            uint ancestorStartDayOneZero = invest.investTime.sub(8 hours).div(1 days).mul(1 days).add(1 days);
            if(ancestorStartDayOneZero > startDayThreeZero){
                continue;
            }
            uint ancestorStartDayThreeZero = ancestorStartDayOneZero.add(2 days);
            if(ancestorStartDayThreeZero < startDayOneZero){
                break;
            }
            uint ancestorStartDayTwoZero = ancestorStartDayOneZero.add(1 days);
            if(ancestorStartDayOneZero == startDayOneZero || ancestorStartDayOneZero == startDayTwoZero || ancestorStartDayOneZero == startDayThreeZero){
                sameDaysAmount[0] = invest.investAmount;
            }
            if(ancestorStartDayTwoZero == startDayOneZero || ancestorStartDayTwoZero == startDayTwoZero || ancestorStartDayTwoZero == startDayThreeZero){
                sameDaysAmount[1] = invest.investAmount;
            }
            if(ancestorStartDayThreeZero == startDayOneZero || ancestorStartDayThreeZero == startDayTwoZero || ancestorStartDayThreeZero == startDayThreeZero){
                sameDaysAmount[2] = invest.investAmount;
            }
        }
        return sameDaysAmount;
    }

    function calStaticProfitInner(address payable userAddr) private returns (uint){
        User storage user = userMapping[userAddr];
        if (user.id == 0 || user.freezeAmount == 0 || user.invests.length == 0) {
            return 0;
        }
        uint allStatic = 0;
        uint i = user.invests.length.sub(1);
        Invest storage invest = user.invests[i];
        uint scale;
        scale = getScByLevel(user.staticLevel);
        uint startDay = invest.investTime.sub(8 hours).div(1 days).mul(1 days);
        if (now.sub(8 hours) < startDay) {
            return 0;
        }
        uint staticGaps = now.sub(8 hours).sub(startDay).div(1 days);

        if (staticGaps > investPeriod) {
            staticGaps = investPeriod;
        }
        if (staticGaps > invest.times) {
            allStatic = staticGaps.sub(invest.times).mul(scale).mul(invest.investAmount).div(1000);
            invest.times = staticGaps;
        }

        (uint unlockDay, uint unlockAmountRedeemTime) = getUnLockDay(invest.investTime);

        if (unlockDay >= investPeriod && user.freezeAmount != 0) {
            user.staticFlag = user.staticFlag.add(1);
            user.freezeAmount = user.freezeAmount.sub(invest.investAmount);
            user.unlockAmount = user.unlockAmount.add(invest.investAmount);
            user.unlockAmountRedeemTime = unlockAmountRedeemTime;
            user.staticLevel = getLineLevel(user.freezeAmount);
        }

        allStatic = allStatic.mul(coefficient).div(10);
        user.allStaticAmount = user.allStaticAmount.add(allStatic);
        user.hisStaticAmount = user.hisStaticAmount.add(allStatic);
        return user.allStaticAmount;
    }

    function getStaticProfits(address userAddr) public view returns(uint, uint, uint) {
        User memory user = userMapping[userAddr];
        if (user.id == 0 || user.invests.length == 0) {
            return (0, 0, 0);
        }
        if (user.freezeAmount == 0) {
            return (0, user.hisStaticAmount, user.staticWithdrawn);
        }
        uint allStatic = 0;
        uint i = user.invests.length.sub(1);
        Invest memory invest = user.invests[i];
        uint scale;
        scale = getScByLevel(user.staticLevel);
        uint startDay = invest.investTime.sub(8 hours).div(1 days).mul(1 days);
        if (now.sub(8 hours) < startDay) {
            return (0, user.hisStaticAmount, user.staticWithdrawn);
        }
        uint staticGaps = now.sub(8 hours).sub(startDay).div(1 days);

        if (staticGaps > investPeriod) {
            staticGaps = investPeriod;
        }
        if (staticGaps > invest.times) {
            allStatic = staticGaps.sub(invest.times).mul(scale).mul(invest.investAmount).div(1000);
        }

        allStatic = allStatic.mul(coefficient).div(10);
        return (
            user.allStaticAmount.add(allStatic),
            user.hisStaticAmount.add(allStatic),
            user.staticWithdrawn
        );
    }

    function storeDynamicPreProfits(address userAddr, uint investDay) private {
        uint freezeAmount = userMapping[userAddr].freezeAmount;
        if (freezeAmount >= 100 * ethWei) {
            uint scale;
            scale = getScByLevel(userMapping[userAddr].staticLevel);            
            updateReferrerPreProfits(userMapping[userAddr].referrer, investDay, freezeAmount, scale);
        }
    }

    function updateReferrerPreProfits(string memory referrer, uint day, uint freezeAmount, uint scale) private {
        string memory tmpReferrer = referrer;

        for (uint i = 1; i <= 20; i++) {
            if (isEmpty(tmpReferrer)) {
                break;
            }
            uint floorIndex = getFloorIndex(i);
            address tmpUserAddr = addressMapping[tmpReferrer];

            uint baseAmount;
            if (freezeAmount < userMapping[tmpUserAddr].freezeAmount) {
                baseAmount = freezeAmount;
            } else {
                baseAmount = userMapping[tmpUserAddr].freezeAmount;
            }

            uint staticProfits = baseAmount.mul(scale).div(1000);

            for (uint j = 0; j < investPeriod; j++) {
                uint dayIndex = day.add(j);
                uint currentMoney = userMapping[tmpUserAddr].dynamicProfits[floorIndex][dayIndex];
                userMapping[tmpUserAddr].dynamicProfits[floorIndex][dayIndex] = currentMoney.add(staticProfits);
            }
            tmpReferrer = userMapping[tmpUserAddr].referrer;
        }
    }

    function calDynamicProfits(address user) private view returns (uint, uint) {
        uint[] memory params = new uint[](6);
        params[0] = userMapping[user].invests.length;
        if (params[0] == 0) {
            return (0, 0);
        }
        
        params[2] = getDayForProfits(userMapping[user].invests[params[0]-1].investTime);
        uint totalProfits;

        for (uint j = 0; j < investPeriod; j++) {
            params[4] = params[2].add(j);
            (params[3], params[5]) = getAndUpdateDayInviteAmount(user, params[4]);
            
            uint floorCap = getFloorIndex(params[5]);
            for (uint i = 1; i <= floorCap; i++) {
                uint staticProfits = userMapping[user].dynamicProfits[i][params[4]];
                uint recommendSc = getRecommendScaleByLevelAndTim(i);
                if (recommendSc != 0) {
                    uint tmpDynamicAmount = staticProfits.mul(recommendSc);
                    totalProfits = tmpDynamicAmount.div(100).add(totalProfits);
                }
            }
        }

        return (params[3], totalProfits);
    }

    function getAndUpdateDayInviteAmount(address user, uint day) private view returns(uint, uint) {
        uint index = userMapping[user].index;
        if (userMapping[user].dayInvites.length == 0) {
            return (0, 0);
        }
        uint currentDay = userMapping[user].dayInvites[index].day;
        uint inviteAmount = userMapping[user].dayInvites[index].invite;

        if (day < currentDay) {
            return (index, 0);
        }
        
        if (day == currentDay || index == userMapping[user].dayInvites.length-1) {
            return (index, inviteAmount);
        }

        uint nextDay;
        uint nextInviteAmount;
        for (uint i = index+1; i < userMapping[user].dayInvites.length; i++) {
            nextDay = userMapping[user].dayInvites[i].day;
            nextInviteAmount = userMapping[user].dayInvites[i].invite;

            if (day < nextDay) {
                return (index, inviteAmount);
            }

            if (day == nextDay) {
                return (i, nextInviteAmount);
            }

            if (day > nextDay) {
                index = i;
                inviteAmount = nextInviteAmount;
            }
        }

        return (index, inviteAmount);
    }

    function registerUserInfo(address user, string calldata inviteCode, string calldata referrer) external onlyOwner {
        registerUser(user, inviteCode, referrer);
    }

    function redeem()
    public
    isHuman()
    isSuspended()
    gameStarted()
    {
        User storage user = userMapping[msg.sender];
        require(user.id > 0, "user not exist");
        calStaticProfitInner(msg.sender);
        require(now >= user.unlockAmountRedeemTime, "redeem time non-arrival");

        uint sendMoney = user.unlockAmount;
        require(sendMoney != 0, "you don't have unlock money");

        bool ended = sendAllProfits();
        if (ended) {
            return;
        }

        uint profitsAmount = user.hisStaticAmount.add(user.hisDynamicAmount);
        bool isEnough = false;
        uint resultMoney = 0;

        (isEnough, resultMoney) = isEnoughBalanceToRedeem(sendMoney, user.reInvestCount, profitsAmount);

        if (!isEnough) {
            endRound();
        }
        if (resultMoney > 0) {
            sendMoneyToUser(msg.sender, resultMoney);
        }
        user.unlockAmount = 0;
        user.staticLevel = getLineLevel(user.freezeAmount);
        user.reInvestCount = 0;
        user.hisStaticAmount = 0;
        user.hisDynamicAmount = 0;
        emit LogRedeem(msg.sender, user.id, sendMoney, now);

        string memory referrer = user.referrer;
        address referrerAddr = getUserAddressByCode(referrer);
        if (!isEmpty(referrer) && userMapping[referrerAddr].inviteAmount > 0) {
            userMapping[referrerAddr].inviteAmount--;
        }
    }

    function getUnLockDay(uint investTime) private view returns (uint unlockDay, uint unlockAmountRedeemTime){
        uint gameStartTime = startTime;
        if (gameStartTime <= 0 || investTime > now || investTime < gameStartTime) {
            return (0, 0);
        }
        unlockDay = now.sub(investTime).div(1 days);
        unlockAmountRedeemTime = 0;
        if (unlockDay < investPeriod) {
            return (unlockDay, unlockAmountRedeemTime);
        }
        unlockAmountRedeemTime = investTime.add(uint(3).mul(1 days));

        uint stopTime = suspendedTime;
        if (stopTime == 0) {
            return (unlockDay, unlockAmountRedeemTime);
        }

        uint stopDays = suspendedDays;
        uint stopEndTime = stopTime.add(stopDays.mul(1 days));
        if (investTime < stopTime){
            if(unlockAmountRedeemTime >= stopEndTime){
                unlockAmountRedeemTime = unlockAmountRedeemTime.add(stopDays.mul(1 days));
            }else if(unlockAmountRedeemTime < stopEndTime && unlockAmountRedeemTime > stopTime){
                unlockAmountRedeemTime = stopEndTime.add(unlockAmountRedeemTime.sub(stopTime));
            }
        }
        if (investTime >= stopTime && investTime < stopEndTime){
            if(unlockAmountRedeemTime >= stopEndTime){
                unlockAmountRedeemTime = unlockAmountRedeemTime.add(stopEndTime.sub(investTime));
            }else if(unlockAmountRedeemTime < stopEndTime && unlockAmountRedeemTime > stopTime){
                unlockAmountRedeemTime = stopEndTime.add(uint(3).mul(1 days));
            }
        }
        return (unlockDay, unlockAmountRedeemTime);
    }

    function endRound() private {
        startTime = 0;
    }

    function isUsed(string memory code) public view returns (bool) {
        address user = getUserAddressByCode(code);
        return uint(user) != 0;
    }

    function getUserAddressByCode(string memory code) public view returns (address) {
        return addressMapping[code];
    }

    function sendFeetoAdmin(uint amount) private {
        sendMoneyToUser(devAddr0, amount.div(100));
        sendMoneyToUser(devAddr1, amount.div(100));
    }

    function sendPrizeToPool(uint amount) private {
        sendMoneyToUser(bigPool, amount.div(100));
    }

    function getGameInfo() public isHuman() view returns (uint, uint, uint, uint, uint, uint, uint, uint, bool) {
        uint dayInvest;
        dayInvest = everyDayInvestMapping[getCurrentInvestDay(now)];
        return (
        uid,
        startTime,
        investCount,
        investMoney,
        coefficient,
        dayInvest,
        baseLimit,
        now,
        gameStart()
        );
    }

    function getUserInfo(address user) public isHuman() view returns (
        uint[17] memory ct, string memory inviteCode, string memory referrer
    ) {
        uint[] memory params = new uint[](4);

        User memory userInfo = userMapping[user];

        ct[0] = userInfo.id;
        ct[1] = userInfo.staticLevel;
        ct[2] = userInfo.allInvest;
        Invest memory invest;
        if (userInfo.invests.length == 0) {
            ct[3] = 0;
        } else {
            invest = userInfo.invests[userInfo.invests.length-1];
            ct[3] = getScByLevel(userInfo.staticLevel);
        }
        ct[4] = userInfo.inviteAmount;
        ct[5] = userInfo.freezeAmount;
        ct[6] = userInfo.staticWithdrawn.add(userInfo.dynamicWithdrawn);
        ct[7] = userInfo.staticWithdrawn;
        ct[8] = userInfo.dynamicWithdrawn;
        (params[0], params[1], params[2]) = getStaticProfits(user);
        ct[9] = params[0];
        (params[1], params[2]) = calDynamicProfits(user);
        params[1] = calReverseDynamic(user);
        ct[10] = params[2].add(params[1]);
        (params[2], params[3]) = getUnLockDay(invest.investTime);
        ct[11] = params[2];
        ct[12] = params[3];
        ct[13] = userInfo.reInvestCount;
        ct[14] = userInfo.unlockAmount;
        ct[15] = invest.investTime;
        uint profits = userInfo.hisStaticAmount.add(userInfo.hisDynamicAmount).add(ct[9]).add(ct[10]);
        ct[16] = getDeductedAmount(ct[13], profits);

        inviteCode = userInfo.inviteCode;
        referrer = userInfo.referrer;
        return (
        ct,
        inviteCode,
        referrer
        );
    }

    function getInvestTime(uint amount) public view returns (uint){
        uint lastTime = lastInvestTime;

        uint investTime = 0;

        if (baseLimit >= amount.add(everyDayInvestMapping[getCurrentInvestDay(now)])) {
            if (now < lastTime) {
                investTime = lastTime.add(1 minutes);
            } else {
                investTime = now;
            }
        } else {
            investTime = lastTime.add(1 minutes);
            if (baseLimit < amount.add(everyDayInvestMapping[getCurrentInvestDay(investTime)])) {
                investTime = getCurrentInvestDay(lastTime).mul(1 days).add(baseTime);
            }
        }
        return investTime;
    }


    function getDayForProfits(uint investTime) private pure returns (uint) {
        return investTime.sub(8 hours).div(1 days);
    }
    function getCurrentInvestDay(uint investTime) public view returns (uint){
        uint gameStartTime = baseTime;
        if (gameStartTime == 0 || investTime < gameStartTime) {
            return 0;
        }
        uint currentInvestDay = investTime.sub(gameStartTime).div(1 days).add(1);
        return currentInvestDay;
    }
    
    function notSuspended() public view returns (bool) {
        uint sTime = suspendedTime;
        uint sDays = suspendedDays;
        return sTime == 0 || now < sTime || now >= sDays.mul(1 days).add(sTime);
    }

    function notSuspended(uint investTime) public view returns (bool) {
        uint sTime = suspendedTime;
        uint sDays = suspendedDays;
        return sTime == 0 || investTime < sTime || investTime >= sDays.mul(1 days).add(sTime);
    }

    function suspended(uint stopTime, uint stopDays) external onlyOwner gameStarted {
        require(stopTime > now, "stopTime shoule gt now");
        require(stopTime > lastInvestTime, "stopTime shoule gt lastInvestTime");
        suspendedTime = stopTime;
        suspendedDays = stopDays;
    }

    function getAvailableReInvestInAmount(address userAddr) public view returns (uint){
        User memory user = userMapping[userAddr];
        if(user.freezeAmount == 0){
            return user.unlockAmount;
        }else{
            Invest memory invest = user.invests[user.invests.length - 1];
            (uint unlockDay, uint unlockAmountRedeemTime) = getUnLockDay(invest.investTime);
            if(unlockDay >= investPeriod){
                return invest.investAmount;
            }
        }
        return 0;
    }

    function getAvailableRedeemAmount(address userAddr) public view returns (uint){
        User memory user = userMapping[userAddr];
        if (now < user.unlockAmountRedeemTime) {
            return 0;
        }
        uint allUnlock = user.unlockAmount;
        if (user.freezeAmount > 0) {
            Invest memory invest = user.invests[user.invests.length - 1];
            (uint unlockDay, uint unlockAmountRedeemTime) = getUnLockDay(invest.investTime);
            if (unlockDay >= investPeriod && now >= unlockAmountRedeemTime) {
                allUnlock = invest.investAmount;
            }
        }
        return allUnlock;
    }

    function registerUser(address user, string memory inviteCode, string memory referrer) private {
        User storage userInfo = userMapping[user];
        uid++;
        userInfo.id = uid;
        userInfo.userAddress = user;
        userInfo.inviteCode = inviteCode;
        userInfo.referrer = referrer;

        addressMapping[inviteCode] = user;
        indexMapping[uid] = user;
    }
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "mul overflow");

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "div zero");
        // Solidity only automatically asserts when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "lower sub bigger");
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "overflow");

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "mod zero");
        return a % b;
    }
}
