// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CZip.swift",
    products: [
        .library(name: "CZip", targets: ["CZip", "zip"]),
    .executable(name: "zip_tester", targets: ["zip_tester", "CZip"]),
    ],
    targets: [
        .executableTarget(name: "zip_tester", dependencies: ["CZip", "zip"]),
        .target(name: "CZip", dependencies: ["zip"]),
        .target(name: "zip", dependencies: [],
          path: "Sources/zip",
          exclude: ["test", "fuzz"],
          publicHeadersPath: "src"),
        .testTarget(
            name: "CZipTests",
            dependencies: ["CZip"]
        ),
    ]
)
