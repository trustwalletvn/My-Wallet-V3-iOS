// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

// TODO: Dimitris - Move this to its proper place
public struct ServerIncidents: Decodable {
    public struct Page: Decodable {
        public let id: String
        public let name: String
        public let url: String

        internal init(id: String, name: String, url: String) {
            self.id = id
            self.name = name
            self.url = url
        }
    }

    public struct Incident: Decodable {
        public let id: String
        public let name: String
        public let status: String
        public let components: [Component]
    }

    public struct Component: Decodable {
        /// we check against this parameter
        fileprivate static let wallet = "Wallet"

        public enum Status: String, Decodable {
            case operational
            case majorOutage = "major_outage"
        }

        public let id: String
        public let name: String
        public let status: Status
    }

    public let page: Page
    public let incidents: [Incident]

    internal init(page: Page, incidents: [Incident]) {
        self.page = page
        self.incidents = incidents
    }

    /// If there is an incident with a component name = Wallet whose component status is NOT Operational,
    public var hasActiveMajorIncident: Bool {
        incidents.flatMap(\.components)
            .filter { $0.name == Component.wallet }
            .filter { $0.status != .operational }
            .count > 0
    }
}

public protocol MaintenanceServicing {
    var serverUnderMaintenanceMessage: Single<String?> { get }

    // TODO: Re-enable this once we have isolated the source of the crash
//    var serverStatus: Single<ServerIncidents> { get }
}

public protocol WalletOptionsAPI: MaintenanceServicing {
    var walletOptions: Single<WalletOptions> { get }
}
