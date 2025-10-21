// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "RefreshableKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "RefreshableKit",
            targets: ["RefreshableKit"]
        )
    ],
    dependencies: [
        // Use mobile-health fork that supports SPM
    .package(url: "https://github.com/mobile-health/SWActivityIndicatorView.git", branch: "master")
    ],
    targets: [
        .target(
            name: "RefreshableKit",
            dependencies: [
                .product(name: "SWActivityIndicatorView", package: "SWActivityIndicatorView")
            ],
            path: "Classes"
        )
    ]
)
