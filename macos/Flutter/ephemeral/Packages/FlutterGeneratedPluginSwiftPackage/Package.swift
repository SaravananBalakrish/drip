// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//
// Generated file. Do not edit.
//

import PackageDescription

let package = Package(
    name: "FlutterGeneratedPluginSwiftPackage",
    platforms: [
        .macOS("10.15")
    ],
    products: [
        .library(name: "FlutterGeneratedPluginSwiftPackage", type: .static, targets: ["FlutterGeneratedPluginSwiftPackage"])
    ],
    dependencies: [
        .package(name: "connectivity_plus", path: "../.packages/connectivity_plus-6.1.5"),
        .package(name: "device_info_plus", path: "../.packages/device_info_plus-11.3.0"),
        .package(name: "file_selector_macos", path: "../.packages/file_selector_macos-0.9.5"),
        .package(name: "firebase_app_check", path: "../.packages/firebase_app_check-0.4.1"),
        .package(name: "firebase_auth", path: "../.packages/firebase_auth-6.1.0"),
        .package(name: "firebase_core", path: "../.packages/firebase_core-4.1.1"),
        .package(name: "firebase_messaging", path: "../.packages/firebase_messaging-16.0.2"),
        .package(name: "flutter_blue_plus_darwin", path: "../.packages/flutter_blue_plus_darwin-8.2.1"),
        .package(name: "flutter_local_notifications", path: "../.packages/flutter_local_notifications-19.4.0"),
        .package(name: "geolocator_apple", path: "../.packages/geolocator_apple-2.3.13"),
        .package(name: "package_info_plus", path: "../.packages/package_info_plus-8.3.1"),
        .package(name: "path_provider_foundation", path: "../.packages/path_provider_foundation-2.4.1"),
        .package(name: "shared_preferences_foundation", path: "../.packages/shared_preferences_foundation-2.5.4"),
        .package(name: "url_launcher_macos", path: "../.packages/url_launcher_macos-3.2.2"),
        .package(name: "webview_flutter_wkwebview", path: "../.packages/webview_flutter_wkwebview-3.23.0"),
        .package(name: "FlutterFramework", path: "../.packages/FlutterFramework")
    ],
    targets: [
        .target(
            name: "FlutterGeneratedPluginSwiftPackage",
            dependencies: [
                .product(name: "connectivity-plus", package: "connectivity_plus"),
                .product(name: "device-info-plus", package: "device_info_plus"),
                .product(name: "file-selector-macos", package: "file_selector_macos"),
                .product(name: "firebase-app-check", package: "firebase_app_check"),
                .product(name: "firebase-auth", package: "firebase_auth"),
                .product(name: "firebase-core", package: "firebase_core"),
                .product(name: "firebase-messaging", package: "firebase_messaging"),
                .product(name: "flutter-blue-plus-darwin", package: "flutter_blue_plus_darwin"),
                .product(name: "flutter-local-notifications", package: "flutter_local_notifications"),
                .product(name: "geolocator-apple", package: "geolocator_apple"),
                .product(name: "package-info-plus", package: "package_info_plus"),
                .product(name: "path-provider-foundation", package: "path_provider_foundation"),
                .product(name: "shared-preferences-foundation", package: "shared_preferences_foundation"),
                .product(name: "url-launcher-macos", package: "url_launcher_macos"),
                .product(name: "webview-flutter-wkwebview", package: "webview_flutter_wkwebview"),
                .product(name: "FlutterFramework", package: "FlutterFramework")
            ]
        )
    ]
)
