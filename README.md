# 🌟 FoT Apple - Field of Truth VQbit Substrate Platform

**Quantum for All** - A native Apple platform implementing the Field of Truth framework with quantum-inspired optimization, cryptographic validation, and SafeAICoin blockchain integration.

## Overview

FoT Apple is a comprehensive multi-platform application that brings the Field of Truth (FoT) quantum substrate to the entire Apple ecosystem. It combines:

- **8096-dimensional VQbit substrate** for quantum-inspired optimization
- **Audit Knowledge Graph (AKG)** with Cypher query interface
- **Cryptographic validation** using Merkle trees and Ed25519 signatures
- **SafeAICoin blockchain** integration for immutable attestations
- **Domain-specific packs** for Protein, Chemistry, Fluid Dynamics, Legal, Clinical Trials, and Clinician domains

## Quick Start

### Build

```bash
cd /Users/richardgillespie/Documents/FoTApple
swift build
```

### Test

```bash
swift test
```

### Run CLI

```bash
swift run fot --help
```

## Features

### 🧮 VQbit Quantum Substrate

- 8096-dimensional complex amplitude states
- Four cardinal virtue operators (Justice, Temperance, Prudence, Fortitude)
- Entangled multi-vQbit evolution
- Virtue-guided collapse for optimization
- Accelerate framework integration for performance

### 📊 Audit Knowledge Graph (AKG)

- SQLite-based graph database
- Cypher query interface
- Cryptographic hashing (BLAKE3)
- Merkle tree validation
- Ed25519 signatures
- Read receipts with proofs

### 🔐 Cryptographic Validation

- RFC 8785 canonical JSON
- BLAKE3-256 hashing
- Binary Merkle trees
- Ed25519 signing (Secure Enclave on iOS/macOS)
- Immutable attestation records

### ⛓️ SafeAICoin Integration

- RPC client for blockchain communication
- Attestation anchoring
- Proof retrieval
- Transaction confirmation
- Gas estimation

### 🧬 Domain Packs

#### Protein Domain Pack ✅
- Amino acid sequence validation
- Chain length constraints
- UniProt ID format checking
- Molecular mass validation
- GO annotation support
- BiVQbitEGNN integration (ready)

#### Chemistry Domain Pack ⏳
- SMILES validation
- InChIKey generation
- MOF generation
- Reaction pathway optimization

#### Fluid Dynamics Domain Pack ⏳
- FEA/FSI matrix assembly
- Navier-Stokes quantum solver
- Modal analysis
- Echo-steered collapse

#### Legal Domain Pack ⏳
- Constitutional analysis
- Section 3 enforcement
- Oath violation detection
- Stare decisis checker

#### Clinical Trials Domain Pack ⏳
- ISO 14155 conformance
- Visit window checking
- Endpoint validation
- GLP/GMP compliance

#### Clinician Domain Pack ⏳
- Context-aware clinical advisor
- Medical data quality checking
- ICD-10/LOINC validation
- PHI encryption

## CLI Commands

### Initialize Services
```bash
fot init
```

### Run Cypher Query
```bash
fot query "MATCH (n:Protein) RETURN n LIMIT 10"
```

### Execute Validated Write
```bash
fot write '{"mutations": [...]}'
```

### Run VQbit Optimization
```bash
fot optimize
```

### Check System Status
```bash
fot status
```

### Start HTTP Server
```bash
fot serve --port 8888
```

## HTTP API

### Endpoints

- `GET /` - API documentation (HTML)
- `GET /status` - Service status and statistics
- `POST /cypher` - Execute Cypher query with receipt
- `POST /write` - Execute validated write batch
- `GET /proof/{attestation_id}` - Retrieve Merkle proof

### Example: Create Node

```bash
curl -X POST http://localhost:8888/write \
  -H "Content-Type: application/json" \
  -d '{
    "mutations": [
      {
        "type": "createNode",
        "labels": ["Protein"],
        "properties": {
          "sequence": "MVHLTPEEK",
          "uniprot": "P69905",
          "name": "Hemoglobin"
        }
      }
    ]
  }'
```

Response:
```json
{
  "attestation_id": "01JD...",
  "merkle_root": "b3:...",
  "signature": "ed25519:...",
  "timestamp": 1698451200000,
  "records_count": 1
}
```

## Architecture

```
┌─────────────────────────────────────────┐
│          FoT Apple Platform             │
├─────────────────────────────────────────┤
│  Apps: Mac, iOS, Watch, Vision          │
├─────────────────────────────────────────┤
│  SwiftUI Components                     │
├─────────────────────────────────────────┤
│  Domain Packs                           │
│  ├─ Protein                             │
│  ├─ Chemistry                           │
│  ├─ Fluid Dynamics                      │
│  ├─ Legal                               │
│  ├─ Clinical Trials                     │
│  └─ Clinician                           │
├─────────────────────────────────────────┤
│  FoT Core                               │
│  ├─ VQbit Engine (8096 dims)           │
│  ├─ AKG Service (SQLite + Cypher)      │
│  ├─ Validator (Merkle + Ed25519)       │
│  └─ Common (ULID, BLAKE3, JSON)        │
├─────────────────────────────────────────┤
│  SafeAICoin Bridge                      │
│  └─ RPC Client + Attestation           │
└─────────────────────────────────────────┘
```

## Platform Support

- **macOS 14+**: Full features, server mode, Metal acceleration
- **iOS/iPadOS 17+**: Mobile interface, Secure Enclave, iCloud sync
- **watchOS 10+**: Monitoring, reduced dimensions (512)
- **visionOS 1+**: 3D visualization, immersive mode

## Development

### Requirements

- Xcode 15+
- Swift 5.9+
- macOS 14+ (for development)

### Dependencies

- **GRDB.swift**: SQLite database access
- **Swift-NIO**: HTTP server
- **CryptoSwift**: Cryptographic primitives
- **Swift-Algorithms**: Collection algorithms
- **Swift-Numerics**: Numeric types

### Running Tests

```bash
# All tests
swift test

# Specific test suite
swift test --filter FoTCoreTests

# With verbose output
swift test --verbose
```

### Test Coverage

- ✅ AKGServiceTests: 8/8 passing
- ⚠️  CanonicalJSONTests: 6/7 passing
- ⏳ VQbitEngineTests: Needs expansion
- ⏳ ProteinDomainPackTests: Needs expansion

## Contributing

This is a Field of Truth implementation following these principles:

1. **Zero Simulation/Zero Mock**: All implementations are real
2. **No Hardcoded Mainnet Values**: All values are dynamic
3. **100% Deterministic Validation**: Cryptographic proofs for everything
4. **Quantum for All**: Accessible across all Apple platforms

## License

Field of Truth - Quantum for All

## Contact

For questions about the Field of Truth framework or this implementation:
- Project: FoT Apple Native Platform
- Version: 1.0.0-alpha
- Platform: Apple Ecosystem (Watch, Phone, iPad, Vision, Mac)

---

**🌟 Quantum for All - Field of Truth 100%**
