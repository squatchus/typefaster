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

+ (float)numberOfStarsBySpeed:(int)speed;
+ (NSString *)rankTitleBySpeed:(int)speed;

+ (int)minValueForRank:(NSString *)rankString;
+ (int)maxValueForRank:(NSString *)rankString;
+ (NSString *)rankAfterRank:(NSString *)rankString;

+ (int)bestResult;
+ (int)prevBestResult;
+ (NSString *)currentRank;
+ (NSString *)prevRank;

+ (int)numberOfKeysForCurrentRank;
+ (int)numberOfHighestScores;

- (void)playButtonClickSound;
- (void)playErrorSound;
- (void)playNewResultSound;
- (void)playNewRankSound;

+ (void)enableNotifications;
+ (void)disableNotifications;

+ (NSString *)categoryByText:(NSString *)text;
+ (int)summaryTimeOfAllTrainings;

@end

