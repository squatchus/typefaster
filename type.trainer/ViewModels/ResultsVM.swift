//
//  ResultsVM.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import Foundation

struct ResultsModel: Codable, Equatable {
    let resultTitle: String
    let bestResult: String
    let bestResultTitle: String
    let signsPerMin: String
    let signsPerMinTitle: String
    let mistakes: String
    let mistakesTitle: String
    let starImageNames: [String]
    let text: String
    let author: String
    let continueTitle: String
    let settingsTitle: String
    let rateTitle: String
}

class ResultsVM {

    let data: ResultsModel
    
    init(dataModel: ResultsModel) {
        self.data = dataModel
    }
    
    init(level: Level, result: LevelResult, event: ResultEvent, provider: ResultProvider) {
        let bestSpeed = provider.bestSpeed
        let spm = result.charsPerMin
        
        let resultTitle: String
        if (event == .newRank) {
            let newRank = NSLocalizedString("results.vm.new.rank", comment: "")
            let rankTitle = provider.rankTitle(by: bestSpeed)
            resultTitle = "\(newRank):\n\(rankTitle)!"
        } else if (event == .newRecord) {
            resultTitle = NSLocalizedString("results.vm.new.record", comment: "")
        } else {
            resultTitle = NSLocalizedString("results.vm.your.result", comment: "")
        }
        
        let bestResult = "\(bestSpeed)"
        let bestResultTitle = NSLocalizedString("results.vm.best.result", comment: "")
        
        let signsPerMin = "\(spm)"
        
        let chars = String.localizedStringWithFormat(NSLocalizedString("%d char(s)", comment: ""), spm)
        let signsPerMinTitle = "\(chars)\n\(NSLocalizedString("common.per.minute", comment: ""))"
        
        let linesCount = level.text.components(separatedBy: "\n").count
        let mistakesPercent = result.mistakes * 100 / (level.text.count - (linesCount-1))
        let mistakes = "\(mistakesPercent)%"
        let mistakesTitle = NSLocalizedString("results.vm.mistakes", comment: "")
        
        let starImageNames = provider.starImageNames
        let text = level.text
        let author = "\(level.title)\n\(level.author)"
        
        let continueTitle = NSLocalizedString("results.vm.continue", comment: "")
        let settingsTitle = NSLocalizedString("common.settings", comment: "")
        let rateTitle = NSLocalizedString("common.rate", comment: "")
        
        self.data = ResultsModel(resultTitle: resultTitle,
                                 bestResult: bestResult,
                                 bestResultTitle: bestResultTitle,
                                 signsPerMin: signsPerMin,
                                 signsPerMinTitle: signsPerMinTitle,
                                 mistakes: mistakes,
                                 mistakesTitle: mistakesTitle,
                                 starImageNames: starImageNames,
                                 text: text,
                                 author: author,
                                 continueTitle: continueTitle,
                                 settingsTitle: settingsTitle,
                                 rateTitle: rateTitle)
    }
    
}
