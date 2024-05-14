// swift-tools-version: 5.10
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "UnsafeSendable",
    platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6), .macCatalyst(.v13)],
    products: [
        .library(name: "UnsafeSendable", targets: ["UnsafeSendable"]),
        .executable(name: "UnsafeSendableClient", targets: ["UnsafeSendableClient"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-syntax.git", from: "509.0.0"),
    ],
    targets: [
        .macro(
            name: "UnsafeSendableMacros",
            dependencies: [
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax")
            ],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),

        // Library that exposes a macro as part of its API, which is used in client programs.
        .target(
            name: "UnsafeSendable", 
            dependencies: ["UnsafeSendableMacros"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
            ]
        ),

        // A client of the library, which is able to use the macro in its own code.
        .executableTarget(name: "UnsafeSendableClient", dependencies: ["UnsafeSendable"]),

        // A test target used to develop the macro implementation.
        .testTarget(
            name: "UnsafeSendableTests",
            dependencies: [
                "UnsafeSendableMacros",
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
            ]
        ),
    ]
)
