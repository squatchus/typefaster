//
//  LevelProvider.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

extension Data {
    var asPlistArray: [Dictionary<String, String>] {
        try! PropertyListSerialization.propertyList(from: self, options: [], format: nil) as! [Dictionary<String, String>]
    }
}

class LevelProvider {
    
    let levels: [Level]
    
    init(levelsPath: String = Bundle.main.path(forResource: "Levels", ofType: "plist")!) {
        let levelsURL = URL(fileURLWithPath: levelsPath)
        let levelsData = try! Data(contentsOf: levelsURL)
        let dictArray = levelsData.asPlistArray
        levels = dictArray.map { Level(dict: $0) }
    }
    
    func nextLevel(for settings: UserDefaults) -> Level {
        // filter available levels
        let disabledCategories = settings.disabledCategories
        let allDisabled = (disabledCategories.count == settings.allCategories.count)
        let allowedLevels = levels.filter {
            let allowed = !disabledCategories.contains($0.category)
            return allowed || allDisabled
        }
        // update level index
        var levelIndex = 0
        if let prevIndex = settings.prevLevelIndex {
            let newIndex = prevIndex + 1
            if (newIndex < allowedLevels.count) {
                levelIndex = newIndex
            }
        }
        settings.prevLevelIndex = levelIndex
        return allowedLevels[levelIndex]
    }
    
}
