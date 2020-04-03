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
    
    let settings: UserDefaults

    init(settings: UserDefaults = .standard) {
        self.settings = settings
        
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

}
