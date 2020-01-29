// swift-tools-version:5.1
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "ApplicationGroupKit",
    platforms: [
        .macOS(.v10_11),
        .iOS(.v9),
        .tvOS(.v9),
        .watchOS(.v3)
    ],
    products: [
        .library(name: "ApplicationGroupKit", targets: ["ApplicationGroupKit"])
    ],
    dependencies: [
        .package(url: "https://github.com/phimage/Prephirences.git", .upToNextMajor(from: "5.1.0")),
    ],
    targets: [
        .target(name: "ApplicationGroupKit", dependencies: [ "Prephirences"], path: "Sources")
    ]
)
