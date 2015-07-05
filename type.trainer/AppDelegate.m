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
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"])
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"notifications"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"strictTyping"];
    
    // Update button's settings in UserDefaults
    //
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryClassic"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryClassic"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryQuotes"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryQuotes"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryHokku"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryHokku"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryCookies"])
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"categoryCookies"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
