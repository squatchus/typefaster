//
//  AppDelegate.h
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAllKeysInKeyboard 31

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong) NSString* leaderboardIdentifier;
@property BOOL gameCenterEnabled;
@property int gameCenterScore;

+ (float)numberOfStarsBySpeed:(int)speed;
+ (NSString *)rankTitleBySpeed:(int)speed;

+ (int)minValueForRank:(NSString *)rankString;
+ (int)maxValueForRank:(NSString *)rankString;
+ (NSString *)rankAfterRank:(NSString *)rankString;

+ (int)firstResult;

+ (int)bestResult;
+ (int)prevBestResult;
+ (NSString *)currentRank;
+ (NSString *)prevRank;

+ (int)numberOfKeysForCurrentRank;
+ (int)numberOfHighestScores;

- (void)playKeyboardClickSound;
- (void)playButtonClickSound;
- (void)playErrorSound;
- (void)playNewResultSound;
- (void)playNewRankSound;

- (void)authenticateLocalPlayer;
- (void)reportScore;

+ (void)enableNotifications;
+ (void)disableNotifications;

+ (int)summaryTimeOfAllTrainings;

@end

