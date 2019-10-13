//
//  SettingsService.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface TFSettingsVM : NSObject

@property (strong, nonatomic, readonly) NSString *settingsTitle;
@property (strong, nonatomic, readonly) NSString *notificationsTitle;
@property (strong, nonatomic, readonly) NSString *notificationsInfo;
@property (strong, nonatomic, readonly) NSString *strictTypingTitle;
@property (strong, nonatomic, readonly) NSString *strictTypingInfo;
@property (strong, nonatomic, readonly) NSString *doneTitle;

@property BOOL notifications;
@property BOOL strictTyping;

@property BOOL categoryClassic;
@property BOOL categoryQuotes;
@property BOOL categoryHokku;
@property BOOL categoryCookies;

@end

NS_ASSUME_NONNULL_END
