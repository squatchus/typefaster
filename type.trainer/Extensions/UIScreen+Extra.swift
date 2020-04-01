//
//  UIScreen+Extra.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

extension UIScreen {

    static func textFontForDevice() -> UIFont {
        let screenHeight = UIScreen.main.bounds.size.height
        let fontSizes = [
            "896": 18, // 11, 11 pro max
            "812": 17, // 11 pro
            "736": 18, // 6+/7+/8+
            "667": 17, // 6/7/8
            "568": 16, // SE
        ]
        let sizeNumber = fontSizes["\(screenHeight)"]
        let size = CGFloat(sizeNumber ?? 16)
        return UIFont.monospacedSystemFont(ofSize: size, weight: .regular)
    }

    class func verticalMarginForDevice() -> CGFloat {
        let screenHeight = UIScreen.main.bounds.size.height
        let fontSizes = [
            "896": 64, // 11, 11 pro max
            "812": 64, // 11 pro
            "736": 32, // 6+/7+/8+
            "667": 32, // 6/7/8
            "568": 0, // SE
        ]
        let marginNumber = fontSizes["\(screenHeight)"]
        let margin = CGFloat(marginNumber ?? 0)
        return margin
    }
    
}
