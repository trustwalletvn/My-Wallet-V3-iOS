// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A Model describing an Asset (crypto or fiat).
public protocol AssetModel {
    var code: String { get }
    var kind: AssetModelType { get }
    var name: String { get }
    var precision: Int { get }
    var products: [AssetModelProduct] { get }
    var logoPngUrl: String? { get }
    var spotColor: String? { get }
}

extension AssetModel {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(code)
        hasher.combine(kind)
    }

    public static func == (lhs: AssetModel, rhs: AssetModel) -> Bool {
        lhs.code == rhs.code && lhs.kind == rhs.kind
    }
}
