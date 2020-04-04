//
//  AppCoordinator.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class AppCoordinator {

    let levelProvider: LevelProvider
    let resultsProvider: ResultProvider
    let sounds: SoundService
    let settings: UserDefaults
    let reminder: ReminderService
    let leaderboards: LeaderboardService
    weak var rootNC: UINavigationController!
    
    init() {
        let levelsPath = Bundle.main.path(forResource: "Levels", ofType: "plist")!
        levelProvider = LevelProvider(levelsPath: levelsPath)
        resultsProvider = ResultProvider(userDefaults: .standard)
        settings = UserDefaults.standard
        sounds = SoundService()
        reminder = ReminderService()
        leaderboards = LeaderboardService()
    }
    
    func start(with window: UIWindow) {
        let rootNC = UINavigationController()
        rootNC.navigationBar.isHidden = true
        window.rootViewController = rootNC
        self.rootNC = rootNC
        setupLeaderboards()
        showMenu()
    }
    
    func setupLeaderboards() {
        leaderboards.onShouldPresentAuthVC = { [weak self] (authVC) in
            self?.rootNC.present(authVC, animated: true)
        }
        leaderboards.onShouldDismissVC = { (vc) in
            vc.dismiss(animated: true)
        }
        leaderboards.onScoreReceived = { [weak self] (score) in
            guard let self = self else { return }
            if let menuVC = self.rootNC.topViewController as? MenuVC {
                let menuVM = MenuVM(resultProvider: self.resultsProvider)
                menuVC.reload(viewModel: menuVM)
            }
        }
        leaderboards.authenticateLocalPlayer()
    }
    
    func showMenu() {
        let menuVM = MenuVM(resultProvider: resultsProvider)
        let menuVC = MenuVC(viewModel: menuVM)
        menuVC.onLeaderboardPressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            if (self.leaderboards.canShowLeaderboard) {
                self.rootNC.present(self.leaderboards.controller, animated: true)
            } else {
                UIAlertController.showLoginToGameCenterAlert()
            }
        }
        menuVC.onPlayPressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.showGame()
        }
        menuVC.onRatePressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.rateApp()
        }
        menuVC.onSetttingsPressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.showSettings()
        }
        rootNC.pushViewController(menuVC, animated: false)
    }
    
    func showGame() {
        let typingVC = TypingVC()
        typingVC.onViewWillAppear = { [weak self] (vc) in
            guard let self = self else { return }
            let level = self.levelProvider.nextLevel(for: self.settings)
            let strict = self.settings.strictTyping
            vc.viewModel = TypingVM(level: level, strictTyping: strict)
        }
        typingVC.onMistake = { [weak self] in
            self?.sounds.play(.mistake)
        }
        typingVC.onLevelCompleted = { [weak self] (viewModel) in
            guard let self = self else { return }
            let event = self.resultsProvider.save(result: viewModel.result)
            if (event == .newRank) {
                self.sounds.play(.newRank)
                self.leaderboards.report(score: viewModel.result.charsPerMin)
            } else if (event == .newRecord) {
                self.sounds.play(.newRecord)
                self.leaderboards.report(score: viewModel.result.charsPerMin)
            }
            self.showRemindMeAlertIfNeeded()
            let resultsVM = ResultsVM(level: viewModel.level, result: viewModel.result, event: event, provider: self.resultsProvider)
            self.showResultsWithViewModel(viewModel: resultsVM)
        }
        typingVC.onDonePressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.rootNC.popViewController(animated: true)
        }
        rootNC.pushViewController(typingVC, animated: true)
    }
    
    func showSettings() {
        let settingsVM = SettingsVM(settings: self.settings)
        let settingsVC = SettingsVC(viewModel: settingsVM)
        settingsVC.onNotificationsSettingChanged = { [weak self] (enabled) in
            guard let self = self else { return }
            if (enabled) {
                self.reminder.enableReminders()
            } else {
                self.reminder.disableReminders()
            }
        }
        settingsVC.onCategorySettingChanged = { [weak self] in
            self?.sounds.play(.buttonClick)
        }
        settingsVC.onShouldDismissVC = { [weak self] (vc) in
            self?.sounds.play(.buttonClick)
            vc.dismiss(animated: true)
        }
        rootNC.topViewController?.present(settingsVC, animated: true)
    }
    
    func showResultsWithViewModel(viewModel: ResultsVM) {
        let resultsVC = ResultsVC(viewModel: viewModel)
        resultsVC.onSharePressed = { [weak self] (text) in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.share(text: text)
        }
        resultsVC.onSettingsPressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.showSettings()
        }
        resultsVC.onRatePressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.rateApp()
        }
        resultsVC.onContinuePressed = { [weak self] in
            guard let self = self else { return }
            self.sounds.play(.buttonClick)
            self.rootNC.popViewController(animated: true)
        }
        rootNC.pushViewController(resultsVC, animated: true)
    }
    
    func showRemindMeAlertIfNeeded() {
        let thirdLevelFinished = (resultsProvider.results.count == 3)
        let remindersDisabled = (settings.notifications == false)
        if (thirdLevelFinished && remindersDisabled) {
            UIAlertController.showRemindMeAlertWith { [weak self] (remind) in
                guard let self = self else { return }
                if (remind) {
                    self.settings.notifications = true
                    self.reminder.enableReminders()
                } else {
                    self.settings.notifications = false
                    self.reminder.disableReminders()
                }
            }
        }
    }
    
    func share(text: String) {
        let urlString = "https://apps.apple.com/app/id1013588476"
        let message = "\(text)\n\n\(urlString)"
        let controller = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        controller.excludedActivityTypes = [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToVimeo, .postToTencentWeibo, .airDrop]
        rootNC.present(controller, animated: true)
    }
    
    func rateApp() {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1013588476")!
        UIApplication.shared.open(url)
    }

}
