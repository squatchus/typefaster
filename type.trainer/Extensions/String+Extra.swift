//
//  String+Extra.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 31.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

extension String {

    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
    
    subscript(range: NSRange) -> String {
        let loc = range.location
        let len = range.length
        let fromIndex = index(startIndex, offsetBy: loc)
        let toIndex = index(startIndex, offsetBy: loc+len)
        let range = fromIndex..<toIndex
        return String(self[range])
    }
    
    func isNewLine(at index: Int) -> Bool {
        if index < self.count {
            return self[index] == "\n"
        } else {
            return false
        }
    }

    func isUppercased() -> Bool {
        let comps = self.components(separatedBy: CharacterSet.letters.inverted)
        let isLetter = (comps.count == 1)
        let isUppercased = (self == self.uppercased())
        return isLetter && isUppercased
    }
    
    func hasSmartMatch(with key: String) -> Bool {
        let typedKey = self
        if (key == "ё" && typedKey == "е") {
            return true
        } else if (key == "Ё" && typedKey == "Е") {
            return true
        } else if (key == "\n" && typedKey == " ") {
            return true
        }
        return typedKey == key
    }
    
    func hasSmartPrefix(_ typedPrefix: String) -> Bool {
        let fullWord = self
        for i in 0..<typedPrefix.count {
            let range = NSMakeRange(i, 1)
            let typedKey = typedPrefix[range]
            let wordKey = fullWord[range]
            if !typedKey.hasSmartMatch(with: wordKey) {
                return false
            }
        }
        return true
    }
    
    var justified: NSAttributedString {
        let style = NSMutableParagraphStyle()
        style.alignment = .justified
        style.firstLineHeadIndent = 1.0
        let attributes = [NSAttributedString.Key.paragraphStyle: style]
        return NSAttributedString(string: self, attributes: attributes)
    }
    
}
