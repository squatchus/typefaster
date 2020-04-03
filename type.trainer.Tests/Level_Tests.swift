//
//  Level_Tests.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 02.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class Level_Tests: XCTestCase {

    var validDict: Dictionary<String, String>!
    var validLevel: Level!

    override func setUpWithError() throws {
        validDict = [
            "title": "Fight Club",
            "author": "Chuck Palahniuk",
            "category": "categoryEnglish",
            "text": "Losing all hope was freedom."
        ]
        validLevel = Level(dict: validDict)
    }

    override func tearDownWithError() throws {
        validDict = nil
        validLevel = nil
    }
    
    func testInitWithEmptyDict() throws {
        XCTAssertFalse(Level(dict: ["":""]).isValid)
    }
    
    func testInitWithValidDict() throws {
        XCTAssertTrue(validLevel.isValid)
    }
    
    func testTokensCound() throws {
        XCTAssertTrue(validLevel.tokens.count == 10)
    }
    
    func testLevelDict() throws {
        XCTAssertEqual(validLevel.dict, validDict)
    }
    
    func testTokenByWrongPositionLeft() throws {
        XCTAssertNil(validLevel.token(by: -1))
    }
    
    func testTokenByWrongPositionRight() throws {
        // given
        let text = validDict["text"]!
        // when
        let token = validLevel.token(by: text.count)
        // then
        XCTAssertNil(token)
    }
    
    func testTokenByPositionZero() throws {
        XCTAssertEqual(validLevel.token(by: 0)?.string, "Losing")
    }
    
    func testTokenByPositionInText() throws {
        XCTAssertEqual(validLevel.token(by: 5)?.string, "Losing")
    }
        
    func testTokenByPositionLast() throws {
        // given
        let text = validDict["text"]!
        // when
        let token = validLevel.token(by: text.count-1)
        // then
        XCTAssertEqual(token?.string, ".")
    }
    
    func testRealLevelsExistInBundle() {
        XCTAssertNotNil(Bundle.main.path(forResource: "Levels", ofType: "plist"))
    }
    
    func testRealLevelsFromPlist() throws {
        XCTAssertNil(invalidLevels())
    }

    func appLevels() -> [Level] {
        let path = Bundle.main.path(forResource: "Levels", ofType: "plist")!
        let levelsURL = URL(fileURLWithPath: path)
        let levelsData = try! Data(contentsOf: levelsURL)
        let dictArray = levelsData.asPlistArray
        return dictArray.map { Level(dict: $0) }
    }
    
    func invalidLevels() -> [Level]? {
        let levels = appLevels()
        let invalidLevels = levels.filter { !($0.isValid) }
        if invalidLevels.count > 0 {
            return invalidLevels
        }
        return nil
    }
    
}
