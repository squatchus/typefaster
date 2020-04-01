//
//  TypingVM.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

enum InputResult {
    case impossible
    case mistaken
    case correct
}

class TypingVM: NSObject {

    var onSessionStarted: (()->())?
    var onSessionEnded: (()->())?
    var onTimerUpdated: ((_ min: Int32, _ sec: Int32)->())?

    let completeTitle: String
    @objc let level: TFLevel
    @objc var result: TFSessionResult
    let strictTyping: Bool
    
    fileprivate var typedString = ""
    fileprivate var awaitedKey: String?
    fileprivate var timer: Timer?
    
    @objc init(level: TFLevel, strictTyping: Bool) {
        completeTitle = NSLocalizedString("typing.vm.complete", comment: "")
        self.level = level
        self.result = TFSessionResult()
        self.strictTyping = strictTyping
        self.awaitedKey = String(level.text.first!)
    }
    
    func startSession()
    {
        awaitedKey = nextAwaitedKey()
        result.seconds = 0
        result.symbols = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }

    func endSession() {
        timer?.invalidate()
        timer = nil
        onSessionEnded?()
    }

    func shouldEndSession() -> Bool
    {
        if typedString.count == level.text.count {
            let mistakeOnLastChar = (awaitedKey == "")
            let strictTypingEnd = (strictTyping && !mistakeOnLastChar)
            if (strictTypingEnd || !strictTyping) {
                return true
            }
        }
        return false
    }
    
    @objc func updateTimer() {
        result.seconds += 1
        let min = result.seconds / 60
        let sec = result.seconds % 60
        onTimerUpdated?(min, sec)
    }
    
    func process(input: String, in range:NSRange) -> InputResult {
        var impossibleOccured = false
        var mistakeOccured = false
        // process backspaces
        let backspaces = typedString.count - range.location
        for _ in 0..<backspaces {
            let result = process(key: "") // backspace
            if result == .impossible { impossibleOccured = true }
            if result == .mistaken { mistakeOccured = true }
        }
        // process typed text
        for key in input {
            let result = process(key: String(key))
            if result == .impossible { impossibleOccured = true }
            if result == .mistaken { mistakeOccured = true }
        }
        if (impossibleOccured) {
            return .impossible
        } else if (mistakeOccured) {
            return .mistaken
        } else {
            return .correct
        }
    }
    
    func process(key: String) -> InputResult {
        if keyCanBeTyped(key) {
            var typedKey = key
            let typedLength = typedString.count
            let newLineExpceted = level.text.isNewLine(at: typedLength)
            if newLineExpceted && typedKey == " " {
                typedKey = "\n"
            }
            // start session if key was typed for the first time
            if (timer == nil) { startSession() }
            // perform input
            let backspaceTyped = (typedKey.count == 0)
            if (backspaceTyped) {
                typedString = String(typedString.dropLast())
            } else {
                typedString.append(typedKey)
            }
            // update awaited key
            awaitedKey = nextAwaitedKey()
            // check for mistakes
            let prevMistakes = result.mistakes
            updateResults()
            let newMistakes = (result.mistakes > prevMistakes)
            // end session if needed
            if shouldEndSession() { endSession() }
            return newMistakes ? .mistaken : .correct
        }
        return .impossible
    }
    
    func keyCanBeTyped(_ key: String) -> Bool {
        guard let awaitedKey = awaitedKey else {
            return false
        }
        let backspaceTyped = (key.count == 0)
        let backspaceOnStart = (backspaceTyped && typedString.count == 0)
        let typedToEnd = (typedString.count == level.text.count)
        let newLineTyped = (key == "\n")
        let newLineExpceted = (awaitedKey == "\n")
        let symbolExpected = (awaitedKey.count > 0 && !newLineExpceted)
        let notAllowedOnNewLineTyped = !(backspaceTyped || "\n ".contains(key))
        // restrictions
        if (backspaceOnStart) {
            return false
        } else if (!backspaceTyped && typedToEnd) {
            return false
        } else if (newLineTyped && !newLineExpceted) {
            return false
        } else if (newLineExpceted && notAllowedOnNewLineTyped) {
            return false
        }
        if (strictTyping) {
            if key.hasSmartMatch(with: awaitedKey) {
                return true // backspace or key match
            } else if (!backspaceTyped && symbolExpected) {
                return true // type 1 wrong key
            } else {
                return false
            }
        } else { // non strict typing
            return true
        }
    }
        
    func nextAwaitedKey() -> String? {
        if typedString.count == 0 {
            return String(level.text.first!)
        }
        let lastTypedKey = String(typedString.last!)
        let supposedKey = level.text[typedString.count-1]
        let lastCorrect = lastTypedKey.hasSmartMatch(with: supposedKey)
        let typedToEnd = typedString.count == level.text.count
        if (lastCorrect) {
            if (typedToEnd) {
                return nil
            } else {
                let nextKeyRange = typedString.count
                let nextKey = level.text[nextKeyRange]
                return nextKey
            }
        } else { // awaited for backspace
            return ""
        }
    }
    
