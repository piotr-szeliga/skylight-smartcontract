// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title VestingLFI
 */
contract VestingLFI is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    struct VestingSchedule {
        // unique id for each beneficiary
        uint256 vestingId;
        // wallet address of beneficiary
        address recipient;
        // start timestamps
        uint256 startTime;
        // duration of the vesting period in seconds
        uint256 vestingPeriod;
        // duration of the vesting cliff in seconds
        uint256 vestingCliff;
        // total amount of tokens to be vested to the beneficiary
        uint256 allocatedAmount;
        // amount of tokens released to be claimed
        uint256 vestedAmount;
        // vesting is ended
        bool isEnded;
    }

    // address of the ERC20 token
    IERC20 private immutable _token;

    // mapping from address to VestingSchedule
    mapping(address => uint256) private vestingScheduleIdsByAddress;

    // mapping from id to VestingSchedule
    mapping(uint256 => VestingSchedule) private vestingSchedulesById;

    // mapping from index to accounts to be took part in vesting
    mapping(uint256 => address) public vestingAccounts;

    uint256 public vestingScheduleCounter = 0;

    uint256 public globalStartTime;

    // value for minutes in a day
    uint32 private MINUTES_IN_DAY;

    event TokenVested(address indexed account, uint256 amount);

    event DepositTokenToContract(address indexed account, uint256 amount);

    event TokenRescueWithdrawn(address indexed account, uint256 amount);

    event WithdrawTokenToContract(uint256 amount);

    event AddedVestingSchedules(address sender, uint256 amount);

    event CreatedVestingSchedule(
        address sender,
        address account,
        uint256 startTime,
        uint256 vestingPeriod,
        uint256 vestingCliff,
        uint256 amount
    );

    /**
     * @dev Creates a vesting contract.
     * @param token_ address of the ERC20 token contract
     */
    constructor(address token_) {
        require(token_ != address(0x0));
        _token = IERC20(token_);

        globalStartTime = 1660176000; //11 August 2022 00:00:00

        MINUTES_IN_DAY = 24 * 60; // 24 * 60 for mainnet, 1 for testnet
    }

    /**
     * @notice Add bulk of vesting schedules
     * @param listOfRecipient address of beneficiary
     * @param listOfVestingPeriod total linear vesting duration in days
     * @param listOfVestingCliff duration in days of the period until vesting is started
     * @param listOfAmount total amount of tokens to be released till the end of the vesting
     */
    function addVestingSchedules(
        address[] memory listOfRecipient,
        uint256[] memory listOfStartTime,
        uint256[] memory listOfVestingPeriod,
        uint256[] memory listOfVestingCliff,
        uint256[] memory listOfAmount
    ) public onlyOwner {
        require(
            listOfRecipient.length == listOfStartTime.length &&
                listOfRecipient.length == listOfVestingPeriod.length &&
                listOfRecipient.length == listOfVestingCliff.length &&
                listOfRecipient.length == listOfAmount.length,
            "Data for Vesting Schedules is invalid."
        );

        uint256 _totalAmount = 0;
        for (uint8 i = 0; i < listOfRecipient.length; i++) {
            createVestingSchedule(
                listOfRecipient[i],
                listOfStartTime[i],
                listOfVestingPeriod[i],
                listOfVestingCliff[i],
                listOfAmount[i]
            );
            _totalAmount += listOfAmount[i];
        }

        emit AddedVestingSchedules(msg.sender, _totalAmount);
    }

    /**
     * @notice Creates a new vesting schedule for a beneficiary.
     * @param _recipient address of beneficiary
     * @param _startTime start time
     * @param _vestingPeriod total linear vesting duration in days
     * @param _vestingCliff duration in days of the period until vesting is started
     * @param _amount total amount of tokens to be released till the end of the vesting
     */
    function createVestingSchedule(
        address _recipient,
        uint256 _startTime,
        uint256 _vestingPeriod,
        uint256 _vestingCliff,
        uint256 _amount
    ) public onlyOwner {
        require(_vestingPeriod > 0, "Vesting period must be > 0");
        require(_amount > 0, "Vesting amount must be > 0");
        require(
            vestingScheduleIdsByAddress[_recipient] == 0,
            "Vesting is already existing for this recipient"
        );

        vestingScheduleCounter++;
        vestingAccounts[vestingScheduleCounter] = _recipient;

        VestingSchedule memory vestingSchedule = VestingSchedule(
            vestingScheduleCounter,
            _recipient,
            _startTime * MINUTES_IN_DAY * 60,
            _vestingPeriod * MINUTES_IN_DAY * 60,
            _vestingCliff * MINUTES_IN_DAY * 60,
            _amount,
            0,
            false
        );

        vestingScheduleIdsByAddress[_recipient] = vestingScheduleCounter;
        vestingSchedulesById[vestingScheduleCounter] = vestingSchedule;

        emit CreatedVestingSchedule(
            msg.sender,
            _recipient,
            _startTime,
            _vestingPeriod,
            _vestingCliff,
            _amount
        );
    }

    /**
     * @notice Claim vested tokens that have vested as of now
     * @param to redirected address of recipient
     */
    function _claimTo(address to) internal {
        require(
            vestingScheduleIdsByAddress[msg.sender] != 0,
            "No existing vesting."
        );

        uint256 id = vestingScheduleIdsByAddress[msg.sender];

        require(!vestingSchedulesById[id].isEnded, "Vesting is ended.");

        require(
            block.timestamp > globalStartTime + vestingSchedulesById[id].startTime,
            "Vesting is not started."
        );

        require(
            block.timestamp >=
                globalStartTime + vestingSchedulesById[id].startTime +
                    vestingSchedulesById[id].vestingCliff,
            "Vesting is not unlocked."
        );

        uint256 _amount = computeClaimableAmount(id);

        require(
            _token.balanceOf(address(this)) > _amount,
            "Not enough remained token on contract"
        );

        if (
            block.timestamp >=
            globalStartTime + vestingSchedulesById[id].startTime +
                vestingSchedulesById[id].vestingPeriod
        ) {
            vestingSchedulesById[id].isEnded = true;
        }

        _token.transfer(to, _amount);

        vestingSchedulesById[id].vestedAmount += _amount;

        emit TokenVested(to, _amount);
    }

    /**
     * @notice Claim vested amount of tokens.
     */
    function claimVestedTokens() external {
        _claimTo(msg.sender);
    }

    /**
     * @notice Claim vested amount of tokens.
     * @param to address of recipient
     */
    function claimVestedTokensTo(address to) external {
        _claimTo(to);
    }

    /**
     * @dev Computes the vested amount of tokens at this moment since last vesting
     * @param id vesting id
     * @return _amount of new tokens vested at this moment since last vesting
     */
    function computeClaimableAmount(uint256 id)
        public
        view
        returns (uint256 _amount)
    {
        if (vestingSchedulesById[id].isEnded) {
            _amount = 0;
        } else {
            if (block.timestamp < globalStartTime + vestingSchedulesById[id].startTime) {
                _amount = 0;
            } else if (
                block.timestamp >=
                globalStartTime + vestingSchedulesById[id].startTime +
                    vestingSchedulesById[id].vestingPeriod
            ) {
                _amount =
                    vestingSchedulesById[id].allocatedAmount -
                    vestingSchedulesById[id].vestedAmount;
            } else {
                if (
                    block.timestamp >=
                    globalStartTime + vestingSchedulesById[id].startTime +
                        vestingSchedulesById[id].vestingCliff
                ) {
                    _amount =
                        (vestingSchedulesById[id].allocatedAmount *
                            (block.timestamp - globalStartTime -
                                vestingSchedulesById[id].startTime)) /
                        vestingSchedulesById[id].vestingPeriod -
                        vestingSchedulesById[id].vestedAmount;
                } else {
                    _amount = 0;
                }
            }
        }
    }

    /**
     * @notice Owner deposit depositVestingAmount to contract.
     * @param _amount amount of tokens which Owner deposit to contract
     */
    function depositVestingAmount(uint256 _amount)
        public
        onlyOwner
        nonReentrant
    {
        _token.transferFrom(msg.sender, address(this), _amount);

        emit DepositTokenToContract(msg.sender, _amount);
    }

    /**
     * @notice Owner withdraw token from contract
     * @param _amount amount of tokens which Owner withdraw from contract
     */
    function rescueWithdraw(uint256 _amount) public onlyOwner nonReentrant {
        _token.transfer(msg.sender, _amount);

        emit TokenRescueWithdrawn(msg.sender, _amount);
    }

    function getStartTime(uint256 id) public view returns (uint256) {
        return globalStartTime + vestingSchedulesById[id].startTime;
    }

    /**
     * @dev Returns the vesting account address at the given id.
     * @return the vesting account address
     */
    function getVestingAccountById(uint256 id) public view returns (address) {
        require(id <= vestingScheduleCounter, "vesting: index out of bounds");
        return vestingSchedulesById[id].recipient;
    }

    /**
     * @notice Returns the vesting schedule struct for a given address.
     * @return the vesting schedule structure information
     */
    function getVestingScheduleByAddress(address account)
        public
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedulesById[vestingScheduleIdsByAddress[account]];
    }

    /**
     * @notice Returns the vesting schedule struct for a given id.
     * @return the vesting schedule structure information
     */
    function getVestingScheduleById(uint256 id)
        public
        view
        returns (VestingSchedule memory)
    {
        return vestingSchedulesById[id];
    }

    /**
     * @dev Returns the address of the ERC20 token managed by the vesting contract.
     */
    function getToken() external view returns (address) {
        return address(_token);
    }

    /**
     * @dev Returns the number of vesting accounts managed by this contract.
     * @return the number of vesting accounts
     */
    function getVestingAccountsCount() public view returns (uint256) {
        return vestingScheduleCounter;
    }

    /**
     * @dev Returns the number of vesting accounts managed by this contract.
     * @param account address of vesting
     * @return the claimable token amount
     */
    function getClaimable(address account) public view returns (uint256) {
        return computeClaimableAmount(vestingScheduleIdsByAddress[account]);
    }
}
