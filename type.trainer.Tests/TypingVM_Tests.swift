//
//  TypingVM_Tests.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 04.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import XCTest
@testable import type_trainer

class TypingVM_Tests: XCTestCase {

    var levelDict: Dictionary<String, String>!
    var level: Level!

    override func setUpWithError() throws {
        levelDict = [
            "title": "Fight Club",
            "author": "Chuck Palahniuk",
            "category": "categoryQuotesEn",
            "text": "Losing all hope\nwas freedom."
        ]
        level = Level(dict: levelDict)
    }

    override func tearDownWithError() throws {
        levelDict = nil
        level = nil
    }
    
    func testSessionStartCallback() throws {
        // given
        var callbackCalled = false
        let vm = TypingVM(level: level, strictTyping: true)
        vm.onSessionStarted = { callbackCalled = true }
        // when
        let _ = vm.input("L", in: NSRange(location: 0, length: 1))
        // then
        XCTAssertTrue(callbackCalled)
    }
    
    func testTimerUpdateCallback() throws {
        // given
        var callbackCalled = false
        let expectation = self.expectation(description: "timer")
        let vm = TypingVM(level: level, strictTyping: true)
        vm.onTimerUpdated = { (min, sec) in
            callbackCalled = true
            expectation.fulfill()
        }
        // when
        let _ = vm.input("L", in: NSRange(location: 0, length: 1))
        // then
        waitForExpectations(timeout: 2, handler: nil)
        XCTAssertTrue(callbackCalled)
    }
    
    func testShiftBackspaceAfterInit() throws {
        // given
        let shiftBackspaceHidden = [false, true]
        // when
        let vm = TypingVM(level: level, strictTyping: true)
        // then
        XCTAssertEqual([vm.shiftHidden, vm.backspaceHidden], shiftBackspaceHidden)
    }
    
    func testShiftBackspaceAfterMistake() throws {
        // given
        let shiftBackspaceHidden = [true, false]
        let vm = TypingVM(level: level, strictTyping: true)
        // when
        let _ = vm.input("A", in: NSRange(location: 0, length: 1))
        // then
        XCTAssertEqual([vm.shiftHidden, vm.backspaceHidden], shiftBackspaceHidden)
    }
    
    func testInputUnexpectedNewLine() throws {
        // given
        let vm = TypingVM(level: level, strictTyping: true)
        // when
        let result = vm.input("\n", in: NSRange(location: 0, length: 1))
        // then
        XCTAssertEqual(result, .impossible)
    }
    
    func testInputExpectedNewLine() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losing all hope")
        // when
        let result = vm.input("\n", in: NSRange(location: 15, length: 1))
        // then
        XCTAssertEqual(result, .correct)
    }
    
    func testInputSpaceOnExpectedNewLine() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losing all hope")
        // when
        let result = vm.input(" ", in: NSRange(location: 15, length: 1))
        // then
        XCTAssertEqual(result, .correct)
    }
    
    func testInputCharOnExpectedNewLine() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losing all hope")
        // when
        let result = vm.input("s", in: NSRange(location: 15, length: 1))
        // then
        XCTAssertEqual(result, .impossible)
    }
    
    func testStrictMistakeBeforeNewLine() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losing all hop3")
        // when
        let result = vm.input("\n", in: NSRange(location: 15, length: 1))
        // then
        XCTAssertEqual(result, .impossible)
    }
    
    func testNonStrictMistakeBeforeNewLine() throws {
        // given
        let vm = viewModel(strictTyping: false, inputString: "Losing all hop3")
        // when
        let result = vm.input("\n", in: NSRange(location: 15, length: 1))
        // then
        XCTAssertEqual(result, .impossible)
    }
    
    func testStrictOneMistake() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losin")
        // when
        let result = vm.input("f", in: NSRange(location: 5, length: 1))
        // then
        XCTAssertEqual(result, .mistaken)
    }
    
    func testStrictTwoMistakesInRow() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losinf")
        // when
        let result = vm.input("f", in: NSRange(location: 6, length: 1))
        // then
        XCTAssertEqual(result, .impossible)
    }
    
    func testNonStrictTwoMistakesInRow() throws {
        // given
        let vm = viewModel(strictTyping: false, inputString: "Losinf")
        // when
        let result = vm.input("f", in: NSRange(location: 6, length: 1))
        // then
        XCTAssertEqual(result, .mistaken)
    }
    
    func testStrictBackspaceOnMistake() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losinf")
        // when
        let result = vm.input("", in: NSRange(location: 5, length: 1))
        // then
        XCTAssertEqual(result, .correct)
    }
    
    func testStrictBackspaceNoMistake() throws {
        // given
        let vm = viewModel(strictTyping: true, inputString: "Losing")
        // when
        let result = vm.input("", in: NSRange(location: 5, length: 1))
        // then
        XCTAssertEqual(result, .impossible)
    }
    
    func testNonStrictBackspaceNoMistake() throws {
        // given
        let vm = viewModel(strictTyping: false, inputString: "Losing")
        // when
        let result = vm.input("", in: NSRange(location: 5, length: 1))
        // then
        XCTAssertEqual(result, .correct)
    }
    
    func testInputLastChar() throws {
        // given
        var callbackCalled = false
        let vm = viewModel(strictTyping: true, inputString: "Losing all hope\nwas freedom")
        vm.onSessionEnded = { callbackCalled = true }
        // when
        let _ = vm.input(".", in: NSRange(location: 28, length: 1))
        // then
        XCTAssertTrue(callbackCalled)
    }
    
    func testStrictLastCharMistake() throws {
        // given
        var callbackCalled = false
        let vm = viewModel(strictTyping: true, inputString: "Losing all hope\nwas freedom")
        vm.onSessionEnded = { callbackCalled = true }
        // when
        let _ = vm.input("s", in: NSRange(location: 28, length: 1))
        // then
        XCTAssertFalse(callbackCalled)
    }
    
    func testNonStrictLastCharMistake() throws {
        // given
        var callbackCalled = false
        let vm = viewModel(strictTyping: false, inputString: "Losing all hope\nwas freedom")
        vm.onSessionEnded = { callbackCalled = true }
        // when
        let _ = vm.input("s", in: NSRange(location: 28, length: 1))
        // then
        XCTAssertTrue(callbackCalled)
    }
    
    func testCurrentWord() throws {
        // given
        let vm = viewModel(strictTyping: false, inputString: "Losing all ho")
        // when
        let word = vm.currentWord.string
        // then
        XCTAssertEqual(word, "hope")
    }
    
    func viewModel(strictTyping: Bool, inputString: String) -> TypingVM {
        let vm = TypingVM(level: level, strictTyping: strictTyping)
        let range = NSRange(location: 0, length: inputString.count)
        let _ = vm.input(inputString, in: range)
        return vm
    }

}
