//
//  ResultProvider.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 03.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class ResultProvider_Tests: XCTestCase {

    var defaults: UserDefaults!
    
    override func tearDownWithError() throws {
        defaults.removePersistentDomain(forName: #file)
        defaults = nil
    }
        
    func testInitWithDefaultsVersion_1_0() throws {
        // given
        defaults = defaultsWithResultsVersion_1_0()
        // when
        let provider = ResultProvider(userDefaults: defaults)
        // then
        XCTAssertEqual(provider.results, resultsVersion_1_1())
    }
    
    func testInitWithDefaultsVersion_1_1() throws {
        // given
        defaults = defaultsWithResultsVersion_1_1()
        // when
        let provider = ResultProvider(userDefaults: defaults)
        // then
        XCTAssertEqual(provider.results, resultsVersion_1_1())
    }

    func defaultsWithResultsVersion_1_0() -> UserDefaults {
        let defaults = UserDefaults(suiteName: #file)!
        let results = [
            ["seconds": 60, "symbols": 80, "level": "someData"],
            ["seconds": 60, "symbols": 90, "level": "someData"],
            ["seconds": 60, "symbols": 100, "level": "someData"]
        ]
        defaults.set(results, forKey: DefaultsKey.results.rawValue)
        return defaults
    }
    
    func defaultsWithResultsVersion_1_1() -> UserDefaults {
        let defaults = UserDefaults(suiteName: #file)!
        let resultsRaw = resultsVersion_1_1().map { $0.dict }
        defaults.set(resultsRaw, forKey: DefaultsKey.results.rawValue)
        return defaults
    }
    
    func resultsVersion_1_1() -> [LevelResult] {
        [
            LevelResult(dict: ["seconds": 60, "symbols": 80]),
            LevelResult(dict: ["seconds": 60, "symbols": 90]),
            LevelResult(dict: ["seconds": 60, "symbols": 100]),
        ]
    }
}
