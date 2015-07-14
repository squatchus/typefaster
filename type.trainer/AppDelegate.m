//
//  AppDelegate.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "AppDelegate.h"
#import "Flurry.h"
#import "VKSdk.h"
@import AudioToolbox;

@interface AppDelegate ()

@property SystemSoundID errorSound;
@property SystemSoundID buttonClickSound;
@property SystemSoundID newResultSound;
@property SystemSoundID newRankSound;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:1.5];
    [VKSdk initializeWithDelegate:nil andAppId:@"4995337"];
    if ([VKSdk wakeUpSession])
    {
        //Start working
    }
    
    
    [Flurry startSession:@"DXG36J5Z73XT554MZMFD"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]) {
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:idfv forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Flurry setUserID:idfv];
    }
    [self initSettings];
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
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
    BOOL bagesAccess = YES;
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        bagesAccess = (currentSettings.types & UIUserNotificationTypeBadge) != 0;
    }
    if (bagesAccess) application.applicationIconBadgeNumber = 0;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    BOOL bagesAccess = YES;
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        UIUserNotificationSettings *currentSettings = [[UIApplication sharedApplication] currentUserNotificationSettings];
        bagesAccess = (currentSettings.types & UIUserNotificationTypeBadge) != 0;
    }
    if (bagesAccess) application.applicationIconBadgeNumber = 0;}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)initSettings {
    // Update switcher's settings in UserDefaults
    //
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"])
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"fullKeyboard"];
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
    
    CFBundleRef mainBundle = CFBundleGetMainBundle ();
    
    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (mainBundle, CFSTR ("error"), CFSTR ("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &_errorSound);
    
    soundFileURLRef = CFBundleCopyResourceURL (mainBundle, CFSTR ("click"), CFSTR ("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &_buttonClickSound);
    
    soundFileURLRef = CFBundleCopyResourceURL (mainBundle, CFSTR ("new_rank"), CFSTR ("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &_newRankSound);

    soundFileURLRef = CFBundleCopyResourceURL (mainBundle, CFSTR ("new_result"), CFSTR ("wav"), NULL);
    AudioServicesCreateSystemSoundID(soundFileURLRef, &_newResultSound);
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

+ (int)firstResult {
    NSArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    if (results && results.count > 0) {
        int seconds = [[results firstObject][@"seconds"] intValue];
        int symbols = [[results firstObject][@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        return signsPerMin;
    }
    return 0;
}

+ (int)bestResult {
    int maxSpeed = 0;
    NSArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        int seconds = [result[@"seconds"] intValue];
        int symbols = [result[@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        if (signsPerMin > maxSpeed)
            maxSpeed = signsPerMin;
    }
    return maxSpeed;
}

+ (int)prevBestResult {
    int maxSpeed = 0;
    NSArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        if (result == results.lastObject) break;
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

+ (NSString *)prevRank {
    return [self rankTitleBySpeed:[self prevBestResult]];
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

+ (int)numberOfHighestScores {
    int maxSpeed = 0;
    int number = 0;
    NSArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        int seconds = [result[@"seconds"] intValue];
        int symbols = [result[@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        if (signsPerMin > maxSpeed) {
            maxSpeed = signsPerMin; number++;
        }
    }
    return number;
}

- (void)playButtonClickSound {
    AudioServicesPlaySystemSound(_buttonClickSound);
}
- (void)playErrorSound {
    NSLog(@"playErrorSound");
    AudioServicesPlaySystemSound(_errorSound);
}
- (void)playNewResultSound {
    AudioServicesPlaySystemSound(_newResultSound);
}
- (void)playNewRankSound {
    AudioServicesPlaySystemSound(_newRankSound);
}

- (void)dealloc {
    AudioServicesDisposeSystemSoundID(_buttonClickSound);
    AudioServicesDisposeSystemSoundID(_newResultSound);
    AudioServicesDisposeSystemSoundID(_newRankSound);
    AudioServicesDisposeSystemSoundID(_errorSound);
}

+ (void)enableNotifications {
    if (SYSTEM_VERSION_GREATER_THAN(@"8.0")) {
        UIUserNotificationType types = UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert;
        UIUserNotificationSettings *mySettings = [UIUserNotificationSettings settingsForTypes:types categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:mySettings];
    }

    NSDate *tomorrow = [[NSDate date] dateByAddingTimeInterval:86400];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit) fromDate:tomorrow];
    [components setMinute:00];
    [components setHour:20];
    [components setTimeZone:[NSTimeZone defaultTimeZone]];
    NSDate *notificationDate = [calendar dateFromComponents:components];
    
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = notificationDate;
    notification.timeZone = [NSTimeZone defaultTimeZone];
    notification.applicationIconBadgeNumber = 1;
    notification.soundName = UILocalNotificationDefaultSoundName;
    notification.repeatInterval = NSCalendarUnitDay;
    if (SYSTEM_VERSION_GREATER_THAN(@"8.2")) notification.alertTitle = @"Печатай быстрее";
    notification.alertBody = @"Потренеруйтесь в скорости печати!";
    
    // this will schedule the notification to fire at the fire date
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (void)disableNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+ (NSString *)categoryByText:(NSString *)text {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Texts" ofType:@"plist"];
    NSDictionary *levels = [NSDictionary dictionaryWithContentsOfFile:filePath];
    for (NSString *catName in [levels allKeys]) {
        NSArray *catLevels = levels[catName];
        for (NSDictionary *level in catLevels)
            if ([text isEqualToString:level[@"text"]]) return catName;
    }
    return nil;
}

+ (int)summaryTimeOfAllTrainings {
    int seconds = 0;
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        seconds += [result[@"seconds"] intValue];
    }
    return seconds;
}

@end