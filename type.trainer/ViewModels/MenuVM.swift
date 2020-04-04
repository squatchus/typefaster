//
//  MenuVM.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 30.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import Foundation

struct MenuModel: Codable, Equatable {
    let bestResultTitle: String
    let charsPerMin: String
    let charsPerMinTitle: String
    let resultStatusTitle: String
    let starImageNames: [String]
    let rankTitle: String
    let rankSubtitle: String
    let typeFasterTitle: String
    let settingsTitle: String
    let rateTitle: String
}

struct MenuVM {
    let data: MenuModel

    init(dataModel: MenuModel) {
        self.data = dataModel
    }
    
    init(resultProvider: ResultProvider) {
        let firstSpeed = resultProvider.firstSpeed
        let bestSpeed = resultProvider.bestSpeed
        let bestResultTitle = NSLocalizedString("menu.vm.best.result", comment: "")
        
        let charsPerMin = "\(bestSpeed)"
        let chars = String.localizedStringWithFormat(NSLocalizedString("%d char(s)", comment: ""), bestSpeed)
        let charsPerMinTitle = "\(chars) \(NSLocalizedString("common.per.minute", comment: ""))"

        let resultStatusTitle: String
        if firstSpeed == 0 && bestSpeed == 0 {
            resultStatusTitle = NSLocalizedString("menu.vm.complete.first", comment: "")
        } else if (firstSpeed > 0 && bestSpeed > firstSpeed) {
            resultStatusTitle = String.localizedStringWithFormat("%@ %d", NSLocalizedString("menu.vm.began.with", comment: ""), firstSpeed)
        } else {
            // could happen if first speed is 0 (i.e. we have no records of LevelResults)
            // but bestSpeed recieved from GameCenter (when user get authenticated)
            resultStatusTitle = NSLocalizedString("menu.vm.keep.training", comment: "")
        }
        let starImageNames = resultProvider.starImageNames

        let rank = NSLocalizedString("menu.vm.rank", comment: "")
        let rankLevel = resultProvider.rankTitle(by: bestSpeed)
        let rankTitle = "\(rank) - \(rankLevel)"

        let rankSubtitle: String
        let goal = resultProvider.nextGoal(by: bestSpeed)
        if goal > 0 {
            let chars = String.localizedStringWithFormat(NSLocalizedString("%d char(s)", comment: ""), goal)
            let perMin = NSLocalizedString("menu.vm.min", comment: "")
            let nextGoal = NSLocalizedString("menu.vm.next.goal", comment: "")
            let signsPerMin = String.localizedStringWithFormat("%d %@/%@", goal, chars, perMin)
            rankSubtitle = "\(nextGoal) \(signsPerMin)"
        } else {
            rankSubtitle = NSLocalizedString("menu.vm.incredible", comment: "")
        }
        let typeFasterTitle = NSLocalizedString("menu.vm.type.faster", comment: "")
        let settingsTitle = NSLocalizedString("common.settings", comment: "")
        let rateTitle = NSLocalizedString("common.rate", comment: "")
        
        data = MenuModel(bestResultTitle: bestResultTitle,
                         charsPerMin: charsPerMin,
                         charsPerMinTitle: charsPerMinTitle,
                         resultStatusTitle: resultStatusTitle,
                         starImageNames: starImageNames,
                         rankTitle: rankTitle,
                         rankSubtitle: rankSubtitle,
                         typeFasterTitle: typeFasterTitle,
                         settingsTitle: settingsTitle,
                         rateTitle: rateTitle)
    }
    
}
