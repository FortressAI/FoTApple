# Getting Started with FoT Apple

## Quick Start Guide

### Prerequisites

- macOS 14+ (Sonoma or later)
- Xcode 15+
- Swift 5.9+

### Build the Project

```bash
cd /Users/richardgillespie/Documents/FoTApple

# Resolve dependencies
swift package resolve

# Build all targets
swift build

# Build for release (optimized)
swift build -c release

# Run tests
swift test
```

### Run the CLI Tool

```bash
# Build and run
swift run fotctl version

# Initialize the system
swift run fotctl init

# Show system status
swift run fotctl status

# Run optimization
swift run fotctl optimize

# Create a node
swift run fotctl create-node Protein '{"sequence":"ACDEFGHIKLMN","uniprot":"P12345"}'
```

## Core Concepts

### 1. VQbit Substrate

The quantum-inspired optimization engine with 8096 dimensions (adaptive by platform):

```swift
import FoTCore

// Create engine
let engine = await VQbitEngine()

// Create quantum state
let state = await engine.createVQbitState()

// Apply virtue-guided collapse
let targetVirtues: [VirtueType: Double] = [
    .justice: 0.8,      // Balanced solutions
    .prudence: 0.7,     // Long-term thinking
    .temperance: 0.6,   // Moderation
    .fortitude: 0.5     // Robustness
]

let collapsed = await engine.applyVirtueCollapse(
    state: state,
    targetVirtues: targetVirtues
)

print("Coherence: \(collapsed.coherence)")
print("Virtue scores: \(collapsed.virtueScores)")
```

### 2. AKG Knowledge Graph

Local SQLite-backed knowledge graph with cryptographic validation:

```swift
import FoTCore

// Initialize AKG
let akg = try await AKGService(databasePath: "./my_knowledge.db")

// Create a node
let nodeId = try await akg.createNode(
    labels: ["Protein"],
    properties: [
        "sequence": "MVHLTPEEKSAVTALWGKVNVDEVGGEALGRLLVVYPWTQRFFESFGDLSTPDAVMGNPKVKAHGKKVLGAFSDGLAHLDNLKGTFATLSELHCDKLHVDPENFRLLGNVLVCVLAHHFGKEFTPPVQAAYQKVVAGVANALAHKYH",
        "uniprot": "P69905",
        "name": "Hemoglobin subunit alpha"
    ]
)

// Create an edge
let edgeId = try await akg.createEdge(
    source: nodeId,
    destination: otherNodeId,
    type: "INTERACTS_WITH",
    properties: ["confidence": 0.95]
)

// Query nodes
let proteins = try await akg.queryNodes(byLabel: "Protein", limit: 100)
```

### 3. Validated Batch Writes

All writes are validated and cryptographically attested:

```swift
let mutations: [Mutation] = [
    .createNode(labels: ["Molecule"], properties: [
        "smiles": "CC(C)CC1=CC=C(C=C1)C(C)C(=O)O",
        "name": "Ibuprofen"
    ]),
    .createNode(labels: ["Target"], properties: [
        "name": "COX-2",
        "uniprot": "P35354"
    ])
]

// This creates a Merkle tree, signs it, and can be anchored to blockchain
let attestation = try await akg.writeBatch(mutations)

print("Attestation ID: \(attestation.id)")
print("Merkle Root: \(attestation.merkleRoot.toHexString())")
print("Signature: \(attestation.signature.toHexString())")
```

### 4. Domain Packs

Register domain-specific validation:

```swift
import FoTProtein

let proteinPack = ProteinDomainPack()
try await proteinPack.initialize(engine: engine, akg: akg)

// Now all Protein nodes are validated automatically
let result = try proteinPack.validate(Record(
    type: .node,
    data: ["sequence": "ACDEFGHIKLMN"],
    labels: ["Protein"]
))

if result.isValid {
    print("✅ Valid protein record")
} else {
    print("❌ Validation errors: \(result.errors)")
}
```

### 5. SafeAICoin Integration

Anchor attestations to blockchain:

```swift
import SafeAICoinBridge

let blockchain = await SafeAICoinClient(
    rpcURL: "https://rpc.safeaicoin.org",
    networkID: "mainnet"
)

// Submit attestation
let txHash = try await blockchain.submitAttestation(attestation)
print("Anchored on-chain: \(txHash)")

// Retrieve proof later
let proof = try await blockchain.retrieveProof(attestationId: attestation.id)
```

## Example Workflows

### Protein Folding Analysis

