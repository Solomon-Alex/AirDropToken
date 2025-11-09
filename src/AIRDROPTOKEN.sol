// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AIRDROPTOKEN is ERC20, Ownable {
    uint256 public constant MINT_AMOUNT = 100 * 10**18;
    
    mapping(address => bool) public hasClaimedAirdrop;
    bool public airdropActive;
    
    event AirdropClaimed(address indexed recipient, uint256 amount);
    event AirdropStatusChanged(bool active);
    event BatchAirdropCompleted(uint256 recipientCount, uint256 totalAmount);

    constructor() ERC20("AIRDROPTOKEN", "ADT") Ownable(msg.sender) {
        airdropActive = true;
    }

    /**
     * @dev Allows users to claim their airdrop tokens
     */
    function claimAirdrop() external {
        require(airdropActive, "Airdrop is not active");
        require(!hasClaimedAirdrop[msg.sender], "Airdrop already claimed");
        
        hasClaimedAirdrop[msg.sender] = true;
        _mint(msg.sender, MINT_AMOUNT);
        
        emit AirdropClaimed(msg.sender, MINT_AMOUNT);
    }

    /**
     * @dev Owner can perform batch airdrop to multiple addresses
     * @param recipients Array of addresses to receive airdrop
     */
    function batchAirdrop(address[] calldata recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        
        uint256 totalMinted = 0;
        
        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            require(recipient != address(0), "Invalid recipient address");
            
            if (!hasClaimedAirdrop[recipient]) {
                hasClaimedAirdrop[recipient] = true;
                _mint(recipient, MINT_AMOUNT);
                totalMinted += MINT_AMOUNT;
                
                emit AirdropClaimed(recipient, MINT_AMOUNT);
            }
        }
        
        emit BatchAirdropCompleted(recipients.length, totalMinted);
    }

    /**
     * @dev Toggle airdrop active status
     * @param active New status for airdrop
     */
    function setAirdropActive(bool active) external onlyOwner {
        airdropActive = active;
        emit AirdropStatusChanged(active);
    }

    /**
     * @dev Check if an address has claimed airdrop
     * @param account Address to check
     * @return bool indicating if airdrop was claimed
     */
    function hasClaimedAirdropView(address account) external view returns (bool) {
        return hasClaimedAirdrop[account];
    }

    /**
     * @dev Owner can mint additional tokens if needed
     * @param to Address to mint tokens to
     * @param amount Amount of tokens to mint
     */
    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    /**
     * @dev Returns the number of decimals used for token amounts
     */
    function decimals() public pure override returns (uint8) {
        return 18;
    }
}