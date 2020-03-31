//
//  MenuVM.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 30.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//


// we declared VM as class temporary to expose it to objc
// TODO: - change class to struct later
class MenuVM: NSObject {
    let bestResultTitle: String
    let signsPerMin: String
    let signsPerMinTitle: String
    let firstResultTitle: String
    let stars: Float
    let rankTitle: String
    let rankSubtitle: String
    let typeFasterTitle: String
    let settingsTitle: String
    let rateTitle: String
    
    @objc init(resultProvider: TFResultProvider) {
        let first = resultProvider.firstSpeed()
        let best = resultProvider.bestSpeed()
        bestResultTitle = NSLocalizedString("menu.vm.best.result", comment: "")
        
        signsPerMin = "\(best)"
        let chars = String.localizedStringWithFormat(NSLocalizedString("%d char(s)", comment: ""), best)
        signsPerMinTitle = "\(chars) \(NSLocalizedString("common.per.minute", comment: ""))"

        if first == 0 && best == 0 {
            firstResultTitle = NSLocalizedString("menu.vm.complete.first", comment: "")
        } else if (first > 0 && best > first) {
            firstResultTitle = String.localizedStringWithFormat("%@ %d", NSLocalizedString("menu.vm.began.with", comment: ""), first)
        } else {
            firstResultTitle = NSLocalizedString("menu.vm.keep.training", comment: "")
        }
        stars = resultProvider.stars(bySpeed: best)

        let rank = NSLocalizedString("menu.vm.rank", comment: "")
        let rankLevel = resultProvider.rankTitle(bySpeed: best)
        rankTitle = "\(rank) - \(rankLevel)"

        let goal = resultProvider.nextGoal(bySpeed: best)
        if goal > 0 {
            let chars = String.localizedStringWithFormat(NSLocalizedString("%d char(s)", comment: ""), goal)
            let perMin = NSLocalizedString("menu.vm.min", comment: "")
            let nextGoal = NSLocalizedString("menu.vm.next.goal", comment: "")
            let signsPerMin = String.localizedStringWithFormat("%d %@/%@", goal, chars, perMin)
            rankSubtitle = "\(nextGoal) \(signsPerMin)"
        } else {
            rankSubtitle = NSLocalizedString("menu.vm.incredible", comment: "")
        }
        typeFasterTitle = NSLocalizedString("menu.vm.type.faster", comment: "")
        settingsTitle = NSLocalizedString("common.settings", comment: "")
        rateTitle = NSLocalizedString("common.rate", comment: "")
    }
    
    func starImageNames() -> [String] {
        var names = [String]()
        var numberOfFullStars = stars
        let halfStar = (stars-numberOfFullStars > 0)
        for _ in 1...5 {
            if numberOfFullStars > 0 {
                names.append("star_gold.png")
            } else if numberOfFullStars == 0 && halfStar {
                names.append("star_goldgray.png")
            } else {
                names.append("star_gray.png")
            }
            numberOfFullStars -= 1
        }
        return names
    }
    
}
