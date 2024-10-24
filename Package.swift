// swift-tools-version:5.9

/**
*  CRLogging
*  Copyright (c) Isaac Paul 2024
*/

import PackageDescription

let package = Package(
    name: "CRLogging",
    
    platforms: [
        .iOS(.v13),
        .macOS(.v10_13),
        .macCatalyst(.v13),
        .tvOS(.v12),
        .visionOS(.v1),
        .watchOS(.v4)
    ],
    products: [
        .library(
            name: "CRLogging",
            targets: ["CRLogging"]
        )
    ],
    targets: [
        .target(
            name: "CRLogging"
        ),
        .testTarget(
            name: "CRLoggingTests",
            dependencies: ["CRLogging"]
        )
    ]
)
