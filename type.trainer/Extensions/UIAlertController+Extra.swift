//
//  UIAlertController+Extra.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    @objc static func showLoginToGameCenterAlert() {
        let title = NSLocalizedString("alert.leaderboard.title", comment: "")
        let message = NSLocalizedString("alert.leaderboard.message", comment: "")
        let buttonTitle = NSLocalizedString("alert.button.ok", comment: "")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        alert.show()
    }
    
    @objc static func showRemindMeAlertWith(handler: @escaping (_ remind: Bool)->()) {
        let title = NSLocalizedString("common.reminders", comment: "")
        let message = NSLocalizedString("alert.reminder.message", comment: "")
        let cancelTitle = NSLocalizedString("alert.button.no", comment: "")
        let buttonTitle = NSLocalizedString("alert.button.remind", comment: "")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: cancelTitle, style: .cancel, handler: { (action) in
            handler(false)
        }))
        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: { (action) in
            handler(true)
        }))
        alert.show()
    }
    
    func show() {
        DispatchQueue.main.async {
            if let rootVC = UIApplication.shared.delegate?.window??.rootViewController {
                rootVC.present(self, animated: true)
            }
        }
    }
    
}
