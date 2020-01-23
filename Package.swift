// swift-tools-version:5.0
//
//  Package.swift

import PackageDescription

let package = Package(name: "ATGMediaBrowser",
                      platforms: [.iOS(.v10)],
                      products: [.library(name: "ATGMediaBrowser",
                                          targets: ["ATGMediaBrowser"])],
                      targets: [.target(name: "ATGMediaBrowser")],
                      swiftLanguageVersions: [.v5])
