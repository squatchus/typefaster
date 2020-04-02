//
//  SettingsVM.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 30.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class SettingsVM: NSObject {

    let settingsTitle: String
    let notificationsTitle: String
    let notificationsInfo: NSAttributedString
    let strictTypingTitle: String
    let strictTypingInfo: NSAttributedString
    let doneTitle: String
    
    let defaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults
        
        settingsTitle = NSLocalizedString("common.settings", comment: "")
        notificationsTitle = NSLocalizedString("common.reminders", comment: "")
        strictTypingTitle = NSLocalizedString("settings.vm.strict.typing", comment: "")
        doneTitle = NSLocalizedString("button.done", comment: "")
        
        let style = NSMutableParagraphStyle()
        style.alignment = .justified
        style.firstLineHeadIndent = 1.0
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        notificationsInfo = NSAttributedString(string: NSLocalizedString("settings.vm.reminders.info", comment: ""), attributes: attributes)
        strictTypingInfo = NSAttributedString(string: NSLocalizedString("settings.vm.strict.typing.info", comment: ""), attributes: attributes)
    }

    var allCategories: [String] {
        let all: [DefaultsKey] = [.classic, .cookies, .quotes, .hokku, .english]
        return all.map { $0.rawValue }
    }
    
    var disabledCategories: [String] {
        var disabled = [DefaultsKey]()
        if (!defaults.classicEnabled) { disabled.append(.classic) }
        if (!defaults.cookiesEnabled) { disabled.append(.cookies) }
        if (!defaults.quotesEnabled) { disabled.append(.quotes) }
        if (!defaults.hokkuEnabled) { disabled.append(.hokku) }
        if (!defaults.englishEnabled) { disabled.append(.english) }
        return disabled.map { $0.rawValue }
    }
    
}
