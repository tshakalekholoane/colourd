// swift-tools-version: 5.8
import PackageDescription

let package = Package(
  name: "colourd",
  platforms: [.macOS(.v13)],
  targets: [.executableTarget(name: "colourd", path: "Sources")]
)
