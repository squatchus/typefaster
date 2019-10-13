//
//  UIAlertController+Alerts.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIAlertController (Alerts)

+ (void)showLoginToGameCenterAlert;
+ (void)showReminMeAlertWithHandler:(void(^)(BOOL remind))handler;

@end

NS_ASSUME_NONNULL_END
