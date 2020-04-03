//
//  LevelProvider_Tests.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 03.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class LevelProvider_Tests: XCTestCase {

    var defaults: UserDefaults!
    
    override func tearDownWithError() throws {
        if (defaults != nil) {
            defaults.removePersistentDomain(forName: #file)
            defaults = nil
        }
    }
    
    func testLevelsExistInBundle() {
        XCTAssertNotNil(Bundle.main.path(forResource: "Levels", ofType: "plist"))
    }
    
    func testInitWithPath() throws {
        // given
        let path = Bundle.main.path(forResource: "Levels", ofType: "plist")!
        // when
        let provider = LevelProvider(levelsPath: path)
        // then
        XCTAssertNil(invalidLevels(from: provider.levels))
    }

    func testNextLevelClassic() throws {
        // given
        defaults = defaultsWithOneEnabled(category: "categoryClassic")
        let provider = LevelProvider()
        // when
        let nextLevel = provider.nextLevel(for: defaults)
        // then
        XCTAssertEqual(nextLevel.category, "categoryClassic")
    }

    func testNextLevelQuotes() throws {
        // given
        defaults = defaultsWithOneEnabled(category: "categoryQuotes")
        let provider = LevelProvider()
        // when
        let nextLevel = provider.nextLevel(for: defaults)
        // then
        XCTAssertEqual(nextLevel.category, "categoryQuotes")
    }
    
    func testNextLevelHokku() throws {
        // given
        defaults = defaultsWithOneEnabled(category: "categoryHokku")
        let provider = LevelProvider()
        // when
        let nextLevel = provider.nextLevel(for: defaults)
        // then
        XCTAssertEqual(nextLevel.category, "categoryHokku")
    }
    
    func testNextLevelCookies() throws {
        // given
        defaults = defaultsWithOneEnabled(category: "categoryCookies")
        let provider = LevelProvider()
        // when
        let nextLevel = provider.nextLevel(for: defaults)
        // then
        XCTAssertEqual(nextLevel.category, "categoryCookies")
    }
    
    func testNextLevelEnglish() throws {
        // given
        defaults = defaultsWithOneEnabled(category: "categoryQuotesEn")
        let provider = LevelProvider()
        // when
        let nextLevel = provider.nextLevel(for: defaults)
        // then
        XCTAssertEqual(nextLevel.category, "categoryQuotesEn")
    }
    
    func defaultsWithOneEnabled(category: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: #file)!
        defaults.classicEnabled = false
        defaults.quotesEnabled = false
        defaults.hokkuEnabled = false
        defaults.cookiesEnabled = false
        defaults.englishEnabled = false
        defaults.set(true, forKey: category)
        return defaults
    }
    
    func invalidLevels(from levels:[Level]) -> [Level]? {
        let invalidLevels = levels.filter { !($0.isValid) }
        if invalidLevels.count > 0 {
            return invalidLevels
        }
        return nil
    }

}
