// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "PrefabKit",
    platforms: [
      .iOS(.v16),
    ],
    products: [
        .library(name: "PrefabApp", targets: ["PrefabApp"]),
        .library(name: "PrefabAppAccessControl", targets: ["PrefabAppAccessControl"]),
        .library(name: "PrefabAppCore", targets: ["PrefabAppCore"]),
        .library(name: "PrefabAppCoreInterface", targets: ["PrefabAppCoreInterface"]),
        .library(name: "PrefabAppUI", targets: ["PrefabAppUI"]),
        .library(name: "PrefabAppUtilities", targets: ["PrefabAppUtilities"]),
    ],
    targets: [
        .target(
            name: "PrefabApp",
            dependencies: [
                "PrefabAppAccessControl",
                "PrefabAppCoreInterface",
                "PrefabAppUI",
            ]
        ),
        .target(
            name: "PrefabAppAccessControl",
            dependencies: [
                "PrefabAppCoreInterface",
                "PrefabAppUI",
            ]
        ),
        .target(name: "PrefabAppCore", dependencies: ["PrefabAppCoreInterface"]),
        .target(name: "PrefabAppCoreInterface", dependencies: ["PrefabAppUtilities"]),
        .target(
            name: "PrefabAppUI",
            dependencies: [
                "PrefabAppCoreInterface",
                "PrefabAppUtilities",
            ],
            resources: [
                .process("Design/Resources"),
            ]
        ),
        .target(name: "PrefabAppUtilities"),
        .testTarget(name: "PrefabAppCoreTests", dependencies: ["PrefabAppCore"]),
    ]
)
