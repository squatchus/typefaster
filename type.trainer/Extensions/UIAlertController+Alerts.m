//
//  UIAlertController+Alerts.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "UIAlertController+Alerts.h"

@implementation UIAlertController (Alerts)

+ (void)showLoginToGameCenterAlert
{
    NSString *title = NSLocalizedString(@"alert.leaderboard.title", nil);
    NSString *message = NSLocalizedString(@"alert.leaderboard.message", nil);
    NSString *buttonTitle = NSLocalizedString(@"alert.button.ok", nil);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:nil]];
    [alert show];
}

+ (void)showReminMeAlertWithHandler:(void(^)(BOOL remind))handler
{
    NSString *title = NSLocalizedString(@"common.reminders", nil);
    NSString *message = NSLocalizedString(@"alert.reminder.message", nil);
    NSString *cancelTitle = NSLocalizedString(@"alert.button.no", nil);
    NSString *buttonTitle = NSLocalizedString(@"alert.button.remind", nil);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:cancelTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        handler ? handler(NO) : nil;
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:buttonTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        handler ? handler(YES) : nil;
    }]];
    [alert show];
}

- (void)show
{
    dispatch_async(dispatch_get_main_queue(), ^{
        id<UIApplicationDelegate> app = UIApplication.sharedApplication.delegate;
        [app.window.rootViewController presentViewController:self animated:YES completion:nil];
    });
}

@end
