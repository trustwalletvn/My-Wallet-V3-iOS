// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Accessibility.Identifier {
    public enum Activity {
        static let prefix = "Activity."

        public enum WalletPickerView {}
        public enum WalletBalance {}
        public enum ActivityCell {}
        public enum WalletSelectorView {}
        public enum EmptyState {}
        public enum Details {}
    }
}

extension Accessibility.Identifier.Activity.WalletPickerView {
    private static let prefix = "\(Accessibility.Identifier.Activity.prefix)WalletPickerView."
    public enum WalletCellItem {
        private static let prefix = "\(Accessibility.Identifier.Activity.WalletPickerView.prefix)WalletPickerCellItem."
        public static let cryptoValuePrefix = "\(prefix)cryptoValue."
        public static let fiatValuePrefix = "\(prefix)fiatValue."
        public static let titleValue = "\(prefix)titleValue"
        public static let descriptionValue = "\(prefix)descriptionValue"
    }
}

extension Accessibility.Identifier.Activity.WalletBalance {
    private static let prefix = "\(Accessibility.Identifier.Activity.prefix)WalletBalance."
    public static let cell = "\(prefix)cell"
    public static let view = "\(prefix)view"
    public static let title = "\(prefix)title"
    public static let description = "\(prefix)description"
    public static let badgeView = "\(prefix)badgeView"
    public static let fiatBalance = "\(prefix)fiatBalanceLabel"
    public static let currencyCode = "\(prefix)currencyCodeLabel"
}

extension Accessibility.Identifier.Activity.ActivityCell {
    private static let prefix = "\(Accessibility.Identifier.Activity.prefix)ActivityCell."
    public static let view = "\(prefix)view"
    public static let badge = "\(prefix)badge"
    public static let titleLabel = "\(prefix)titleLabel"
    public static let descriptionLabel = "\(prefix)descriptionLabel"
    public static let cryptoValuePrefix = "\(prefix)cryptoValue."
    public static let fiatValuePrefix = "\(prefix)fiatValue."
}

extension Accessibility.Identifier.Activity.WalletSelectorView {
    private static let prefix = "\(Accessibility.Identifier.Activity.prefix)WalletSelectorView."
    public static let button = "\(prefix)button"
    public static let titleLabel = "\(prefix)titleLabel"
    public static let subtitleLabel = "\(prefix)subtitleLabel"
}

extension Accessibility.Identifier.Activity.EmptyState {
    private static let prefix = "\(Accessibility.Identifier.Activity.prefix)EmptyState."
    public static let titleLabel = "\(prefix)titleLabel"
    public static let descriptionLabel = "\(prefix)descriptionLabel"
    public static let imageView = "\(prefix)imageView"
}

extension Accessibility.Identifier.Activity.Details {
    private static let prefix = "\(Accessibility.Identifier.Activity.prefix)Details."
    public static let lineItemPrefix = prefix
    public static let cryptoAmountPrefix = prefix + Accessibility.Identifier.LineItem.Transactional.cryptoAmount
}
