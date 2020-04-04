//
//  ResultsVM_Tests.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 04.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class ResultsVM_Tests: XCTestCase {

    var defaults: UserDefaults!
    let jsonTemplate = "ResultsVM.json"
    
    override func setUpWithError() throws {
        defaults = UserDefaults(suiteName: #file)
        
//        // uncoment to update template for current locale
//        let viewModel = viewModelFirstLevelOneResult()
//        TestHelper.save(object: viewModel.data, from: #file, name: jsonTemplate)
    }
    
    override func tearDownWithError() throws {
        if (defaults != nil) {
            defaults.removePersistentDomain(forName: #file)
            defaults = nil
        }
    }
    
    func testTemplateMatch() throws {
        // given
        let templateModel = TestHelper.load(ResultsModel.self, from: #file, name: jsonTemplate)
        let templateVM = ResultsVM(dataModel: templateModel)
        // when
        let viewModel = viewModelFirstLevelOneResult()
        // then
        XCTAssertEqual(viewModel.data, templateVM.data)
    }
    
    func viewModelFirstLevelOneResult() -> ResultsVM {
        let resultsProvider = resultProviderWithOneResult()
        let levelProvider = LevelProvider()
        let level = levelProvider.levels.first!
        let result = resultsProvider.results.last!
        let viewModel = ResultsVM(level: level, result: result, event: .none, provider: resultsProvider)
        return viewModel
    }

    func resultProviderWithOneResult(speed:Int = 100) -> ResultProvider {
        let provider = ResultProvider(userDefaults: defaults)
        let result = LevelResult(dict: ["seconds": 60, "symbols": speed])
        let _ = provider.save(result: result)
        return provider
    }

}
