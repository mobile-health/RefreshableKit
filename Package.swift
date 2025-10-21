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
        // No external SwiftPM dependencies. The repo contains fallback
        // implementations so the package can be used without pulling
        // SWActivityIndicatorView via SPM.
    ],
    targets: [
        .target(
            name: "RefreshableKit",
            dependencies: [],
            path: "Classes"
        )
    ]
)
