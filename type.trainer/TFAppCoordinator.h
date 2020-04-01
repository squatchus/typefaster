//
//  TFAppCoordinator.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@class SettingsVM;
@class SoundService;
@class ResultProvider;
@class LevelProvider;
@class ReminderService;
@class LeaderboardService;
@class UINavigationController;

@interface TFAppCoordinator : NSObject

@property (strong, nonatomic, readonly) LevelProvider *levelProvider;
@property (strong, nonatomic, readonly) ResultProvider *resultsProvider;
@property (strong, nonatomic, readonly) SoundService *sounds;
@property (strong, nonatomic, readonly) SettingsVM *settings;
@property (strong, nonatomic, readonly) ReminderService *reminder;
@property (strong, nonatomic, readonly) LeaderboardService *leaderboards;

- (void)start:(UINavigationController *)rootNC;

@end

NS_ASSUME_NONNULL_END
