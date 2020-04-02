//
//  ReminderService.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

class ReminderService: NSObject {
    
    func enableReminders() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { (granted, error) in
            DispatchQueue.main.async {
                if granted {
                    let tomorrow = Date().addingTimeInterval(86400)
                    var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: tomorrow)
                    components.minute = 0
                    components.hour = 20

                    let content = UNMutableNotificationContent()
                    content.badge = 1
                    content.sound = .default
                    content.title = NSLocalizedString("reminder.title", comment: "")
                    content.body = NSLocalizedString("reminder.message", comment: "")
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                    let request = UNNotificationRequest(identifier: "local.notification", content: content, trigger: trigger)
                    UNUserNotificationCenter.current().add(request)
                }
            }
        }
    }
    
    func disableReminders() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
