import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let triggerChiming = Self("triggerChiming")
}

enum ChimingMode: String, CaseIterable {
    case off
    case minutely
    case quarterly
    case halfHourly
    case hourly

    var id: Self {
        self
    }
}
