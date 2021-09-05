// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public final class LabeledButtonCollectionView<ViewModel: LabeledButtonViewModelAPI>: UICollectionView {

    // MARK: - Types

    private typealias CellType = LabeledButtonCollectionViewCell<ViewModel>

    /// The flow layout of the collection view
    private class CollectionViewFlowLayout: UICollectionViewFlowLayout {
        override init() {
            super.init()
            estimatedItemSize = CGSize(width: 100, height: 32)
            minimumInteritemSpacing = 0
            minimumLineSpacing = 8
            scrollDirection = .horizontal
            sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        }

        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) { nil }
    }

    // MARK: - Injected

    public let viewModelsRelay = BehaviorRelay<[ViewModel]>(value: [])

    // MARK: - Private Properties

    private let collectionViewFlowLayout: CollectionViewFlowLayout
    private let disposeBag = DisposeBag()

    // MARK: - Lifecycle

    public init() {
        let collectionViewFlowLayout = CollectionViewFlowLayout()
        self.collectionViewFlowLayout = collectionViewFlowLayout
        super.init(frame: UIScreen.main.bounds, collectionViewLayout: collectionViewFlowLayout)
        backgroundColor = .clear
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        contentInsetAdjustmentBehavior = .never
        register(CellType.self)
        viewModelsRelay
            .observeOn(MainScheduler.instance)
            .bind(
                to: rx.items(
                    cellIdentifier: CellType.objectName,
                    cellType: CellType.self
                ),
                curriedArgument: { _, viewModel, cell in
                    cell.viewModel = viewModel
                }
            )
            .disposed(by: disposeBag)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }
}
