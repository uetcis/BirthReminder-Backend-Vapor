// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "BirthReminderBackend",
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),

        // 🔵 Swift ORM (queries, models, relations, etc) built on MySQL.
        .package(url: "https://github.com/vapor/fluent-mysql.git", from: "3.0.0"),
        
        // Authentication
        .package(url: "https://github.com/vapor/auth.git", from: "2.0.0-rc")
    ],
    targets: [
        .target(name: "App", dependencies: ["FluentMySQL", "Vapor", "Authentication"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
