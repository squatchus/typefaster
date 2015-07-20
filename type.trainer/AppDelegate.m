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
#import "VKSdk.h"
@import AudioToolbox;
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate () <FlurryDelegate>

@property (nonatomic, strong) AVAudioPlayer *errorPlayer;
@property (nonatomic, strong) AVAudioPlayer *clickPlayer;
@property (nonatomic, strong) AVAudioPlayer *rankPlayer;
@property (nonatomic, strong) AVAudioPlayer *resultPlayer;
@property (nonatomic, strong) AVAudioPlayer *buttonPlayer;

//@property SystemSoundID errorSound;
//@property SystemSoundID buttonClickSound;
//@property SystemSoundID newResultSound;
//@property SystemSoundID newRankSound;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [NSThread sleepForTimeInterval:1.5];
    [VKSdk initializeWithDelegate:nil andAppId:@"4995337"];
    if ([VKSdk wakeUpSession])
    {
        //Start working
    }

//    [Flurry setLogLevel:FlurryLogLevelAll];
//    [Flurry setDebugLogEnabled:YES];
//    [Flurry setEventLoggingEnabled:YES];
//    [Flurry setSessionReportsOnCloseEnabled:YES];
//    [Flurry setSessionReportsOnPauseEnabled:YES];
    [Flurry setDelegate:self];
    [Flurry setCrashReportingEnabled:YES];
    [Flurry startSession:@"DXG36J5Z73XT554MZMFD" withOptions:launchOptions];
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
    return YES;
}

- (void)flurrySessionDidCreateWithInfo:(NSDictionary*)info {
    NSLog(@"flurrySessionDidCreateWithInfo: %@", info);
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
    
//    CFBundleRef mainBundle = CFBundleGetMainBundle ();
//    CFURLRef soundFileURLRef  = CFBundleCopyResourceURL (mainBundle, CFSTR ("error"), CFSTR ("wav"), NULL);
//    AudioServicesCreateSystemSoundID(soundFileURLRef, &_errorSound);
//    soundFileURLRef = CFBundleCopyResourceURL (mainBundle, CFSTR ("click"), CFSTR ("wav"), NULL);
//    AudioServicesCreateSystemSoundID(soundFileURLRef, &_buttonClickSound);
//    soundFileURLRef = CFBundleCopyResourceURL (mainBundle, CFSTR ("new_rank"), CFSTR ("wav"), NULL);
//    AudioServicesCreateSystemSoundID(soundFileURLRef, &_newRankSound);
//    soundFileURLRef = CFBundleCopyResourceURL (mainBundle, CFSTR ("new_result"), CFSTR ("wav"), NULL);
//    AudioServicesCreateSystemSoundID(soundFileURLRef, &_newResultSound);
    
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

- (void)playKeyboardClickSound {
    if (_clickPlayer.isPlaying)
        _clickPlayer.currentTime = 0;
    else
        [_clickPlayer play];
}

- (void)playButtonClickSound {
//    AudioServicesPlaySystemSound(_buttonClickSound);
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
//    AudioServicesPlaySystemSound(_newResultSound);
    if (_resultPlayer.isPlaying)
        _resultPlayer.currentTime = 0;
    else
        [_resultPlayer play];
}
- (void)playNewRankSound {
//    AudioServicesPlaySystemSound(_newRankSound);
    if (_rankPlayer.isPlaying)
        _rankPlayer.currentTime = 0;
    else
        [_rankPlayer play];
}

- (void)dealloc {
//    AudioServicesDisposeSystemSoundID(_buttonClickSound);
//    AudioServicesDisposeSystemSoundID(_newResultSound);
//    AudioServicesDisposeSystemSoundID(_newRankSound);
//    AudioServicesDisposeSystemSoundID(_errorSound);
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

@end