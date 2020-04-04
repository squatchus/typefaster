//
//  UserDefaults+Settings.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 30.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import Foundation

enum DefaultsKey: String {
    case notifications = "notifications"
    case strictTyping = "strictTyping"
    
    case prevLevel = "prevLevel"
    case results = "results"
    case migrations = "migratedTo"
    case score = "gameCenterScore"
    
    case classic = "categoryClassic"
    case quotes = "categoryQuotes"
    case hokku = "categoryHokku"
    case cookies = "categoryCookies"
    case english = "categoryQuotesEn"
}

extension UserDefaults {
    func value(forKey key: DefaultsKey) -> Any? {
        value(forKey: key.rawValue)
    }
    func setValue(_ value: Any?, forKey key: DefaultsKey) {
        setValue(value, forKey: key.rawValue)
    }
    
    // settings
    var notifications: Bool {
        get {
            let defValue = false
            return value(forKey: .notifications) as? Bool ?? defValue
        } set(newValue) {
            setValue(newValue, forKey: .notifications)
        }
    }
    var strictTyping: Bool {
        get {
            let defValue = true
            return value(forKey: .strictTyping) as? Bool ?? defValue
        } set(newValue) {
            setValue(newValue, forKey: .strictTyping)
        }
    }
    var prevLevelIndex: Int? {
        get {
            value(forKey: .prevLevel) as? Int
        } set (newValue) {
            setValue(newValue, forKey: .prevLevel)
        }
    }
    
    var results: [LevelResult] {
        get {
            if let array = value(forKey: .results) as? [Dictionary<String, Int>] {
                return array.map { LevelResult(dict: $0) }
            } else {
                return [LevelResult]()
            }
        } set (newValue) {
            let dictArray = newValue.map { $0.dict }
            setValue(dictArray, forKey: .results)
        }
    }
    
    var migrations: [String]? {
        get {
            value(forKey: .migrations) as? [String]
        } set (newValue) {
            setValue(newValue, forKey: .migrations)
        }
    }
    
    var gameCenterScore: Int {
        get {
            value(forKey: .score) as? Int ?? 0
        } set (newValue) {
            setValue(newValue, forKey: .score)
        }
    }
    
    // categories
    private var showEngTexts: Bool {
        get {
            let langCode = Bundle.main.preferredLocalizations.first!
            let showEngTexts = (langCode == "en")
            return showEngTexts
        }
    }
    var classicEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .classic) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .classic)
        }
    }
    var quotesEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .quotes) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .quotes)
        }
    }
    var hokkuEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .hokku) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .hokku)
        }
    }
    var cookiesEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .cookies) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .cookies)
        }
    }
    var englishEnabled: Bool {
        get {
            let defValue = showEngTexts ? true : false
            return value(forKey: .english) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .english)
        }
    }
    
    var allCategories: [String] {
        let all: [DefaultsKey] = [.classic, .cookies, .quotes, .hokku, .english]
        return all.map { $0.rawValue }
    }
    
    var disabledCategories: [String] {
        var disabled = [DefaultsKey]()
        if (!classicEnabled) { disabled.append(.classic) }
        if (!cookiesEnabled) { disabled.append(.cookies) }
        if (!quotesEnabled) { disabled.append(.quotes) }
        if (!hokkuEnabled) { disabled.append(.hokku) }
        if (!englishEnabled) { disabled.append(.english) }
        return disabled.map { $0.rawValue }
    }
    
    func migrateResultsIfNeeded() {
        var versions = migrations ?? [String]()
        if versions.contains("1.1") == false {
            if let results = value(forKey: .results) as? [Dictionary<String, Any>] {
                var newResults = [Dictionary<String, Any>]()
                for dict in results {
                    var newDict =  dict
                    newDict.removeValue(forKey: "level")
                    newResults.append(newDict)
                }
                setValue(newResults, forKey: .results)
                versions.append("1.1")
                migrations = versions
            }
        }
    }
}
