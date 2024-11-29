// swift-tools-version: 6.0
import PackageDescription

let package = Package(
   name: "ErrorKit",
   platforms: [.macOS(.v13), .iOS(.v16), .tvOS(.v16), .watchOS(.v9), .macCatalyst(.v16)],
   products: [.library(name: "ErrorKit", targets: ["ErrorKit"])],
   targets: [
      .target(name: "ErrorKit"),
      .testTarget(name: "ErrorKitTests", dependencies: ["ErrorKit"]),
   ]
)
