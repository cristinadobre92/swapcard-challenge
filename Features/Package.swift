// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Features",
    platforms: [.iOS(.v18)],
    products: [
        .singleTargetLibrary("BookmarkFeature"),
        .singleTargetLibrary("UsersListFeature"),
        .singleTargetLibrary("UserDetailFeature")
    ],
    dependencies: [
        .package(path: "../Kits")
    ],
    targets: [
        .projectTarget(
            name: "BookmarkFeature",
            dependencies: [
                .kit("APIServiceKit"),
                .kit("SharedModelsKit")
            ]
        ),
        .projectTarget(
            name: "UsersListFeature",
            dependencies: [
                .kit("APIServiceKit"),
                .kit("SharedModelsKit")
            ]
        ),
        .projectTarget(
            name: "UserDetailFeature",
            dependencies: [
                .kit("APIServiceKit"),
                .kit("SharedModelsKit")
            ]
        )
    ]
)


// MARK: - Helpers

extension Product {
    static func singleTargetLibrary(_ name: String) -> Product {
        .library(name: name, targets: [name])
    }
}

extension Target {
    static func projectTarget(
        name: String,
        dependencies: [Target.Dependency] = []
    ) -> Target {
        return Target.target(
            name: name,
            dependencies: dependencies,
            path: "\(name)/Sources"
        )
    }
}

extension Target.Dependency {
    static func kit(_ name: String) -> Target.Dependency {
        .product(name: name, package: "Kits")
    }
}

