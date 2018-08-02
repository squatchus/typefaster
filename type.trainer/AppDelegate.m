//
//  AppDelegate.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "AppDelegate.h"
#import "MenuViewController.h"
#import "Flurry.h"

@import AudioToolbox;

#import <AVFoundation/AVFoundation.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "Sentry.h"

@import YandexMobileMetrica;
@import YandexMobileMetricaPush;
@import UserNotifications;

@interface AppDelegate ()

@property (nonatomic, strong) AVAudioPlayer *errorPlayer;
@property (nonatomic, strong) AVAudioPlayer *clickPlayer;
@property (nonatomic, strong) AVAudioPlayer *rankPlayer;
@property (nonatomic, strong) AVAudioPlayer *resultPlayer;
@property (nonatomic, strong) AVAudioPlayer *buttonPlayer;

@end

@implementation AppDelegate

+ (void)initialize {
    if ([self class] == [AppDelegate class]) {
        YMMYandexMetricaConfiguration *configuration = [[YMMYandexMetricaConfiguration alloc] initWithApiKey:@"307bb2dc-788c-42b5-b7b3-b32579ae0191"];
        [YMMYandexMetrica activateWithConfiguration:configuration];
    }
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Если до этого шага не была инициализирована библиотека AppMetrica SDK, вызов метода приведет к аварийной остановке приложения.
#ifdef DEBUG
    YMPYandexMetricaPushEnvironment pushEnvironment = YMPYandexMetricaPushEnvironmentDevelopment;
#else
    YMPYandexMetricaPushEnvironment pushEnvironment = YMPYandexMetricaPushEnvironmentProduction;
#endif
    [YMPYandexMetricaPush setDeviceTokenFromData:deviceToken pushEnvironment:pushEnvironment];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [YMPYandexMetricaPush handleRemoteNotification:userInfo];
}

- (void)application:(UIApplication *)application
didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    [YMPYandexMetricaPush handleRemoteNotification:userInfo];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:1.5];
    
    [Fabric with:@[CrashlyticsKit]];

    NSError *error = nil;
    SentryClient *client = [[SentryClient alloc] initWithDsn:@"https://67f93b5f48a945588aefc55d2eebad12@sentry.io/1254794" didFailWithError:&error];
    SentryClient.sharedClient = client;
    [SentryClient.sharedClient startCrashHandlerWithError:&error];
    if (nil != error) {
        NSLog(@"%@", error);
    }
    
//    [Flurry setLogLevel:FlurryLogLevelAll];
//    [Flurry setDebugLogEnabled:YES];
//    [Flurry setEventLoggingEnabled:YES];
//    [Flurry setSessionReportsOnCloseEnabled:YES];
//    [Flurry setSessionReportsOnPauseEnabled:YES];
//    [Flurry setDelegate:self];
//    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"GHWGV2G29YDC9YHTYGZS" withOptions:launchOptions];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"userID"]) {
        NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        [[NSUserDefaults standardUserDefaults] setValue:idfv forKey:@"userID"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [Flurry setUserID:idfv];
    }
    else {
        NSString *idfv = [[NSUserDefaults standardUserDefaults] valueForKey:@"userID"];
        [Flurry setUserID:idfv];
    }
    
    [self initSettings];
    [self authenticateLocalPlayer];
    
    if ([application respondsToSelector:@selector(registerForRemoteNotifications)]) {
        if (NSClassFromString(@"UNUserNotificationCenter") != Nil) {
            [UNUserNotificationCenter currentNotificationCenter].delegate = [YMPYandexMetricaPush userNotificationCenterDelegate];
            
            // iOS 10.0 and above
            UNAuthorizationOptions options =
            UNAuthorizationOptionAlert |
            UNAuthorizationOptionBadge |
            UNAuthorizationOptionSound;
            UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
            [center requestAuthorizationWithOptions:options completionHandler:^(BOOL granted, NSError *error) {
                // Enable or disable features based on authorization.
            }];
        }
        else {
            // iOS 8 and iOS 9
            UIUserNotificationType userNotificationTypes =
            UIUserNotificationTypeAlert |
            UIUserNotificationTypeBadge |
            UIUserNotificationTypeSound;
            UIUserNotificationSettings *settings =
            [UIUserNotificationSettings settingsForTypes:userNotificationTypes categories:nil];
            [application registerUserNotificationSettings:settings];
        }
        [application registerForRemoteNotifications];
    }
    
    [YMPYandexMetricaPush handleApplicationDidFinishLaunchingWithOptions:launchOptions];
    
    return YES;
}

