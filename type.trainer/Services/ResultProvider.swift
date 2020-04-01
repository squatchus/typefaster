//
//  ResultProvider.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

@objc enum ResultEvent: Int {
    case none, newRecord, newRank
}

fileprivate enum PlayerRank: Int {
    case lvl0, lvl1, lvl2, lvl3, lvl4, lvl5, lvl6, lvl7, lvl8, lvl9, lvl10
}

class ResultProvider: NSObject {
    
    let defaults: UserDefaults
    
    @objc init(userDefaults: UserDefaults = .standard) {
        defaults = userDefaults
        defaults.migrateResultsIfNeeded()
    }

    @objc var results: [TFSessionResult] {
        defaults.results
    }
    
    @objc var firstSpeed: Int {
        if let first = defaults.results.first?.signsPerMin() {
            return Int (first)
        }
        return 0
    }
    
    @objc var bestSpeed: Int {
        var maxSpeed = 0
        for result in defaults.results {
            if result.signsPerMin() > maxSpeed {
                maxSpeed = Int(result.signsPerMin())
            }
        }
        return max(maxSpeed, defaults.score)
    }
    
    @objc func save(result: TFSessionResult) -> ResultEvent {
        let prevRecord = bestSpeed;
        let prevRank = currentRank

        var prevResults = defaults.results
        prevResults.append(result)
        defaults.results = prevResults
        
        let newRecord = (result.signsPerMin() > prevRecord)
        let newRankAchieved = (currentRank.rawValue > prevRank.rawValue)
        if (newRecord && newRankAchieved) {
            return .newRank;
        } else if (newRecord) {
            return .newRecord;
        } else {
            return .none;
        }
    }
    
    @objc func save(score: Int) {
        defaults.score = score
    }
    
    @objc func nextGoal(by speed: Int) -> Int {
        let rankBySpeed = rank(by: speed)
        if (rankBySpeed.rawValue < PlayerRank.lvl10.rawValue)
        {
            let nextRank = PlayerRank(rawValue: rankBySpeed.rawValue+1)!
            let nextMinValue = minSpeed(for: nextRank)
            let nextMaxValue = maxSpeed(for: nextRank)
            let goal = (speed < nextMinValue) ? nextMinValue : nextMaxValue
            return goal
        }
        return 0

    }
    
    @objc func rankTitle(by speed: Int) -> String {
        let index = rank(by: speed).rawValue
        let rankTitle = [NSLocalizedString("rank.lvl.0", comment: ""),
                         NSLocalizedString("rank.lvl.1", comment: ""),
                         NSLocalizedString("rank.lvl.2", comment: ""),
                         NSLocalizedString("rank.lvl.3", comment: ""),
                         NSLocalizedString("rank.lvl.4", comment: ""),
                         NSLocalizedString("rank.lvl.5", comment: ""),
                         NSLocalizedString("rank.lvl.6", comment: ""),
                         NSLocalizedString("rank.lvl.7", comment: ""),
                         NSLocalizedString("rank.lvl.8", comment: ""),
                         NSLocalizedString("rank.lvl.9", comment: ""),
                         NSLocalizedString("rank.lvl.10", comment: "")][index]
        return rankTitle;
    }
    
    @objc func stars(by speed: Int) -> Double {
        let starRatings = [0, 0.5, 1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]; // 11
        let maxSpeedForRank = maxSpeed(for: rank(by: speed))
        let percent = min(100.0, Float(speed) * 100.0 / Float(maxSpeedForRank))
        let index = Int(percent/10)
        let numberOfStars = starRatings[index]
        return numberOfStars
    }
    
    fileprivate var currentRank: PlayerRank {
        return rank(by: bestSpeed)
    }
    
    fileprivate func rank(by speed: Int) -> PlayerRank {
        if speed < 30       { return .lvl0 } // [0..29]
        else if speed < 40  { return .lvl1 } // [30..39]
        else if speed < 55  { return .lvl2 } // [40..54]
        else if speed < 75  { return .lvl3 } // [55..74]
        else if speed < 100 { return .lvl4 } // [75..99]
        else if speed < 130 { return .lvl5 } // [100..129]
        else if speed < 165 { return .lvl6 } // [130..164]
        else if speed < 205 { return .lvl7 } // [165..204]
        else if speed < 250 { return .lvl8 } // [204..249]
        else if speed < 300 { return .lvl9 } // [250..299]
        else { return .lvl10 }
    }
    
    fileprivate func minSpeed(for rank: PlayerRank) -> Int {
        let minValue = [0, 30, 40, 55, 75, 100, 130, 165, 205, 250, 350][rank.rawValue]
        return minValue;
    }

    fileprivate func maxSpeed(for rank: PlayerRank) -> Int {
        let maxValue = [30, 40, 55, 75, 100, 130, 165, 205, 250, 300, 400][rank.rawValue]
        return maxValue;
    }
    
}
