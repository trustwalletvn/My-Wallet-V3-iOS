// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift
import ToolKit

open class BaseTableViewController: BaseScreenViewController {

    // MARK: - Public UI Elements

    public let tableView = SelfSizingTableView()
    public let scrollView = UIScrollView()

    // MARK: - Private UI Elements

    private let separatorView = UIView()
    private let outerStackView = UIStackView()
    private let bottomContainerView = UIView()
    private let buttonStackView = UIStackView()

    // MARK: - Public UI Constraints

    public private(set) var contentBottomConstraint: NSLayoutConstraint!

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override open func loadView() {
        // Setup view

        view = UIView()
        view.backgroundColor = .white

        // Add all views
        view.addSubview(scrollView)
        scrollView.addSubview(outerStackView)
        outerStackView.addArrangedSubview(tableView)
        outerStackView.addArrangedSubview(bottomContainerView)
        bottomContainerView.addSubview(separatorView)
        bottomContainerView.addSubview(buttonStackView)

        // Setup Table View
        tableView.isScrollEnabled = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = UITableView.automaticDimension
        tableView.sectionHeaderHeight = 28
        tableView.estimatedSectionHeaderHeight = 0
        tableView.sectionFooterHeight = 28
        tableView.estimatedSectionFooterHeight = 0

        // Setup Scrollview
        scrollView.keyboardDismissMode = .interactive
        scrollView.layout(edges: .leading, .trailing, .top, to: view, usesSafeAreaLayoutGuide: true)
        contentBottomConstraint = scrollView
            .layoutToSuperview(.bottom, usesSafeAreaLayoutGuide: true)

        // Setup OuterStackView
        outerStackView.axis = .vertical
        outerStackView.distribution = .equalSpacing
        outerStackView.spacing = 0
        outerStackView.layoutToSuperview(.trailing, .leading, .top, .bottom, .width)
        outerStackView.layoutToSuperview(.height, relation: .greaterThanOrEqual)

        // Setup BottomContainerView
        bottomContainerView.layout(edges: .leading, .trailing, to: view)
        bottomContainerView.contentCompressionResistancePriority = (.penultimateHigh, .penultimateHigh)
        bottomContainerView.contentHuggingPriority = (.init(rawValue: 251), .init(rawValue: 251))

        // Setup SeparatorView
        separatorView.layout(dimension: .height, to: 1)
        separatorView.layout(edges: .leading, .trailing, .top, to: bottomContainerView)
        separatorView.layout(edge: .bottom, to: .top, of: buttonStackView, offset: -16.0, priority: .defaultHigh)

        // Setup ButtonStackView
        buttonStackView.axis = .vertical
        buttonStackView.distribution = .fill
        buttonStackView.spacing = 8
        buttonStackView.layoutToSuperview(.leading, offset: 24)
        buttonStackView.layoutToSuperview(.trailing, offset: -24)
        buttonStackView.layoutToSuperview(.bottom, offset: -16)
    }

    override open func viewDidLoad() {
        super.viewDidLoad()
    }

    public func addButton(with viewModel: ButtonViewModel) {
        let buttonView = ButtonView()
        buttonView.viewModel = viewModel
        buttonStackView.addArrangedSubview(buttonView)
        buttonView.layout(dimension: .height, to: 48)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.availableHeight = scrollView.frame.height
        tableView.unavailableHeight = bottomContainerView.frame.height
    }
}
