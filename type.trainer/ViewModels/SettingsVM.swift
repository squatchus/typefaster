//
//  SettingsVM.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 30.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import Foundation

struct SettingsModel: Codable, Equatable {
    var settingsTitle: String
    var notificationsTitle: String
    var notificationsInfo: String
    var strictTypingTitle: String
    var strictTypingInfo: String
    var doneTitle: String
}

class SettingsVM {

    let data: SettingsModel
    let settings: UserDefaults

    init(dataModel: SettingsModel, settings: UserDefaults = .standard) {
        self.data = dataModel
        self.settings = settings
    }
    
    init(settings: UserDefaults = .standard) {
        self.settings = settings
        let settingsTitle = NSLocalizedString("common.settings", comment: "")
        let notificationsTitle = NSLocalizedString("common.reminders", comment: "")
        let strictTypingTitle = NSLocalizedString("settings.vm.strict.typing", comment: "")
        let doneTitle = NSLocalizedString("button.done", comment: "")
        let notificationsInfo = NSLocalizedString("settings.vm.reminders.info", comment: "")
        let strictTypingInfo = NSLocalizedString("settings.vm.strict.typing.info", comment: "")
        data = SettingsModel(settingsTitle: settingsTitle,
                             notificationsTitle: notificationsTitle,
                             notificationsInfo: notificationsInfo,
                             strictTypingTitle: strictTypingTitle,
                             strictTypingInfo: strictTypingInfo,
                             doneTitle: doneTitle)
    }

}
