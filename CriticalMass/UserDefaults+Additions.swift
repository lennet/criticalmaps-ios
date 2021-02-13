//
//  CriticalMaps

import Foundation
import UIKit

public extension UserDefaults {
    static func makeClearedInstance(
        for functionName: StaticString = #function,
        inFile fileName: StaticString = #file
    ) -> UserDefaults {
        let className = "\(fileName)".split(separator: ".")[0]
        let testName = "\(functionName)".split(separator: "(")[0]
        let suiteName = "de.pokuslabs.criticalmassberlin.test.\(className).\(testName)"

        let defaults = self.init(suiteName: suiteName)!
        defaults.removePersistentDomain(forName: suiteName)
        return defaults
    }
}

public extension UserDefaults {
    private enum Keys {
        static let observationModeKey = "observationMode"
        static let lastMessageReadTimeIntervalKey = "lastMessageReadTimeInterval"
        static let themeKey = "theme"
        static let lastDayUsedKey = "lastDayUsed"
        static let daysCounterKey = "daysCounter"
        static let usesCounterKey = "usesCounter"
        static let lastRatedVersionKey = "lastRatedVersion"
        static let userNameKey = "username"
        static let nextRideRadius = "nextRideRadius"
    }

    // TODO: Move default value to PreferenceStore
    /// - Returns: Searchradius in Kilometer. Default value is 20
    var nextRideRadius: Int {
        set { set(newValue, forKey: Keys.nextRideRadius) }
        get {
            let radius = integer(forKey: Keys.nextRideRadius)
            guard radius != 0 else { return 20 } // Returns a default radius of 20 Kilometer to search for events
            return radius
        }
    }

    var username: String? {
        set { set(newValue, forKey: Keys.userNameKey) }
        get { string(forKey: Keys.userNameKey) }
    }

    var observationMode: Bool {
        set { set(newValue, forKey: Keys.observationModeKey) }
        get { bool(forKey: Keys.observationModeKey) }
    }

    var lastMessageReadTimeInterval: Double {
        set { set(newValue, forKey: Keys.lastMessageReadTimeIntervalKey) }
        get { double(forKey: Keys.lastMessageReadTimeIntervalKey) }
    }

    var theme: String? {
        set { set(newValue, forKey: Keys.themeKey) }
        get { string(forKey: Keys.themeKey) }
    }

    var lastDayUsed: Date? {
        set { set(newValue, forKey: Keys.lastDayUsedKey) }
        get { object(forKey: Keys.lastDayUsedKey) as? Date }
    }

    var daysCounter: Int {
        set { set(newValue, forKey: Keys.daysCounterKey) }
        get { integer(forKey: Keys.daysCounterKey) }
    }

    var usesCounter: Int {
        set { set(newValue, forKey: Keys.usesCounterKey) }
        get { integer(forKey: Keys.usesCounterKey) }
    }

    var lastRatedVersion: String? {
        set { set(newValue, forKey: Keys.lastRatedVersionKey) }
        get { string(forKey: Keys.lastRatedVersionKey) }
    }
}
