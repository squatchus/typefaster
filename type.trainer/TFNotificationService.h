//
//  NotificationService.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFNotificationService : NSObject

- (void)enableNotifications;
- (void)disableNotifications;

@end

NS_ASSUME_NONNULL_END
