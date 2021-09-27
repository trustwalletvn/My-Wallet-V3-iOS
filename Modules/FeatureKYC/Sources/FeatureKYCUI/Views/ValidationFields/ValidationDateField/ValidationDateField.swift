// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

/// `ValidationDateField` is a `ValidationTextField`
/// that presents a `UIDatePicker` instead of a keyboard.
/// It does not support manual date entry.
/// Ideally this would be a `UIPickerView` with its own dataSource
/// but due to time constraints I am using a `UIDatePicker`.
class ValidationDateField: ValidationTextField {

    lazy var pickerView: UIDatePicker = {
        var picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.preferredDatePickerStyle = .wheels
        picker.sizeToFit()
        return picker
    }()

    var selectedDate: Date {
        get {
            pickerView.date
        }
        set {
            pickerView.date = newValue
            datePickerUpdated(pickerView)
        }
    }

    var maximumDate: Date? {
        get {
            pickerView.maximumDate
        }
        set {
            pickerView.maximumDate = newValue
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        textFieldInputView = pickerView
        pickerView.addTarget(self, action: #selector(datePickerUpdated(_:)), for: .valueChanged)
    }

    @objc func datePickerUpdated(_ sender: UIDatePicker) {
        text = DateFormatter.medium.string(from: sender.date)
    }

    override func textFieldDidEndEditing(_ textField: UITextField) {
        super.textFieldDidEndEditing(textField)
        pickerView.isHidden = true
    }

    override func textFieldDidBeginEditing(_ textField: UITextField) {
        super.textFieldDidBeginEditing(textField)
        pickerView.isHidden = false
    }

    override func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        false
    }
}
