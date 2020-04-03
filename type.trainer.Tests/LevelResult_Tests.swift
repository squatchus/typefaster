//
//  LevelResultTests.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 02.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class LevelResult_Tests: XCTestCase {

    func testInitWithEmptyDict() throws {
        XCTAssertFalse(LevelResult(dict: ["":0]).isVaild)
    }
    
    func testInitWithZeroSeconds() throws {
        // given
        let zeroSecondsDict = ["seconds": 0, "symbols": 100]
        // when
        let result = LevelResult(dict: zeroSecondsDict)
        // then
        XCTAssertFalse(result.isVaild)
    }
    
    func testInitWithZeroSymbols() throws {
        // given
        let zeroSymbolsDict = ["seconds": 100, "symbols": 0]
        // when
        let result = LevelResult(dict: zeroSymbolsDict)
        // then
        XCTAssertFalse(result.isVaild)
    }
    
    func testInit() throws {
        // given
        let zeroDict = ["seconds": 0, "symbols": 0, "mistakes": 0]
        // when
        let result = LevelResult()
        // then
        XCTAssertEqual(result.dict, zeroDict)
    }
    
    func testInitWithValidDict() throws {
        // given
        let validDict = ["seconds": 60, "symbols": 100, "mistakes": 5]
        // when
        let result = LevelResult(dict: validDict)
        // then
        XCTAssertTrue(result.isVaild)
    }
    
    func testResultDict() throws {
        // given
        let validDict = ["seconds": 60, "symbols": 100, "mistakes": 5]
        // when
        let result = LevelResult(dict: validDict)
        // then
        XCTAssertEqual(result.dict, validDict)
    }
    
    func testCharPerMin() throws {
        // given
        let validDict = ["seconds": 60, "symbols": 100, "mistakes": 5]
        // when
        let results = LevelResult(dict: validDict)
        // then
        XCTAssertEqual(results.charsPerMin, 100)
    }
    
    func testCharPerMinWithZeroSeconds() throws {
        // given
        let zeroSecondsDict = ["seconds": 0, "symbols": 100]
        // when
        let result = LevelResult(dict: zeroSecondsDict)
        // then
        XCTAssertEqual(result.charsPerMin, 0)
    }

}
