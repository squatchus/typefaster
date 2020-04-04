//
//  TestHelper.swift
//  type.trainer.Tests
//
//  Created by Sergey Mazulev on 04.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class TestHelper {

    static func save<T: Codable>(object: T, from path: String, name: String) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        if let data = try? encoder.encode(object) {
            let folderName = "\(Locale.current.identifier).lproj"
            let url = URL(fileURLWithPath: path).deletingLastPathComponent().appendingPathComponent(folderName).appendingPathComponent(name)
            try? data.write(to: url)
        }
    }
    
    static func load<T: Codable>(_ type: T.Type, from path: String, name: String) -> T {
        let folderName = "\(Locale.current.identifier).lproj"
        let url = URL(fileURLWithPath: path).deletingLastPathComponent().appendingPathComponent(folderName).appendingPathComponent(name)
        let data = try! Data(contentsOf: url)
        return try! JSONDecoder().decode(type, from: data)
    }
}
