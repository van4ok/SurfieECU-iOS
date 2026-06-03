// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SurfieECU",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .executable(name: "SurfieECU", targets: ["SurfieECUApp"])
    ],
    targets: [
        .executableTarget(
            name: "SurfieECUApp",
            path: "App",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
