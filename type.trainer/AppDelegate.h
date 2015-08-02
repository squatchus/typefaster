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


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))
#define SCREEN_MIN_LENGTH (MIN(SCREEN_WIDTH, SCREEN_HEIGHT))

#define IS_IPHONE_4_OR_LESS (IS_IPHONE && SCREEN_MAX_LENGTH < 568.0)
#define IS_IPHONE_5 (IS_IPHONE && SCREEN_MAX_LENGTH == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && SCREEN_MAX_LENGTH == 667.0)
#define IS_IPHONE_6P (IS_IPHONE && SCREEN_MAX_LENGTH == 736.0)


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

+ (NSInteger)levelIdentifierByText:(NSString *)text;

@end

