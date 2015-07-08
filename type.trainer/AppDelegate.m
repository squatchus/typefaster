//
//  AppDelegate.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:1.0];
    [self initSettings];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initSettings {
    // Update switcher's settings in UserDefaults
    //
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"fullKeyboard"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"])
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"notifications"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"strictTyping"];
    
    // Update button's settings in UserDefaults
    //
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"categoryClassic"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryClassic"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"categoryQuotes"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryQuotes"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"categoryHokku"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryHokku"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"categoryCookies"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryCookies"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)rankTitleBySpeed:(int)speed {
    if (speed < 30) return @"Новичек";              // [0..29]
    else if (speed < 40) return @"Ученик";          // [30..39]
    else if (speed < 55) return @"Освоившийся";     // [40..54]
    else if (speed < 75) return @"Уверенный";       // [55..74]
    else if (speed < 100) return @"Опытный";        // [75..99]
    else if (speed < 130) return @"Бывалый";        // [100..129]
    else if (speed < 165) return @"Продвинутый";    // [130..164]
    else if (speed < 205) return @"Мастер";         // [165..204]
    else if (speed < 250) return @"Гуру";           // [204..249]
    else return @"Запредельный";                    // [250..250+]
}

+ (int)minValueForRank:(NSString *)rankString {
    NSDictionary *maxValues = @{@"Новичек": @0,
                                @"Ученик": @30,
                                @"Освоившийся": @40,
                                @"Уверенный": @55,
                                @"Опытный": @75,
                                @"Бывалый": @100,
                                @"Продвинутый": @130,
                                @"Мастер": @165,
                                @"Гуру": @205,
                                @"Запредельный": @250};
    return [maxValues[rankString] intValue];
}

+ (int)maxValueForRank:(NSString *)rankString {
    NSDictionary *maxValues = @{@"Новичек": @30,
                                @"Ученик": @40,
                                @"Освоившийся": @55,
                                @"Уверенный": @75,
                                @"Опытный": @100,
                                @"Бывалый": @130,
                                @"Продвинутый": @165,
                                @"Мастер": @205,
                                @"Гуру": @250,
                                @"Запредельный": @300};
    return [maxValues[rankString] intValue];
}

+ (NSString *)rankAfterRank:(NSString *)rankString {
    NSArray *ranks = @[@"Новичек", @"Ученик", @"Освоившийся", @"Уверенный", @"Опытный", @"Бывалый", @"Продвинутый", @"Мастер", @"Гуру", @"Запредельный"];
    NSInteger index = [ranks indexOfObject:rankString];
    index++;
    if (index < ranks.count) return ranks[index];
    return nil;
}

+ (float)numberOfStarsBySpeed:(int)speed {
    NSArray *starRatings = @[@0, @0.5, @1, @1.5, @2, @2.5, @3, @3.5, @4, @4.5, @5]; // 11
    NSString *rankString = [self currentRank];
    int maxValue = [self maxValueForRank:rankString];
    float percent = MIN(100, (float)speed * 100.0 / (float)maxValue);
    int index = percent/10;
    float numberOfStars = [starRatings[index] floatValue];
    return numberOfStars;
}

+ (int)bestResult {
    int maxSpeed = 0;
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        int seconds = [result[@"seconds"] intValue];
        int symbols = [result[@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        if (signsPerMin > maxSpeed)
            maxSpeed = signsPerMin;
    }
    return maxSpeed;
}

+ (NSString *)currentRank {
    return [self rankTitleBySpeed:[self bestResult]];
}

+ (int)numberOfKeysForCurrentRank {
    NSDictionary *numberOfKeys = @{ @"Новичек": @0, //@4,
                                    @"Ученик": @5, //@10,
                                    @"Освоившийся": @10, //@16,
                                    @"Уверенный": @17, //@22,
                                    @"Опытный": @25}; //@28 };
    NSNumber* num = numberOfKeys[[self currentRank]];
    if (num) return [num intValue];
    return kAllKeysInKeyboard;
}

@end