-(void)authenticateLocalPlayer {
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self.window.rootViewController presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    if (error != nil) NSLog(@"%@", [error localizedDescription]);
                    else {
                        _leaderboardIdentifier = leaderboardIdentifier;
                        
                        GKLeaderboard *leaderboardRequest = [[GKLeaderboard alloc] init];
                        leaderboardRequest.identifier = leaderboardIdentifier;
                        if (leaderboardRequest != nil) {
                            [leaderboardRequest loadScoresWithCompletionHandler:^(NSArray *scores, NSError *error){
                                if (error != nil) NSLog(@"%@", [error localizedDescription]);
                                else {
                                    _gameCenterScore = (int)leaderboardRequest.localPlayerScore.value;
                                    [[NSUserDefaults standardUserDefaults] setValue:@(_gameCenterScore) forKey:@"gameCenterScore"];
                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                    [[NSNotificationCenter defaultCenter] postNotificationName:@"bestScoreUpdated" object:nil];
                                }
                            }];
                        }
                        
                        [self reportScore];
                    }
                }];
            }
            else _gameCenterEnabled = NO;
        }
    };
}

-(void)reportScore {
    if (_gameCenterEnabled) {
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
        score.value = [AppDelegate bestResult];
        
        [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"%@", [error localizedDescription]);
            }
        }];
    }
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
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
    // Load game center cached score
    //
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"gameCenterScore"])
        _gameCenterScore = [[[NSUserDefaults standardUserDefaults] valueForKey:@"gameCenterScore"] intValue];
    
    // Update switcher's settings in UserDefaults
    //
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"fullKeyboard"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"])
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"notifications"];
    if (![[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"strictTyping"];
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"] boolValue]) {
        [AppDelegate disableNotifications];
    }
    
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
    
    NSString *toneFilename = [[NSBundle mainBundle] pathForResource:@"Tock" ofType:@"caf"];
    NSURL *toneURLRef = [NSURL fileURLWithPath:toneFilename];
    _clickPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
    _clickPlayer.volume = 0.1;
    [_clickPlayer prepareToPlay];

    toneFilename = [[NSBundle mainBundle] pathForResource:@"error" ofType:@"wav"];
    toneURLRef = [NSURL fileURLWithPath:toneFilename];
    _errorPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
    [_errorPlayer prepareToPlay];
    
    toneFilename = [[NSBundle mainBundle] pathForResource:@"click" ofType:@"wav"];
    toneURLRef = [NSURL fileURLWithPath:toneFilename];
    _buttonPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
    [_buttonPlayer prepareToPlay];

    toneFilename = [[NSBundle mainBundle] pathForResource:@"new_result" ofType:@"wav"];
    toneURLRef = [NSURL fileURLWithPath:toneFilename];
    _resultPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
    [_resultPlayer prepareToPlay];

    toneFilename = [[NSBundle mainBundle] pathForResource:@"new_rank" ofType:@"wav"];
    toneURLRef = [NSURL fileURLWithPath:toneFilename];
    _rankPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL: toneURLRef error: nil];
    [_rankPlayer prepareToPlay];
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
    else if (speed < 300) return @"Запредельный";   // [250..299]
    else return @"Ну очень быстрый";
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
                                @"Запредельный": @250,
                                @"Ну очень быстрый": @350};
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
                                @"Запредельный": @300,
                                @"Ну очень быстрый": @400};
    return [maxValues[rankString] intValue];
}

+ (NSString *)rankAfterRank:(NSString *)rankString {
    NSArray *ranks = @[@"Новичек", @"Ученик", @"Освоившийся", @"Уверенный", @"Опытный", @"Бывалый", @"Продвинутый", @"Мастер", @"Гуру", @"Запредельный", @"Ну очень быстрый"];
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
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return MAX(maxSpeed,delegate.gameCenterScore);
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
    NSDictionary *numberOfKeys = @{ @"Новичек": @0,
                                    @"Ученик": @3,
                                    @"Освоившийся": @7,
                                    @"Уверенный": @15,
                                    @"Опытный": @25};
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

- (void)playKeyboardClickSound {
    if (_clickPlayer.isPlaying)
        _clickPlayer.currentTime = 0;
    else
        [_clickPlayer play];
}

- (void)playButtonClickSound {
    if (_buttonPlayer.isPlaying)
        _buttonPlayer.currentTime = 0;
    else
        [_buttonPlayer play];
}
- (void)playErrorSound {
    if (_errorPlayer.isPlaying)
        _errorPlayer.currentTime = 0;
    else
        [_errorPlayer play];
}
- (void)playNewResultSound {
    if (_resultPlayer.isPlaying)
        _resultPlayer.currentTime = 0;
    else
        [_resultPlayer play];
}
- (void)playNewRankSound {
    if (_rankPlayer.isPlaying)
        _rankPlayer.currentTime = 0;
    else
        [_rankPlayer play];
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
    notification.alertBody = @"Потренируйтесь в скорости печати!";
    
    // this will schedule the notification to fire at the fire date
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

+ (void)disableNotifications {
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

+ (int)summaryTimeOfAllTrainings {
    int seconds = 0;
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        seconds += [result[@"seconds"] intValue];
    }
    return seconds;
}

+ (NSInteger)levelIdentifierByText:(NSString *)text{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    NSArray *allLevels = [NSArray arrayWithContentsOfFile:filePath];
    for (NSInteger i=0; i<allLevels.count; i++) {
        NSDictionary *level = allLevels[i];
        NSString *levelText = level[@"text"];
        if ([levelText isEqualToString:text]) return i;
    }
    return -1;
}

@end
