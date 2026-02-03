// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MetinKisayol",
    platforms: [.macOS(.v13)],
    targets: [
        .executableTarget(
            name: "MetinKisayol",
            path: "Sources"
        )
    ]
)
