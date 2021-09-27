// We shouldn't need this but we let the user search an address and don't reload states within that VC...
enum UnitedStates {
    struct State {
        let abbreviation: String
        let name: String

        var isoCode: String {
            "US-\(abbreviation)"
        }
    }

    static let states: [UnitedStates.State] = [
        UnitedStates.State(abbreviation: "AK", name: "Alaska"),
        UnitedStates.State(abbreviation: "AL", name: "Alabama"),
        UnitedStates.State(abbreviation: "AR", name: "Arkansas"),
        UnitedStates.State(abbreviation: "AS", name: "American Samoa"),
        UnitedStates.State(abbreviation: "AZ", name: "Arizona"),
        UnitedStates.State(abbreviation: "CA", name: "California"),
        UnitedStates.State(abbreviation: "CO", name: "Colorado"),
        UnitedStates.State(abbreviation: "CT", name: "Connecticut"),
        UnitedStates.State(abbreviation: "DC", name: "District of Columbia"),
        UnitedStates.State(abbreviation: "DE", name: "Delaware"),
        UnitedStates.State(abbreviation: "FL", name: "Florida"),
        UnitedStates.State(abbreviation: "GA", name: "Georgia"),
        UnitedStates.State(abbreviation: "GU", name: "Guam"),
        UnitedStates.State(abbreviation: "HI", name: "Hawaii"),
        UnitedStates.State(abbreviation: "IA", name: "Iowa"),
        UnitedStates.State(abbreviation: "ID", name: "Idaho"),
        UnitedStates.State(abbreviation: "IL", name: "Illinois"),
        UnitedStates.State(abbreviation: "IN", name: "Indiana"),
        UnitedStates.State(abbreviation: "KS", name: "Kansas"),
        UnitedStates.State(abbreviation: "KY", name: "Kentucky"),
        UnitedStates.State(abbreviation: "LA", name: "Louisiana"),
        UnitedStates.State(abbreviation: "MA", name: "Massachusetts"),
        UnitedStates.State(abbreviation: "MD", name: "Maryland"),
        UnitedStates.State(abbreviation: "ME", name: "Maine"),
        UnitedStates.State(abbreviation: "MI", name: "Michigan"),
        UnitedStates.State(abbreviation: "MN", name: "Minnesota"),
        UnitedStates.State(abbreviation: "MO", name: "Missouri"),
        UnitedStates.State(abbreviation: "MS", name: "Mississippi"),
        UnitedStates.State(abbreviation: "MT", name: "Montana"),
        UnitedStates.State(abbreviation: "NC", name: "North Carolina"),
        UnitedStates.State(abbreviation: "ND", name: "North Dakota"),
        UnitedStates.State(abbreviation: "NE", name: "Nebraska"),
        UnitedStates.State(abbreviation: "NH", name: "New Hampshire"),
        UnitedStates.State(abbreviation: "NJ", name: "New Jersey"),
        UnitedStates.State(abbreviation: "NM", name: "New Mexico"),
        UnitedStates.State(abbreviation: "NV", name: "Nevada"),
        UnitedStates.State(abbreviation: "NY", name: "New York"),
        UnitedStates.State(abbreviation: "OH", name: "Ohio"),
        UnitedStates.State(abbreviation: "OK", name: "Oklahoma"),
        UnitedStates.State(abbreviation: "OR", name: "Oregon"),
        UnitedStates.State(abbreviation: "PA", name: "Pennsylvania"),
        UnitedStates.State(abbreviation: "PR", name: "Puerto Rico"),
        UnitedStates.State(abbreviation: "RI", name: "Rhode Island"),
        UnitedStates.State(abbreviation: "SC", name: "South Carolina"),
        UnitedStates.State(abbreviation: "SD", name: "South Dakota"),
        UnitedStates.State(abbreviation: "TN", name: "Tennessee"),
        UnitedStates.State(abbreviation: "TX", name: "Texas"),
        UnitedStates.State(abbreviation: "UT", name: "Utah"),
        UnitedStates.State(abbreviation: "VA", name: "Virginia"),
        UnitedStates.State(abbreviation: "VI", name: "Virgin Islands"),
        UnitedStates.State(abbreviation: "VT", name: "Vermont"),
        UnitedStates.State(abbreviation: "WA", name: "Washington"),
        UnitedStates.State(abbreviation: "WI", name: "Wisconsin"),
        UnitedStates.State(abbreviation: "WV", name: "West Virginia"),
        UnitedStates.State(abbreviation: "WY", name: "Wyoming")
    ]
}

extension UnitedStates.State: PickerViewSelectable {
    var id: String {
        isoCode
    }

    var title: String {
        name
    }
}