    func updateResults() {
        let backspaceAwaited = (awaitedKey != nil && awaitedKey?.count == 0)
        if strictTyping {
            result.symbols = Int32(typedString.count)
            if (backspaceAwaited) {
                result.mistakes += 1
            }
        } else {
            // symbols used to determine typing speed (chars/min)
            // for non-strict typing mode, we count only symbols of correct words
            result.symbols = 0
            var mistakes = 0
            for token in level.tokens {
                if token.startIndex >= typedString.count { break }
                let length = min(typedString.count-Int(token.startIndex), Int(token.endIndex-token.startIndex)+1)
                let typedRange = NSMakeRange(Int(token.startIndex), length)
                let typedSubstring = typedString[typedRange]
                for i in 0..<typedSubstring.count {
                    let typedKey = typedSubstring[NSMakeRange(i, 1)]
                    let supposedKey = token.string[NSMakeRange(i, 1)]
                    if typedKey.hasSmartMatch(with: supposedKey) == false { mistakes += 1 }
                }
                if token.string.hasSmartPrefix(typedSubstring) {
                    result.symbols += Int32(length)
                }
            }
            result.mistakes = Int32(mistakes)
        }
    }
    
    func symbolsEnteredString() -> String {
        return "\(result.symbols)"
    }

    func shiftHidden() -> Bool {
        if let awaitedKey = awaitedKey {
            let backspaceAwaited = (awaitedKey.count == 0)
            let hidden = (backspaceAwaited || awaitedKey.isUppercased() == false)
            return hidden
        }
        return true
    }

    func backspaceHidden() -> Bool {
        if let awaitedKey = awaitedKey {
            let backspaceAwaited = (awaitedKey.count == 0)
            return !backspaceAwaited
        }
        return true
    }
    
    func getCursorRange() -> NSRange {
        return NSMakeRange(typedString.count, 0);
    }
    
    func getText() -> NSAttributedString {
        // join result string
        let trail = String(level.text.dropFirst(typedString.count))
        let joined = "\(typedString)\(trail)"
        let text = NSMutableAttributedString(string: joined)
        text.addAttribute(.font, value: UIScreen.textFontForDevice(), range: NSMakeRange(0, text.length))
        text.addAttribute(.foregroundColor, value: UIColor.tf_light_text, range: NSMakeRange(0, text.length))
        // style for typed part
        text.addAttribute(.foregroundColor, value: UIColor.tf_dark_text, range: NSMakeRange(0, typedString.count))
        
        for i in 0..<typedString.count {
            let range = NSMakeRange(i, 1)
            let typedLetter = typedString[range]
            let textLetter = level.text[range]
            if typedLetter.hasSmartMatch(with: textLetter) == false {
                text.addAttribute(.foregroundColor, value: UIColor.tf_red, range: range)
            }
        }
        return text
    }

    func getCurrentWord() -> NSAttributedString {
        let backspaceAwaited = (awaitedKey != nil && awaitedKey!.count == 0)
        let tokenPosOffset = backspaceAwaited ? 1 : 0
        let tokenPosition = Int32(typedString.count - tokenPosOffset)
        let token = level.token(byPosition: tokenPosition) ?? level.tokens.last!
        let typedLength = min(typedString.count-Int(token.startIndex), Int(token.endIndex-token.startIndex)+1)
        let typedRange = NSMakeRange(Int(token.startIndex), typedLength)
        let typedPart = typedString[typedRange].replacingOccurrences(of: " ", with: "_")
        let trail = String(token.string.dropFirst(typedPart.count))
        var word = "\(typedPart)\(trail)"
        if (word == " " || word == "\n") { word = "\" \"" }

        let currentWord = NSMutableAttributedString(string: word)
        currentWord.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 24), range: NSMakeRange(0, currentWord.length))
        currentWord.addAttribute(.foregroundColor, value: UIColor.tf_dark_text, range: NSMakeRange(0, currentWord.length))
        currentWord.addAttribute(.foregroundColor, value: UIColor.tf_green, range: NSMakeRange(0, typedPart.count))
        for i in 0..<typedPart.count {
            let range = NSMakeRange(i, 1)
            let typedLetter = typedPart[range]
            let textLetter = token.string[range]
            if typedLetter.hasSmartMatch(with: textLetter) == false {
                currentWord.addAttribute(.foregroundColor, value: UIColor.tf_red, range: range)
            }
        }
        return currentWord;
    }
    
    deinit {
        if timer?.isValid != nil {
            timer?.invalidate()
        }
    }
    
}
