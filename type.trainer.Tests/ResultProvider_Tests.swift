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
    
    let results_1_0 = [
        ["seconds": 60, "symbols": 80, "level": "someData"],
        ["seconds": 60, "symbols": 100, "level": "someData"],
        ["seconds": 60, "symbols": 90, "level": "someData"]
    ]
    let results_1_1 = [
        ["seconds": 60, "symbols": 80],
        ["seconds": 60, "symbols": 100],
        ["seconds": 60, "symbols": 90],
    ]
    
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
        let r1 = provider.results
        let r2 = levelResultsVersion_1_1()
        XCTAssertEqual(r1, r2)
    }
    
    func testInitWithDefaultsVersion_1_1() throws {
        // given
        defaults = defaultsWithResultsVersion_1_1()
        // when
        let provider = ResultProvider(userDefaults: defaults)
        // then
        XCTAssertEqual(provider.results, levelResultsVersion_1_1())
    }

    func testFirstSpeed() throws {
        // given
        defaults = defaultsWithResultsVersion_1_1()
        // when
        let provider = ResultProvider(userDefaults: defaults)
        // then
        XCTAssertEqual(provider.firstSpeed, 80)
    }
    
    func testBestSpeed() throws {
        // given
        defaults = defaultsWithResultsVersion_1_1()
        // when
        let provider = ResultProvider(userDefaults: defaults)
        // then
        XCTAssertEqual(provider.bestSpeed, 100)
    }
    
    func testSaveResults() throws {
        // given
        defaults = defaultsWithResultsVersion_1_1()
        let provider = ResultProvider(userDefaults: defaults)
        let result = LevelResult(dict: ["seconds": 60, "symbols": 80])
        // when
        let resultEvent = provider.save(result: result)
        // then
        XCTAssertEqual(resultEvent, ResultEvent.none)
    }
    
    func testSaveResultsNewRecord() throws {
        // given
        defaults = defaultsWithResultsVersion_1_1()
        let provider = ResultProvider(userDefaults: defaults)
        let result = LevelResult(dict: ["seconds": 60, "symbols": 115])
        // when
        let resultEvent = provider.save(result: result)
        // then
        XCTAssertEqual(resultEvent, ResultEvent.newRecord)
    }
    
    func testSaveResultsNewRank() throws {
        // given
        defaults = defaultsWithResultsVersion_1_1()
        let provider = ResultProvider(userDefaults: defaults)
        let result = LevelResult(dict: ["seconds": 60, "symbols": 130])
        // when
        let resultEvent = provider.save(result: result)
        // then
        XCTAssertEqual(resultEvent, ResultEvent.newRank)
    }
    
    func testSaveScore() throws {
        // given
        defaults = UserDefaults(suiteName: #file)
        let provider = ResultProvider(userDefaults: defaults)
        // when
        provider.save(score: 42)
        // then
        XCTAssertEqual(defaults.integer(forKey: DefaultsKey.score.rawValue), 42)
    }
    
    func testNextGoalWithLowSpeed() throws {
        // given
        defaults = UserDefaults(suiteName: #file)
        let provider = ResultProvider(userDefaults: defaults)
        let lowSpeed = 15 // chars per minute
        // when
        let firstGoal = provider.nextGoal(by: lowSpeed)
        // then
        XCTAssertEqual(firstGoal, 30)
    }
    
    func testNextGoalWithHighSpeed() throws {
        // given
        defaults = UserDefaults(suiteName: #file)
        let provider = ResultProvider(userDefaults: defaults)
        let tooHighSpeed = 415 // chars per minute
        // when
        let goal = provider.nextGoal(by: tooHighSpeed)
        // then
        XCTAssertEqual(goal, 0)
    }
    
    func testRankTitle() throws {
        // given
        defaults = UserDefaults(suiteName: #file)
        let provider = ResultProvider(userDefaults: defaults)
        let lowSpeed = 15 // chars per minute
        let firstRankTitle = NSLocalizedString("rank.lvl.0", comment: "")
        // when
        let title = provider.rankTitle(by: lowSpeed)
        // then
        XCTAssertEqual(title, firstRankTitle)
    }
    
    func testStarsImageNames() throws {
        // given
        defaults = UserDefaults(suiteName: #file)
        let provider = ResultProvider(userDefaults: defaults)
        let twoAndHalfStarsResult = LevelResult(dict: ["seconds": 60, "symbols": 15])
        let twoAndHapfStarsImageNames = ["star_gold.png", "star_gold.png", "star_goldgray.png", "star_gray.png", "star_gray.png"]
        // when
        let _ = provider.save(result: twoAndHalfStarsResult)
        // then
        XCTAssertEqual(provider.starImageNames, twoAndHapfStarsImageNames)
    }

    func defaultsWithResultsVersion_1_0() -> UserDefaults {
        let defaults = UserDefaults(suiteName: #file)!
                defaults.set(results_1_0, forKey: DefaultsKey.results.rawValue)
        return defaults
    }
    
    func defaultsWithResultsVersion_1_1() -> UserDefaults {
        let defaults = UserDefaults(suiteName: #file)!
        defaults.set(results_1_1, forKey: DefaultsKey.results.rawValue)
        return defaults
    }
    
    func levelResultsVersion_1_1() -> [LevelResult] {
        results_1_1.map { LevelResult(dict: $0) }
    }
    
}
