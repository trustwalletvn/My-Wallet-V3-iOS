protocol PickerViewSelectable {
    var id: String { get }
    var title: String { get }
}

extension ValidationPickerField.PickerItem {

    init(_ item: PickerViewSelectable) {
        self.init(id: item.id, title: item.title)
    }
}
