//
//  Level.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 02.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

struct Token: Codable {
    let string: String
    let startIndex: Int
    let endIndex: Int
}

struct Level: Codable {
    let title: String
    let author: String
    let text: String
    let category: String
    var tokens = [Token]()
    
    init(dict: Dictionary<String, String>) {
        title = dict["title"]!
        author = dict["author"]!
        text = dict["text"]!
        category = dict["category"]!
        buildTokens()
    }
    
    var dict: Dictionary<String, String> {
        [
            "title": title,
            "author": author,
            "text": text,
            "category": category
        ]
    }
    
    func token(by position: Int) -> Token? {
        for token in tokens {
            let range = token.startIndex...token.endIndex
            if range.contains(position) {
                return token
            }
        }
        return nil
    }
    
    mutating func buildTokens() {
        var parsedTokens = [Token]()
        var curTokenString = ""
        var curTokenStart = -1
        var curTokenEnd = -1
        var i = 0
//        let appendTokenIfNeeded = { (_ charString: String) in
//            if word.count > 0 {
//                end = index-1
//                let token = Token(string: word, startIndex: start, endIndex: end)
//                parsedTokens.append(token)
//
//            }
//        }
//        for character in text {
//            let charString = String(character)
//            if character.isLetter {
//                if word.count == 0 { start = index }
//                word.append(character)
//            } else { // not letter
//                appendTokenIfNeeded(charString)
//            }
//            index += 1
//        }
//        // and repeat 1 more time for the last word
//        appendTokenIfNeeded()
//        tokens = parsedTokens
        
        

        for character in text {
            let cString = String(character)
            if character.isLetter {
                if (curTokenString.count == 0) { curTokenStart = i }
                curTokenString.append(cString)
            } else {
                if (curTokenString.count > 0) {
                    curTokenEnd = i-1
                    let token = Token(string: curTokenString, startIndex: curTokenStart, endIndex: curTokenEnd)
                    parsedTokens.append(token)
                    curTokenString = ""
                }
                let token = Token(string: cString, startIndex: i, endIndex: i)
                parsedTokens.append(token)
            }
            i += 1
        }
        if (curTokenString.count > 0) {
            curTokenEnd = text.count-1
            let token = Token(string: curTokenString, startIndex: curTokenStart, endIndex: curTokenEnd)
            parsedTokens.append(token)
        }
        tokens = parsedTokens
    }
}
