//
//  AppDelegate.h
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kAllKeysInKeyboard 31

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

+ (float)numberOfStarsBySpeed:(int)speed;
+ (NSString *)rankTitleBySpeed:(int)speed;

+ (int)minValueForRank:(NSString *)rankString;
+ (int)maxValueForRank:(NSString *)rankString;
+ (NSString *)rankAfterRank:(NSString *)rankString;

+ (int)bestResult;
+ (NSString *)currentRank;
+ (int)numberOfKeysForCurrentRank;

@end

