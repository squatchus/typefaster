//
//  AppDelegate.h
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

@import UIKit;

#import "TFAppCoordinator.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic, readonly) TFAppCoordinator *coordinator;

@end

NS_ASSUME_NONNULL_END
