//
//  AppDelegate.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFAppDelegate.h"

@implementation TFAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    _coordinator = [TFAppCoordinator new];
    [self.coordinator start];
    return YES;
}

@end
