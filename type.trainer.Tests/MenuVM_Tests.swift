//
//  MenuViewModel.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 02.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class MenuVM_Tests: XCTestCase {

    var defaults: UserDefaults!
    let jsonTemplate = "MenuVM.json"
    
    override func setUpWithError() throws {
        defaults = UserDefaults(suiteName: #file)
        
//        // uncoment to update template for current locale
//        let provider = resultProviderWithOneResult()
//        let viewModel = MenuVM(resultProvider: provider)
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
        let templateModel = TestHelper.load(MenuModel.self, from: #file, name: jsonTemplate)
        let templateVM = MenuVM(dataModel: templateModel)
        let provider = resultProviderWithOneResult()
        // when
        let viewModel = MenuVM(resultProvider: provider)
        // then
        XCTAssertEqual(viewModel.data, templateVM.data)
    }
    
    func resultProviderWithOneResult(speed:Int = 100) -> ResultProvider {
        let provider = ResultProvider(userDefaults: defaults)
        let result = LevelResult(dict: ["seconds": 60, "symbols": speed])
        let _ = provider.save(result: result)
        return provider
    }

}
