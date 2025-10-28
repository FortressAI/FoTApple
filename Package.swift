// swift-tools-version: 5.9
// Field of Truth - Master Package
// Complete Apple ecosystem for Clinician, Legal US, and Education K-18 domains

import PackageDescription

let package = Package(
    name: "FieldOfTruth",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        // Core Libraries
        .library(name: "FoTCore", targets: ["FoTCore"]),
        .library(name: "FoTUI", targets: ["FoTUI"]),
        .library(name: "AKG", targets: ["AKG"]),
        .library(name: "VQbitSubstrate", targets: ["VQbitSubstrate"]),
        .library(name: "RulesEngine", targets: ["RulesEngine"]),
        .library(name: "EthicsProvenance", targets: ["EthicsProvenance"]),
        .library(name: "PrivacyPHI", targets: ["PrivacyPHI"]),
        .library(name: "DataAdapters", targets: ["DataAdapters"]),
        .library(name: "SearchRetrieval", targets: ["SearchRetrieval"]),
        .library(name: "ReasonGraph", targets: ["ReasonGraph"]),
        
        // Domain Libraries
        .library(name: "FoTClinician", targets: ["FoTClinician"]),
        .library(name: "FoTLegalUS", targets: ["FoTLegalUS"]),
        .library(name: "FoTEducationK18", targets: ["FoTEducationK18"]),
        
        // App Intents (64 voice commands)
        .library(name: "FoTAppIntents", targets: ["FoTAppIntents"]),
        
        // Apps will be built as Xcode projects with full UI
    ],
    dependencies: [
        // No external dependencies - 100% native Apple frameworks
    ],
    targets: [
        // ================================================================
        // CORE PLATFORM TARGETS
        // ================================================================
        
        .target(
            name: "FoTCore",
            dependencies: [],
            path: "packages/FoTCore/Sources",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FoTCoreTests",
            dependencies: ["FoTCore"],
            path: "packages/FoTCore/Tests"
        ),
        
        // FoTUI - Glass morphism UI components
        .target(
            name: "FoTUI",
            dependencies: [],
            path: "Sources/FoTUI"
        ),
        
        // FoTAppIntents - All 64 voice commands for Siri integration
        .target(
            name: "FoTAppIntents",
            dependencies: ["FoTCore"],
            path: "packages/FoTCore/AppIntents",
            swiftSettings: [
                .enableUpcomingFeature("BareSlashRegexLiterals")
            ]
        ),
        
        // AKG - Audit Knowledge Graph with Cypher frontend
        .target(
            name: "AKG",
            dependencies: ["FoTCore"],
            path: "packages/AKG/Sources"
        ),
        .testTarget(
            name: "AKGTests",
            dependencies: ["AKG"],
            path: "packages/AKG/Tests"
        ),
        
        // VQbit Substrate - Quantum-inspired optimization using Metal
        .target(
            name: "VQbitSubstrate",
            dependencies: ["FoTCore"],
            path: "packages/VQbitSubstrate/Sources",
            resources: [.process("Shaders")]
        ),
        .testTarget(
            name: "VQbitSubstrateTests",
            dependencies: ["VQbitSubstrate"],
            path: "packages/VQbitSubstrate/Tests"
        ),
        
        // Rules Engine - Domain-specific rules and compliance
        .target(
            name: "RulesEngine",
            dependencies: ["FoTCore", "AKG"],
            path: "packages/RulesEngine/Sources"
        ),
        .testTarget(
            name: "RulesEngineTests",
            dependencies: ["RulesEngine"],
            path: "packages/RulesEngine/Tests"
        ),
        
        // Ethics Provenance - Cryptographic proof generation
        .target(
            name: "EthicsProvenance",
            dependencies: ["FoTCore", "AKG"],
            path: "packages/EthicsProvenance/Sources"
        ),
        .testTarget(
            name: "EthicsProvenanceTests",
            dependencies: ["EthicsProvenance"],
            path: "packages/EthicsProvenance/Tests"
        ),
        
        // Privacy PHI - HIPAA-compliant encryption
        .target(
            name: "PrivacyPHI",
            dependencies: ["FoTCore"],
            path: "packages/PrivacyPHI/Sources"
        ),
        .testTarget(
            name: "PrivacyPHITests",
            dependencies: ["PrivacyPHI"],
            path: "packages/PrivacyPHI/Tests"
        ),
        
        // Data Adapters - External API integration (RxNav, etc.)
        .target(
            name: "DataAdapters",
            dependencies: ["FoTCore"],
            path: "packages/DataAdapters/Sources"
        ),
        .testTarget(
            name: "DataAdaptersTests",
            dependencies: ["DataAdapters"],
            path: "packages/DataAdapters/Tests"
        ),
        
        // Search Retrieval - Vector search and semantic retrieval
        .target(
            name: "SearchRetrieval",
            dependencies: ["FoTCore", "AKG", "VQbitSubstrate"],
            path: "packages/SearchRetrieval/Sources"
        ),
        .testTarget(
            name: "SearchRetrievalTests",
            dependencies: ["SearchRetrieval"],
            path: "packages/SearchRetrieval/Tests"
        ),
        
        // Reason Graph - Graph-based reasoning and provenance
        .target(
            name: "ReasonGraph",
            dependencies: ["FoTCore", "AKG", "EthicsProvenance"],
            path: "packages/ReasonGraph/Sources"
        ),
        .testTarget(
            name: "ReasonGraphTests",
            dependencies: ["ReasonGraph"],
            path: "packages/ReasonGraph/Tests"
        ),
        
        // ================================================================
        // DOMAIN-SPECIFIC TARGETS
        // ================================================================
        
        // Clinician Domain
        .target(
            name: "FoTClinician",
            dependencies: [
                "FoTCore",
                "AKG",
                "RulesEngine",
                "DataAdapters",
                "PrivacyPHI",
                "EthicsProvenance",
                "ReasonGraph"
            ],
            path: "packages/FoTClinician/Sources",
            resources: [.copy("Persistence/PatientStore.swift.grdb_version")]
        ),
        .testTarget(
            name: "FoTClinicianTests",
            dependencies: ["FoTClinician"],
            path: "packages/FoTClinician/Tests"
        ),
        
        // Legal US Domain
        .target(
            name: "FoTLegalUS",
            dependencies: [
                "FoTCore",
                "AKG",
                "RulesEngine",
                "EthicsProvenance",
                "ReasonGraph"
            ],
            path: "packages/FoTLegalUS/Sources"
        ),
        
        // Education K-18 Domain
        .target(
            name: "FoTEducationK18",
            dependencies: [
                "FoTCore",
                "AKG",
                "RulesEngine",
                "EthicsProvenance",
                "ReasonGraph",
                "VQbitSubstrate"
            ],
            path: "packages/FoTEducationK18/Sources"
        ),
        
        // ================================================================
        // APPLICATION TARGETS
        // ================================================================
        // Apps are built as separate Xcode projects with full SwiftUI UIs
        // They import the domain libraries defined above
    ]
)
