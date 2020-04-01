//
//  AppCoordinator.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class AppCoordinator: NSObject {

    let levelProvider: LevelProvider
    let resultsProvider: ResultProvider
    let sounds: SoundService
    let settings: SettingsVM
    let reminder: ReminderService
    let leaderboards: LeaderboardService
    weak var rootNC: UINavigationController!
    
    override init() {
        let levelsPath = Bundle.main.path(forResource: "Levels", ofType: "plist")!
        levelProvider = LevelProvider(levelsPath: levelsPath)
        resultsProvider = ResultProvider(userDefaults: .standard)
        settings = SettingsVM(userDefaults: .standard)
        sounds = SoundService()
        reminder = ReminderService()
        leaderboards = LeaderboardService()
        super.init()
    }
    
    func start(with window: UIWindow) {
        let rootNC = UINavigationController()
        rootNC.navigationBar.isHidden = true
        window.rootViewController = rootNC
        self.rootNC = rootNC
        leaderboards.onShouldPresentAuthVC = { [weak self] (authVC) in
            self?.rootNC.present(authVC, animated: true)
        }
        leaderboards.onShouldDismissVC = { (vc) in
            vc.dismiss(animated: true)
        }
        leaderboards.onScoreReceived = { [weak self] (score) in
            guard let self = self else { return }
            self.resultsProvider.save(score: score)
            self.reloadBestScoreIfNeeded()
        }
        leaderboards.authenticateLocalPlayer()
        showMenu()
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
        typingVC.onViewWillAppear = { [weak self] in
            guard let self = self else { return }
            let level = self.levelProvider.nextLevel(for: self.settings)
            let strict = self.settings.defaults.strictTyping
            typingVC.viewModel = TypingVM(level: level, strictTyping: strict)
        }
        typingVC.onMistake = { [weak self] in
            self?.sounds.play(.mistake)
        }
        typingVC.onLevelCompleted = { [weak self] (viewModel) in
            guard let self = self else { return }
            let result = self.resultsProvider.save(result: viewModel.result)
            if (result == .newRank) {
                self.sounds.play(.newRank)
                self.leaderboards.report(score: Int(viewModel.result.signsPerMin()))
            } else if (result == .newRecord) {
                self.sounds.play(.newRecord)
                self.leaderboards.report(score: Int(viewModel.result.signsPerMin()))
            }
            self.showRemindMeAlertIfNeeded()
            let resultsVM = ResultsVM(level: viewModel.level, result: viewModel.result, event: result, provider: self.resultsProvider)
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
        let settingsVC = SettingsVC(viewModel: settings)
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
        settingsVC.onDonePressed = { [weak self] in
            self?.sounds.play(.buttonClick)
            settingsVC.dismiss(animated: true)
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
    
    func reloadBestScoreIfNeeded() {
        let topVC = rootNC.topViewController
        if let menuVC = topVC as? MenuVC {
            menuVC.reloadViewModel()
        } else if let resultsVC = topVC as? ResultsVC {
            resultsVC.reloadViewModel()
        }
    }
    
    func showRemindMeAlertIfNeeded() {
        let thirdLevelFinished = (resultsProvider.results.count == 3)
        let remindersDisabled = (settings.defaults.notifications == false)
        if (thirdLevelFinished && remindersDisabled) {
            UIAlertController.showRemindMeAlertWith { [weak self] (remind) in
                guard let self = self else { return }
                if (remind) {
                    self.settings.defaults.notifications = true
                    self.reminder.enableReminders()
                } else {
                    self.settings.defaults.notifications = false
                    self.reminder.disableReminders()
                }
            }
        }
    }
    
    func share(text: String) {
        let urlString = "https://apps.apple.com/app/id1013588476"
        let message = "\(text)\n\n\(urlString)"
        let controller = UIActivityViewController(activityItems: [message], applicationActivities: nil)
        controller.excludedActivityTypes = [.postToWeibo, .print, .assignToContact, .saveToCameraRoll, .addToReadingList, .postToVimeo, .postToTencentWeibo, .airDrop];
        rootNC.present(controller, animated: true)
    }
    
    func rateApp() {
        let url = URL(string: "itms-apps://itunes.apple.com/app/id1013588476")!
        UIApplication.shared.open(url)
    }

}
