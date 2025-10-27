// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FoTApple",
    platforms: [
        .macOS(.v14),
        .iOS(.v17),
        .watchOS(.v10),
        .visionOS(.v1)
    ],
    products: [
        // Core library with VQbit substrate and AKG service
        .library(
            name: "FoTCore",
            targets: ["FoTCore"]
        ),
        // Domain-specific packs
        .library(
            name: "FoTDomainPacks",
            targets: [
                "FoTProtein",
                "FoTChemistry", 
                "FoTFluidDynamics",
                "FoTLegalUS",
                "FoTClinicalTrials",
                "FoTClinician"
            ]
        ),
        // SafeAICoin blockchain integration
        .library(
            name: "SafeAICoinBridge",
            targets: ["SafeAICoinBridge"]
        ),
        // SwiftUI components
        .library(
            name: "FoTUI",
            targets: ["FoTUI"]
        ),
        // Command-line tool
        .executable(
            name: "fotctl",
            targets: ["FoTCLI"]
        )
    ],
    dependencies: [
        // SQLite database
        .package(url: "https://github.com/groue/GRDB.swift", from: "6.26.0"),
        // HTTP server
        .package(url: "https://github.com/apple/swift-nio", from: "2.60.0"),
        // Algorithms
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.2.0"),
        // Numerics
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
        // Crypto utilities
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.8.0")
    ],
    targets: [
        // MARK: - Core Targets
        .target(
            name: "FoTCore",
            dependencies: [
                .product(name: "GRDB", package: "GRDB.swift"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOWebSocket", package: "swift-nio"),
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Numerics", package: "swift-numerics"),
                .product(name: "CryptoSwift", package: "CryptoSwift")
            ],
            resources: [.process("AKG/Storage/Schema.sql")]
        ),
        
        // MARK: - Domain Pack Targets
        .target(
            name: "FoTProtein",
            dependencies: ["FoTCore"],
            path: "Sources/DomainPacks/FoTProtein"
        ),
        .target(
            name: "FoTChemistry",
            dependencies: ["FoTCore"],
            path: "Sources/DomainPacks/FoTChemistry"
        ),
        .target(
            name: "FoTFluidDynamics",
            dependencies: ["FoTCore"],
            path: "Sources/DomainPacks/FoTFluidDynamics"
        ),
        .target(
            name: "FoTLegalUS",
            dependencies: ["FoTCore"],
            path: "Sources/DomainPacks/FoTLegalUS"
        ),
        .target(
            name: "FoTClinicalTrials",
            dependencies: ["FoTCore"],
            path: "Sources/DomainPacks/FoTClinicalTrials"
        ),
        .target(
            name: "FoTClinician",
            dependencies: ["FoTCore"],
            path: "Sources/DomainPacks/FoTClinician"
        ),
        
        // MARK: - SafeAICoin Bridge
        .target(
            name: "SafeAICoinBridge",
            dependencies: [
                "FoTCore",
                .product(name: "NIO", package: "swift-nio")
            ]
        ),
        
        // MARK: - UI Components
        .target(
            name: "FoTUI",
            dependencies: ["FoTCore"]
        ),
        
        // MARK: - CLI Tool
        .executableTarget(
            name: "FoTCLI",
            dependencies: [
                "FoTCore",
                "FoTProtein",
                "FoTChemistry",
                "FoTFluidDynamics",
                "FoTLegalUS",
                "FoTClinicalTrials",
                "FoTClinician",
                "SafeAICoinBridge"
            ]
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "FoTCoreTests",
            dependencies: ["FoTCore"]
        ),
        .testTarget(
            name: "FoTDomainPacksTests",
            dependencies: [
                "FoTProtein",
                "FoTChemistry",
                "FoTFluidDynamics",
                "FoTLegalUS",
                "FoTClinicalTrials",
                "FoTClinician"
            ]
        ),
        .testTarget(
            name: "SafeAICoinBridgeTests",
            dependencies: ["SafeAICoinBridge"]
        )
    ]
)

