//
//  NotificationService.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFNotificationService.h"

@import UserNotifications;

@implementation TFNotificationService

- (void)enableNotifications
{
    UNAuthorizationOptions options = (UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound);
    [UNUserNotificationCenter.currentNotificationCenter requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError * _Nullable error)
     {
         dispatch_sync(dispatch_get_main_queue(), ^{
             if (granted)
             {
                 NSDate *tomorrow = [NSDate.date dateByAddingTimeInterval:86400];
                 NSDateComponents *components = [NSCalendar.currentCalendar components:(NSCalendarUnitYear | NSCalendarUnitMonth |  NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:tomorrow];
                 [components setMinute:00];
                 [components setHour:20];
                 [components setTimeZone:[NSTimeZone defaultTimeZone]];
                 
                 UNMutableNotificationContent *content = [UNMutableNotificationContent new];
                 content.badge = @(1);
                 content.sound = UNNotificationSound.defaultSound;
                 content.title = NSLocalizedString(@"reminder.title", nil);
                 content.body = NSLocalizedString(@"reminder.message", nil);
                 
                 UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
                 UNNotificationRequest *requset = [UNNotificationRequest requestWithIdentifier:@"local.notification" content:content trigger:trigger];
                 [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:requset withCompletionHandler:nil];
             }
         });
     }];
}

- (void)disableNotifications
{
    [UNUserNotificationCenter.currentNotificationCenter removeAllPendingNotificationRequests];
}

@end
