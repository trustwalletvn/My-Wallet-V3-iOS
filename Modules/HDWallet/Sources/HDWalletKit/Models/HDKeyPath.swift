// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

enum DerivationComponent: Equatable {
    case normal(UInt32)
    case hardened(UInt32)

    var isHardened: Bool {
        switch self {
        case .normal:
            return false
        case .hardened:
            return true
        }
    }

//    var libWallyComponent: BIP32Derivation {
//        switch self {
//        case .normal(let value):
//            return .normal(value)
//        case .hardened(let value):
//            return .hardened(value)
//        }
//    }
}

extension Array where Element == DerivationComponent {

    func with(normal index: UInt32) -> Self {
        self + [.normal(index)]
    }

    func with(hardened index: UInt32) -> Self {
        self + [.hardened(index)]
    }
}

// extension BIP32Derivation {
//    var component: DerivationComponent {
//        switch self {
//        case .normal(let value):
//            return .normal(value)
//        case .hardened(let value):
//            return .hardened(value)
//        }
//    }
// }

// extension BIP32Path {
//    var derivationComponents: [DerivationComponent] {
//        components.map { $0.component }
//    }
// }

struct HDKeyPath: LosslessStringConvertible {

    var description: String {
        unimplemented()
    }

    let components: [DerivationComponent]

    init(_ component: DerivationComponent, relative: Bool = true) throws {
        try self.init([component], relative: relative)
    }

    init(_ index: Int, relative: Bool = true) throws {
        try self.init([.normal(UInt32(index))], relative: relative)
    }

    init(_ components: [DerivationComponent], relative: Bool = true) throws {
        unimplemented()
        // let libWallyComponents = components.map { $0.libWallyComponent }
        // let libWallyPath: BIP32Path
        // do {
        //     libWallyPath = try BIP32Path(libWallyComponents, relative: relative)
        // } catch {
        //     throw HDWalletKitError.libWallyError(error)
        // }
        // self.libWallyPath = libWallyPath
        // self.components = libWallyPath.derivationComponents
    }

    init?(_ description: String) {
        unimplemented()
        // guard let libWallyPath = BIP32Path(description) else { return nil }
        // self.components = libWallyPath.derivationComponents
        // self.libWallyPath = libWallyPath
    }
}

extension HDKeyPath {

    static func from(components: [DerivationComponent], relative: Bool = true) -> Result<HDKeyPath, HDWalletKitError> {
        Result { try HDKeyPath(components, relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }

    static func from(component: DerivationComponent, relative: Bool = true) -> Result<HDKeyPath, HDWalletKitError> {
        Result { try HDKeyPath(component, relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }

    static func from(index: Int, relative: Bool = true) -> Result<HDKeyPath, HDWalletKitError> {
        Result { try HDKeyPath(index, relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }
}

extension HDKeyPath {

    func with(normal index: UInt32, relative: Bool = true) -> Result<Self, HDWalletKitError> {
        Result { try HDKeyPath(components + [.normal(index)], relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }

    func with(hardened index: UInt32, relative: Bool = true) -> Result<Self, HDWalletKitError> {
        Result { try HDKeyPath(components + [.hardened(index)], relative: relative) }
            .mapError { $0 as! HDWalletKitError }
    }
}

extension Result where Success == HDKeyPath, Failure == HDWalletKitError {

    func with(normal index: UInt32, relative: Bool = true) -> Result<Success, Failure> {
        flatMap { path -> Result<Success, Failure> in
            path.with(normal: index, relative: relative)
        }
    }

    func with(hardened index: UInt32, relative: Bool = true) -> Result<Success, Failure> {
        flatMap { path -> Result<Success, Failure> in
            path.with(hardened: index, relative: relative)
        }
    }
}
