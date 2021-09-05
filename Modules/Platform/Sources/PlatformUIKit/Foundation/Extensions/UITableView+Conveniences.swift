// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import UIKit

extension UITableView {

    // MARK: - Mutating accessors

    public func insertFirst(with animation: RowAnimation = .automatic) {
        insertRows(at: [.firstRowInFirstSection], with: animation)
    }

    public func deleteFirst(with animation: RowAnimation = .automatic) {
        deleteRows(at: [.firstRowInFirstSection], with: animation)
    }

    // MARK: - Register header / footer

    public func register<HeaderType: UITableViewHeaderFooterView>(_ headerType: HeaderType.Type) {
        register(headerType, forHeaderFooterViewReuseIdentifier: headerType.objectName)
    }

    // MARK: - Register cell type

    public func register<CellType: UITableViewCell>(_ cellType: CellType.Type) {
        register(cellType, forCellReuseIdentifier: cellType.objectName)
    }

    public func register<CellType: UITableViewCell>(_ cellTypes: [CellType.Type]) {
        for type in cellTypes {
            register(type, forCellReuseIdentifier: type.objectName)
        }
    }

    // MARK: - Register cell name

    public func registerHeaderView(_ name: String, bundle: Bundle = .main) {
        register(UINib(nibName: name, bundle: bundle), forHeaderFooterViewReuseIdentifier: name)
    }

    public func registerNibCell(_ type: UITableViewCell.Type, in bundle: Bundle) {
        let name = type.objectName
        register(UINib(nibName: name, bundle: bundle), forCellReuseIdentifier: name)
    }

    public func registerNibCells(_ types: UITableViewCell.Type..., in bundle: Bundle) {
        for type in types {
            registerNibCell(type, in: bundle)
        }
    }

    // MARK: - Dequeue accessors

    public func dequeue<CellType: UITableViewCell>(_ type: CellType.Type, for indexPath: IndexPath) -> CellType {
        dequeueReusableCell(withIdentifier: type.objectName, for: indexPath) as! CellType
    }

    public func dequeue<HeaderType: UITableViewHeaderFooterView>(_ type: HeaderType.Type) -> HeaderType {
        dequeueReusableHeaderFooterView(withIdentifier: type.objectName) as! HeaderType
    }
}
