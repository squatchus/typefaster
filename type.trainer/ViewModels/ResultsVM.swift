//
//  ResultsVM.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import Foundation

class ResultsVM: NSObject {

    let resultTitle: String
    let bestResult: String
    let bestResultTitle: String
    let signsPerMin: String
    let signsPerMinTitle: String
    let mistakes: String
    let mistakesTitle: String
    let stars: Float
    let text: String
    let author: String
    let continueTitle: String
    let settingsTitle: String
    let rateTitle: String
    
    init(level: Level, result:LevelResult, event: ResultEvent, provider: ResultProvider) {
        let bestSpeed = provider.bestSpeed
        let spm = result.signsPerMin
        
        if (event == .newRank) {
            let newRank = NSLocalizedString("results.vm.new.rank", comment: "")
            let rankTitle = provider.rankTitle(by: bestSpeed)
            resultTitle = "\(newRank):\n\(rankTitle)!"
        } else if (event == .newRecord) {
            resultTitle = NSLocalizedString("results.vm.new.record", comment: "")
        } else {
            resultTitle = NSLocalizedString("results.vm.your.result", comment: "")
        }
        
        bestResult = "\(bestSpeed)"
        bestResultTitle = NSLocalizedString("results.vm.best.result", comment: "")
        
        signsPerMin = "\(spm)"
        
        let chars = String.localizedStringWithFormat(NSLocalizedString("%d char(s)", comment: ""), spm)
        signsPerMinTitle = "\(chars)\n\(NSLocalizedString("common.per.minute", comment: ""))"
        
        let linesCount = level.text.components(separatedBy: "\n").count
        let mistakesPercent = result.mistakes * 100 / (level.text.count - (linesCount-1))
        mistakes = "\(mistakesPercent)%"
        mistakesTitle = NSLocalizedString("results.vm.mistakes", comment: "")
        
        stars = provider.stars(by: bestSpeed)
        text = level.text
        author = "\(level.title)\n\(level.author)"
        
        continueTitle = NSLocalizedString("results.vm.continue", comment: "")
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
