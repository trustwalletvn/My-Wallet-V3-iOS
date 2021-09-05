import Foundation

extension Date {
    public var currentYear: Int {
        Calendar.current.component(.year, from: self)
    }
}
