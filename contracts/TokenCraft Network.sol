// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title TokenCraftNetwork
 * @dev Minimal ERC20-like token factory and registry
 * @notice Lets creators deploy simple fungible tokens and keeps a registry of all created tokens
 */
contract TokenCraftNetwork {
    address public owner;

    // --- Minimal ERC20-like token used by the factory ---
    contract CraftToken {
        string public name;
        string public symbol;
        uint8  public decimals = 18;
        uint256 public totalSupply;

        mapping(address => uint256) public balanceOf;
        mapping(address => mapping(address => uint256)) public allowance;

        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);

        constructor(
            string memory _name,
            string memory _symbol,
            uint256 _initialSupply,
            address _owner
        ) {
            name = _name;
            symbol = _symbol;
            totalSupply = _initialSupply;
            balanceOf[_owner] = _initialSupply;
            emit Transfer(address(0), _owner, _initialSupply);
        }

        function transfer(address to, uint256 value) external returns (bool) {
            require(balanceOf[msg.sender] >= value, "Balance too low");
            _transfer(msg.sender, to, value);
            return true;
        }

        function approve(address spender, uint256 value) external returns (bool) {
            allowance[msg.sender][spender] = value;
            emit Approval(msg.sender, spender, value);
            return true;
        }

        function transferFrom(address from, address to, uint256 value) external returns (bool) {
            require(balanceOf[from] >= value, "Balance too low");
            require(allowance[from][msg.sender] >= value, "Allowance too low");
            allowance[from][msg.sender] -= value;
            _transfer(from, to, value);
            return true;
        }

        function _transfer(address from, address to, uint256 value) internal {
            require(to != address(0), "Zero address");
            balanceOf[from] -= value;
            balanceOf[to] += value;
            emit Transfer(from, to, value);
        }
    }

    struct TokenInfo {
        address tokenAddress;
        address creator;
        string  name;
        string  symbol;
        uint256 initialSupply;
        uint256 createdAt;
    }

    // index => TokenInfo
    TokenInfo[] public tokens;

    // creator => list of indexes
    mapping(address => uint256[]) public tokensOf;

    event TokenDeployed(
        uint256 indexed index,
        address indexed tokenAddress,
        address indexed creator,
        string name,
        string symbol,
        uint256 initialSupply
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Deploy a new CraftToken and register it
     * @param name Token name
     * @param symbol Token symbol
     * @param initialSupply Initial supply in wei units (taking 18 decimals into account)
     */
    function deployToken(
        string calldata name,
        string calldata symbol,
        uint256 initialSupply
    ) external returns (address tokenAddr, uint256 index) {
        require(initialSupply > 0, "Supply = 0");

        CraftToken token = new CraftToken(name, symbol, initialSupply, msg.sender);
        tokenAddr = address(token);

        TokenInfo memory info = TokenInfo({
            tokenAddress: tokenAddr,
            creator: msg.sender,
            name: name,
            symbol: symbol,
            initialSupply: initialSupply,
            createdAt: block.timestamp
        });

        tokens.push(info);
        index = tokens.length - 1;
        tokensOf[msg.sender].push(index);

        emit TokenDeployed(index, tokenAddr, msg.sender, name, symbol, initialSupply);
    }

    /**
     * @dev Get number of tokens deployed via this network
     */
    function getTokensCount() external view returns (uint256) {
        return tokens.length;
    }

    /**
     * @dev Get all token indexes created by a specific address
     */
    function getTokensOf(address user) external view returns (uint256[] memory) {
        return tokensOf[user];
    }

    /**
     * @dev Transfer ownership of the TokenCraftNetwork registry
     */
    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Zero address");
        address prev = owner;
        owner = newOwner;
        emit OwnershipTransferred(prev, newOwner);
    }
}
