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
    @objc var notifications: Bool {
        get {
            let defValue = false
            return value(forKey: .notifications) as? Bool ?? defValue
        } set(newValue) {
            setValue(newValue, forKey: .notifications)
        }
    }
    @objc var strictTyping: Bool {
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
    
    var results: [TFSessionResult] {
        get {
            if let array = value(forKey: .results) as? [Dictionary<String, Any>] {
                return array.map { TFSessionResult(dict: $0) }
            } else {
                return [TFSessionResult]()
            }
        } set (newValue) {
            let dictArray = newValue.map { $0.dict() }
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
    
    var score: Int {
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
    @objc var classicEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .classic) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .classic)
        }
    }
    @objc var quotesEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .quotes) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .quotes)
        }
    }
    @objc var hokkuEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .hokku) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .hokku)
        }
    }
    @objc var cookiesEnabled: Bool {
        get {
            let defValue = showEngTexts ? false : true
            return value(forKey: .cookies) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .cookies)
        }
    }
    @objc var englishEnabled: Bool {
        get {
            let defValue = showEngTexts ? true : false
            return value(forKey: .english) as? Bool ?? defValue
        }
        set(enabled) {
            setValue(enabled, forKey: .english)
        }
    }
    
    func migrateResultsIfNeeded() {
        var versions = migrations ?? [String]()
        if versions.contains("1.1") {
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