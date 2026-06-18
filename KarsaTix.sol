// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KarsaTix
 * @dev Ticketing smart contract for KarsaFest that implements anonymous verification using Merkle Trees.
 */
contract KarsaTix {
    bytes32 public merkleRoot;
    address public owner;

    // Events for logging
    event MerkleRootUpdated(bytes32 indexed oldRoot, bytes32 indexed newRoot);
    event TicketVerified(address indexed verifier, bytes32 indexed leaf, bool success);

    // Modifier to restrict access to owner only
    modifier onlyOwner() {
        require(msg.sender == owner, "KarsaTix: Caller is not the owner");
        _;
    }

    /**
     * @dev Set the contract deployer as the owner.
     */
    constructor() {
        owner = msg.sender;
    }

    /**
     * @dev Update the Merkle root of the ticket list. Only owner (panitia) can call this.
     * @param _newRoot The new Merkle root representing the valid tickets.
     */
    function updateMerkleRoot(bytes32 _newRoot) external onlyOwner {
        bytes32 oldRoot = merkleRoot;
        merkleRoot = _newRoot;
        emit MerkleRootUpdated(oldRoot, _newRoot);
    }

    /**
     * @dev Verify if a ticket leaf belongs to the current Merkle root.
     * @param proof Merkle proof elements.
     * @param leaf Keccak-256 hash of the ticket secret.
     * @return bool True if valid, false otherwise.
     */
    function verifyTicket(bytes32[] calldata proof, bytes32 leaf) public view returns (bool) {
        return verify(proof, merkleRoot, leaf);
    }

    /**
     * @dev Internal function to verify a Merkle proof.
     * @param proof Merkle proof elements.
     * @param root The Merkle root to check against.
     * @param leaf The leaf node hash to verify.
     * @return bool True if the proof matches the root, false otherwise.
     */
    function verify(
        bytes32[] memory proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                // Hash computedHash + proofElement
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                // Hash proofElement + computedHash
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == root;
    }
}
