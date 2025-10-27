import Foundation

/// Merkle tree for cryptographic verification of batch operations
/// Binary tree with deterministic ordering
public struct MerkleTree: Sendable {
    /// Root hash of the tree
    public let root: Data
    
    /// Leaf hashes (original records)
    public let leaves: [Data]
    
    /// Internal nodes (computed from leaves)
    private let internalNodes: [[Data]]
    
    /// Metadata about tree construction
    public let metadata: [String: Any]
    
    /// Build Merkle tree from leaf hashes
    public init(leaves: [Data]) {
        self.leaves = leaves
        
        guard !leaves.isEmpty else {
            self.root = Data()
            self.internalNodes = []
            self.metadata = ["empty": true]
            return
        }
        
        // Build tree bottom-up
        var currentLevel = leaves.map { Self.hashLeaf($0) }
        var allLevels: [[Data]] = [currentLevel]
        
        while currentLevel.count > 1 {
            var nextLevel: [Data] = []
            
            for i in stride(from: 0, to: currentLevel.count, by: 2) {
                if i + 1 < currentLevel.count {
                    // Hash pair
                    let combined = Self.hashPair(currentLevel[i], currentLevel[i + 1])
                    nextLevel.append(combined)
                } else {
                    // Odd node: promote to next level (or hash with itself)
                    nextLevel.append(Self.hashPair(currentLevel[i], currentLevel[i]))
                }
            }
            
            allLevels.append(nextLevel)
            currentLevel = nextLevel
        }
        
        self.root = currentLevel[0]
        self.internalNodes = allLevels
        self.metadata = [
            "leaf_count": leaves.count,
            "tree_height": allLevels.count
        ]
    }
    
    /// Hash a leaf node: 0x00 || BLAKE3(data)
    private static func hashLeaf(_ data: Data) -> Data {
        var prefixed = Data([0x00])  // Leaf prefix
        prefixed.append(BLAKE3.hash(data))
        return BLAKE3.hash(prefixed)
    }
    
    /// Hash a pair of nodes: 0x01 || BLAKE3(left || right)
    internal static func hashPair(_ left: Data, _ right: Data) -> Data {
        var prefixed = Data([0x01])  // Internal node prefix
        prefixed.append(left)
        prefixed.append(right)
        return BLAKE3.hash(prefixed)
    }
    
    /// Generate proof for a leaf at given index
    public func generateProof(for index: Int) -> MerkleProof? {
        guard index >= 0 && index < leaves.count else {
            return nil
        }
        
        var proofHashes: [Data] = []
        var proofPositions: [MerkleProof.Position] = []
        var currentIndex = index
        
        // Traverse from leaf to root, collecting sibling hashes
        for level in 0..<(internalNodes.count - 1) {
            let currentLevel = internalNodes[level]
            let isRightNode = currentIndex % 2 == 1
            
            if isRightNode {
                // We're on the right, sibling is on the left
                proofHashes.append(currentLevel[currentIndex - 1])
                proofPositions.append(.left)
            } else {
                // We're on the left, sibling is on the right (or duplicate if odd)
                if currentIndex + 1 < currentLevel.count {
                    proofHashes.append(currentLevel[currentIndex + 1])
                    proofPositions.append(.right)
                } else {
                    // Odd node: no sibling, will be duplicated
                    proofHashes.append(currentLevel[currentIndex])
                    proofPositions.append(.duplicate)
                }
            }
            
            // Move to parent in next level
            currentIndex = currentIndex / 2
        }
        
        return MerkleProof(
            leafHash: Self.hashLeaf(leaves[index]),
            leafIndex: index,
            proofHashes: proofHashes,
            positions: proofPositions,
            root: root
        )
    }
    
    /// Verify a proof against this tree's root
    public func verify(_ proof: MerkleProof) -> Bool {
        return proof.verify(against: root)
    }
}

/// Merkle proof for a single leaf
public struct MerkleProof: Sendable, Codable {
    /// Hash of the leaf being proven
    public let leafHash: Data
    
    /// Index of the leaf in the tree
    public let leafIndex: Int
    
    /// Sibling hashes along the path to root
    public let proofHashes: [Data]
    
    /// Positions of siblings (left, right, or duplicate)
    public let positions: [Position]
    
    /// Expected root hash
    public let root: Data
    
    /// Position of sibling in proof
    public enum Position: String, Codable, Sendable {
        case left
        case right
        case duplicate
    }
    
    /// Verify this proof against a root hash
    public func verify(against expectedRoot: Data) -> Bool {
        var currentHash = leafHash
        
        for (siblingHash, position) in zip(proofHashes, positions) {
            switch position {
            case .left:
                // Sibling is on left: hash(sibling || current)
                currentHash = MerkleTree.hashPair(siblingHash, currentHash)
            case .right:
                // Sibling is on right: hash(current || sibling)
                currentHash = MerkleTree.hashPair(currentHash, siblingHash)
            case .duplicate:
                // No sibling (odd node): hash(current || current)
                currentHash = MerkleTree.hashPair(currentHash, currentHash)
            }
        }
        
        return currentHash == expectedRoot
    }
    
    /// Serialize proof to JSON
    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let dict: [String: Any] = [
            "leaf_hash": leafHash.toHexString(),
            "leaf_index": leafIndex,
            "proof_hashes": proofHashes.map { $0.toHexString() },
            "positions": positions.map { $0.rawValue },
            "root": root.toHexString()
        ]
        
        return try JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted, .sortedKeys])
    }
}

// MARK: - Codable Extensions

extension MerkleProof {
    enum CodingKeys: String, CodingKey {
        case leafHash, leafIndex, proofHashes, positions, root
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode hex strings to Data
        let leafHashHex = try container.decode(String.self, forKey: .leafHash)
        self.leafHash = Data(hexString: leafHashHex) ?? Data()
        
        self.leafIndex = try container.decode(Int.self, forKey: .leafIndex)
        
        let proofHashesHex = try container.decode([String].self, forKey: .proofHashes)
        self.proofHashes = proofHashesHex.compactMap { Data(hexString: $0) }
        
        self.positions = try container.decode([Position].self, forKey: .positions)
        
        let rootHex = try container.decode(String.self, forKey: .root)
        self.root = Data(hexString: rootHex) ?? Data()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(leafHash.toHexString(), forKey: .leafHash)
        try container.encode(leafIndex, forKey: .leafIndex)
        try container.encode(proofHashes.map { $0.toHexString() }, forKey: .proofHashes)
        try container.encode(positions, forKey: .positions)
        try container.encode(root.toHexString(), forKey: .root)
    }
}

