//
//  SettingsVM_Tests.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 04.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class SettingsVM_Tests: XCTestCase {

    var defaults: UserDefaults!
    let jsonTemplate = "SettingsVM.json"
    
    override func setUp() {
        defaults = UserDefaults(suiteName: #file)
        
//        // uncoment to update template for current locale
//        let viewModel = SettingsVM(settings: defaults)
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
        let templateModel = TestHelper.load(SettingsModel.self, from: #file, name: jsonTemplate)
        let templateVM = SettingsVM(dataModel: templateModel, settings: defaults)
        // when
        let viewModel = SettingsVM(settings: defaults)
        // then
        XCTAssertEqual(viewModel.data, templateVM.data)
    }

}
