// Copyright © Blockchain Luxembourg S.A. All rights reserved.

final class CardExpirationDateFormatter: TextFormatting {

    func format(_ string: String, operation: TextInputOperation) -> TextFormattingSource {

        var text = ""
        let (monthString, yearString) = prepareComponents(string)
        processMonth(from: string, operation: operation, month: monthString, year: yearString, output: &text)
        processYear(from: string, year: yearString, output: &text)
        return text == string ? .original(text: text) : .formatted(to: text)
    }

    private func processYear(
        from string: String,
        year: String,
        output: inout String
    ) {
        guard let yearInteger = Int(year) else { return }
        switch yearInteger {
        case 0, 1:
            output += "2"
        case 2...9:
            output += "\(year)"
        case 20...99:
            output += String(format: "%02d", yearInteger)
        default:
            break
        }
    }

    private func processMonth(
        from string: String,
        operation: TextInputOperation,
        month: String,
        year: String,
        output: inout String
    ) {
        guard let monthInteger = Int(month) else { return }

        if string.count == 2, operation == .deletion {
            output = String(string.prefix(1))
        } else {
            switch monthInteger {
            case 0 where year.isEmpty:
                output += "0"
            case 1 where month.count == 1:
                if operation == .addition {
                    output += "\(monthInteger)"
                }
            case 1...9:
                if month.count == 1 {
                    output += String(format: "%02d/", monthInteger)
                } else if !year.isEmpty { // The year is filled
                    output += String(format: "%02d/", monthInteger)
                } else { // Year has not been filled yet
                    if month.count >= 2, month.first == "0" {
                        output += String(format: "%02d/", monthInteger)
                    } else {
                        output += "\(monthInteger)"
                    }
                }
            case 10...12:
                output += String(format: "%02d/", monthInteger)
            default:
                break
            }
        }
    }

    private func prepareComponents(_ string: String) -> (monthString: String, yearString: String) {
        let components = string.split(separator: "/")
        let rawComponents: [String]
        if components.isEmpty {
            if string.contains("/") {
                rawComponents = ["", ""]
            } else {
                let month = String(string.prefix(2))
                let year = String(string.dropFirst(2).prefix(2))
                rawComponents = [month, year]
            }
        } else if components.count == 1 {
            rawComponents = [String(components[0]), ""]
        } else {
            var yearComponent = String(components[1])
            if yearComponent.count > 2 {
                yearComponent = String(yearComponent.prefix(1)) + String(yearComponent.suffix(1))
            }
            rawComponents = [String(components[0]), yearComponent]
        }

        let monthString = String(rawComponents[0])
        let yearString = String(rawComponents[1])

        return (monthString, yearString)
    }
}