```swift
import FoTCore
import FoTProtein

// Initialize
let engine = await VQbitEngine()
let akg = try await AKGService(databasePath: "./proteins.db")
let proteinPack = ProteinDomainPack()
try await proteinPack.initialize(engine: engine, akg: akg)

// Load protein sequence
let sequence = "MVHLTPEEKSAVTALWGKVNVDEVGG..."

// Create optimization problem
let problem = OptimizationProblem(
    id: ULID().string,
    name: "Protein Folding",
    description: "Find stable conformations",
    objectives: [
        Objective(name: "minimize_energy", direction: .minimize),
        Objective(name: "maximize_compactness", direction: .maximize)
    ],
    constraints: [
        Constraint(name: "valid_geometry", type: .lessEqual, bound: 1.0)
    ],
    variables: [
        Variable(name: "phi_1", lowerBound: -180, upperBound: 180),
        Variable(name: "psi_1", lowerBound: -180, upperBound: 180)
        // ... more dihedral angles
    ],
    virtueWeights: [
        .justice: 0.3,    // Balanced geometry
        .prudence: 0.4,   // Stable configuration
        .temperance: 0.2, // Compact structure
        .fortitude: 0.1   // Robust to perturbations
    ]
)

// Run optimization
let solutions = try await proteinPack.optimize(problem: problem)

// Store results
for solution in solutions {
    let nodeId = try await akg.createNode(
        labels: ["Conformation"],
        properties: [
            "sequence": sequence,
            "energy": solution.objectives["minimize_energy"]!,
            "compactness": solution.objectives["maximize_compactness"]!,
            "virtue_scores": solution.virtueScores
        ]
    )
    print("Conformation \(nodeId): Energy = \(solution.objectives["minimize_energy"]!)")
}
```

### Chemical Discovery

```swift
import FoTChemistry

let chemPack = ChemistryDomainPack()
try await chemPack.initialize(engine: engine, akg: akg)

// Generate and validate molecules
let smiles = "CC(=O)Oc1ccccc1C(=O)O"  // Aspirin

let record = Record(
    type: .node,
    data: ["smiles": smiles, "name": "Aspirin"],
    labels: ["Molecule"]
)

let validation = try chemPack.validate(record: record)

if validation.isValid {
    let molId = try await akg.createNode(
        labels: ["Molecule"],
        properties: ["smiles": smiles, "name": "Aspirin"]
    )
    print("✅ Molecule stored: \(molId)")
}
```

## Platform-Specific Features

### macOS

- Full 8096-dimensional vQbit operations
- Metal acceleration for large matrices
- Server mode (HTTP/WebSocket)
- File system access for bulk imports

### iOS/iPadOS

- 4096 dimensions (iPhone), 8096 (iPad Pro)
- Secure Enclave for key storage
- Background processing (limited)
- Handoff to Mac for heavy computation

### watchOS

- 512 dimensions (monitoring only)
- Glanceable virtue scores
- Optimization progress notifications
- Sync with iPhone

### visionOS

- Full 8096 dimensions
- 3D knowledge graph visualization
- Spatial gestures
- Immersive molecular structures

## Performance Tips

1. **Use appropriate dimensions**: Don't use 8096 dimensions if 512 will suffice
2. **Batch operations**: Group mutations into single write transactions
3. **Index frequently queried labels**: Add SQLite indexes for common queries
4. **Metal acceleration**: Enable for large-scale optimizations on Mac/iPad/Vision
5. **Background processing**: Use iOS background refresh for long optimizations

## Troubleshooting

### Build Errors

```bash
# Clean build folder
swift package clean

# Reset package state
rm -rf .build
swift package resolve
swift build
```

### Database Issues

```bash
# Reset database
rm fot.db*

# Reinitialize
swift run fotctl init
```

### Performance Issues

- Check dimension setting: `await engine.status()`
- Enable Metal acceleration for large operations
- Use batch writes instead of individual creates
- Monitor coherence (high = good, decaying = needs collapse)

## Next Steps

1. **Explore Examples**: Check `/Examples` directory for complete workflows
2. **Read API Docs**: `swift package generate-documentation`
3. **Build Apps**: See `/Apps` for platform-specific implementations
4. **Contribute**: Domain packs are pluggable - add your own!

## Support

- GitHub: [FoTApple Repository]
- SafeAICoin: https://safeaicoin.org
- Documentation: [Swift-DocC Output]

---

**Quantum for all. Verified forever.**  
**NO SIMULATIONS. NO MOCKS. ZERO TOLERANCE.**

