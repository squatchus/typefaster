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
            "category": "categoryQuotesEn",
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
    
}
