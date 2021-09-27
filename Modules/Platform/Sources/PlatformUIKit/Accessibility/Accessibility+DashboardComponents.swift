// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Accessibility.Identifier {

    public enum CurrentBalanceCell {
        public static let prefix = "CurrentBalance."
        public static let view = "\(prefix)view"
        public static let title = "\(prefix)title"
        public static let description = "\(prefix)description"
        public static let pending = "\(prefix)pending"
    }

    public enum Dashboard {
        private static let prefix = "Dashboard."
        public enum FiatCustodialCell {
            public static let prefix = "\(Dashboard.prefix)FiatCustodialCell."
            public static let currencyName = "\(prefix)currencyName"
            public static let currencyCode = "\(prefix)currencyCode"
            public static let currencyBadgeView = "\(prefix)currencyBadgeView"
            public static let baseFiatBalance = "\(prefix)baseFiatBalance"
            public static let quoteFiatBalance = "\(prefix)quoteFiatBalance"
        }

        public enum Notice {
            private static let prefix = "\(Dashboard.prefix)Notice."
            public static let label = "\(prefix)label"
            public static let imageView = "\(prefix)imageView"
        }

        public enum TotalBalanceCell {
            private static let prefix = "\(Dashboard.prefix)TotalBalanceCell."
            public static let titleLabel = "\(prefix)titleLabel"
            public static let valueLabelSuffix = "\(prefix)total"
            public static let pieChartView = "\(prefix)pieChartView"
        }

        public enum AssetCell {
            private static let prefix = "\(Dashboard.prefix)AssetCell."
            public static let titleLabelFormat = "\(prefix)titleLabel."
            public static let assetImageView = "\(prefix)assetImageView."
            public static let fiatPriceLabelFormat = "\(prefix)fiatPriceLabelFormat."
            public static let changeLabelFormat = "\(prefix)changeLabelFormat."
            public static let fiatBalanceLabelFormat = "\(prefix)fiatBalanceLabel."
            public static let marketFiatBalanceLabelFormat = "\(prefix)marketFiatBalanceLabel."
            public static let cryptoBalanceLabelFormat = "\(prefix)cryptoBalanceLabel."
        }

        enum Announcement {
            private static let prefix = "\(Dashboard.prefix)Announcement."

            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let imageView = "\(prefix)thumbImageView"
            static let dismissButton = "\(prefix)dismissButton"
            static let confirmButton = "\(prefix)confirmButton"
            static let backgroundButton = "\(prefix)backgroundButton"
        }
    }

    public enum WalletActionSheet {
        public static let prefix = "WalletActionSheet."
        public enum NonCustodial {
            public static let prefix = "\(WalletActionSheet.prefix)NonCustodial"
            public static let cryptoValue = "\(prefix)cryptoValue"
            public static let fiatValue = "\(prefix)fiatValue"
        }

        public enum CustodialAction {
            private static let prefix = "CustodialAction."
            public static let cryptoValue = "\(prefix)AssetBalanceView.cryptoBalanceValue"
            public static let fiatValue = "\(prefix)AssetBalanceView.fiatBalanceValue"
        }

        public enum Action {
            public static let deposit = "\(WalletActionSheet.prefix)Deposit"
            public static let withdraw = "\(WalletActionSheet.prefix)Withdraw"
            public static let transfer = "\(WalletActionSheet.prefix)Transfer"
            public static let interest = "\(WalletActionSheet.prefix)Interest"
            public static let activity = "\(WalletActionSheet.prefix)Activity"
            public static let send = "\(WalletActionSheet.prefix)Send"
            public static let receive = "\(WalletActionSheet.prefix)Receive"
            public static let swap = "\(WalletActionSheet.prefix)Swap"
            public static let buy = "\(WalletActionSheet.prefix)Buy"
            public static let sell = "\(WalletActionSheet.prefix)Sell"
            public static let title = "\(WalletActionSheet.prefix)Title"
            public static let description = "\(WalletActionSheet.prefix)Description"
        }
    }

    public enum AssetDetails {
        private static let prefix = "DashboardDetails."
        public enum CurrentBalanceCell {
            public static let prefix = "\(AssetDetails.prefix)CurrentBalance."
            public static let titleValue = "\(prefix)titleValue"
            public static let descriptionValue = "\(prefix)descriptionValue"
            public static let pendingValue = "\(prefix)pending"
            public static let cryptoValue = "\(prefix)cryptoValue"
            public static let fiatValue = "\(prefix)fiatValue"
        }
    }
}
