import PlatformKit

extension KYCState: PickerViewSelectable {
    var id: String {
        code
    }

    var title: String {
        name
    }
}
