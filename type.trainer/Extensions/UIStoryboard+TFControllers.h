//
//  UIStoryboard+TFControllers.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

@import UIKit;

#import "TFSettingsVC.h"
#import "TFResultsVC.h"
#import "TFTypingVC.h"

@class MenuVC;

NS_ASSUME_NONNULL_BEGIN

@interface UIStoryboard (TFControllers)

+ (MenuVC *)menuVC;
+ (TFSettingsVC *)settingsVC;
+ (TFTypingVC *)typingVC;
+ (TFResultsVC *)resultsVC;

@end

NS_ASSUME_NONNULL_END
