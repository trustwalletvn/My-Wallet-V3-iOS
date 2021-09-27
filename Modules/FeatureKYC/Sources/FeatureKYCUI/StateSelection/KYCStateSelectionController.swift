// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import ToolKit
import UIKit

class KYCStateSelectionController: KYCBaseViewController, ProgressableView {

    // MARK: - ProgressableView

    @IBOutlet var progressView: UIProgressView!
    var barColor: UIColor = .green
    var startingValue: Float = 0.45

    // MARK: - IBOutlets

    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var tableView: UITableView!

    // MARK: - Public Properties

    var country: CountryData?

    // MARK: - Private Properties

    private let statesMap = SearchableMap<KYCState>()

    private lazy var presenter: KYCStateSelectionPresenter = {
        let presenter = KYCStateSelectionPresenter(view: self)
        return presenter
    }()

    // MARK: - Factory

    override class func make(with coordinator: KYCRouter) -> KYCStateSelectionController {
        let controller = makeFromStoryboard(in: .module)
        controller.router = coordinator
        controller.pageType = .states
        return controller
    }

    // MARK: - View Controller Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupProgressView()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.searchTextField.accessibilityIdentifier = "kyc.states.search_bar"

        guard let country = country else {
            Logger.shared.error("Country not set.")
            return
        }
        presenter.fetchStates(for: country)
    }
}

// MARK: - KYCStateSelectionView

extension KYCStateSelectionController: KYCStateSelectionView {
    func continueKycFlow(state: KYCState) {
        router.handle(event: .nextPageFromPageType(pageType, .stateSelected(state, statesMap.allItems ?? [])))
    }

    func showExchangeNotAvailable(state: KYCState) {
        router.handle(event: .failurePageForPageType(pageType, .stateNotSupported(state)))
    }

    func display(states: [KYCState]) {
        statesMap.setAllItems(states)
        tableView.reloadData()
    }
}

// MARK: - UISearchBarDelegate

extension KYCStateSelectionController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        statesMap.searchText = searchText
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension KYCStateSelectionController: UITableViewDataSource, UITableViewDelegate {

    // MARK: UITableViewDataSource

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let firstLetter = statesMap.firstLetters[section]
        return statesMap.items(firstLetter: firstLetter)?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stateCell = tableView.dequeueReusableCell(withIdentifier: "StateCell") else {
            return UITableViewCell()
        }

        guard let state = statesMap.item(at: indexPath) else {
            return UITableViewCell()
        }

        stateCell.textLabel?.text = state.name
        stateCell.accessibilityIdentifier = "kyc.state.\(state.name.snakeCased)"

        return stateCell
    }

    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        index
    }

    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        guard statesMap.searchText?.isEmpty ?? true else {
            return nil
        }
        return statesMap.firstLetters
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        statesMap.keys.count
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        searchBar.resignFirstResponder()
    }

    // MARK: - UITableViewDelegate

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedState = statesMap.item(at: indexPath) else {
            Logger.shared.warning("Could not infer selected state.")
            return
        }
        Logger.shared.info("User selected '\(selectedState.name)'")
        presenter.selected(state: selectedState)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
