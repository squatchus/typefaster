//
//  LeaderboardService.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

@import Foundation;

NS_ASSUME_NONNULL_BEGIN

@interface TFLeaderboardService : NSObject

@property (nonatomic, copy) void (^onScoreReceived)(int score);

- (void)authenticateLocalPlayer;
- (BOOL)canShowLeaderboard;
- (void)showLeaderboard;
- (void)reportScore:(int)score;

@end

NS_ASSUME_NONNULL_END
