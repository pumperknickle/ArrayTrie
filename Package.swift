// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ArrayTrie",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ArrayTrie",
            targets: ["ArrayTrie"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pumperknickle/TrieDictionary.git", from: "0.0.5"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ArrayTrie",
            dependencies: [
                .product(name: "TrieDictionary", package: "TrieDictionary"),]),
        .testTarget(
            name: "ArrayTrieTests",
            dependencies: ["ArrayTrie"]
        ),
    ]
)
