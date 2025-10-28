// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FoTClinicianMac",
    platforms: [.macOS(.v14)],
    products: [
        .executable(
            name: "FoTClinicianMac",
            targets: ["FoTClinicianMac"]
        )
    ],
    dependencies: [
        .package(path: "../../../packages/FoTCore"),
        .package(path: "../../../packages/FoTClinician")
    ],
    targets: [
        .executableTarget(
            name: "FoTClinicianMac",
            dependencies: [
                "FoTCore",
                "FoTClinician"
            ],
            path: "FoTClinicianMac"
        )
    ]
)

