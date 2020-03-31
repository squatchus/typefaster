//
//  TFAppCoordinator.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFResultProvider.h"
#import "TFLeaderboardService.h"
#import "TFNotificationService.h"
#import "TFSoundService.h"

NS_ASSUME_NONNULL_BEGIN

@class SettingsVM;
@class LevelProvider;

@interface TFAppCoordinator : NSObject

@property (strong, nonatomic, readonly) LevelProvider *levelProvider;
@property (strong, nonatomic, readonly) TFResultProvider *resultsProvider;
@property (strong, nonatomic, readonly) TFSoundService *sounds;
@property (strong, nonatomic, readonly) SettingsVM *settings;
@property (strong, nonatomic, readonly) TFNotificationService *reminder;
@property (strong, nonatomic, readonly) TFLeaderboardService *leaderboards;

- (void)start;

@end

NS_ASSUME_NONNULL_END
