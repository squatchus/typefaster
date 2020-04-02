//
//  LevelResult.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 02.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

struct LevelResult  {
    var seconds: Int
    var symbols: Int
    var mistakes: Int
    
    init() {
        seconds = 0
        symbols = 0
        mistakes = 0
    }
    
    init(dict: Dictionary<String, Int>) {
        seconds = Int(dict["seconds"] ?? 0)
        symbols = Int(dict["symbols"] ?? 0)
        mistakes = Int(dict["mistakes"] ?? 0)
    }
    
    var dict: Dictionary<String, Int> {
        ["seconds": seconds, "symbols": symbols, "mistakes": mistakes]
    }
    
    var signsPerMin: Int {
        Int(Float(symbols) / Float(seconds) * 60.0)
    }
}
