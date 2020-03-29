//
//  UIScreen+Extra.m
//  type.trainer
//
//  Created by Sergey Mazulev on 29.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import "UIScreen+Extra.h"

@implementation UIScreen (Extra)

+ (UIFont *)textFontForDevice
{
    int screenHeight = UIScreen.mainScreen.bounds.size.height;
    NSDictionary *fontSizes = @{
        @"896": @(18), // 11, 11 pro max
        @"812": @(17), // 11 pro
        @"736": @(18), // 6+/7+/8+
        @"667": @(17), // 6/7/8
        @"568": @(16), // SE
    };
    NSNumber *sizeNumber = fontSizes[@(screenHeight).stringValue];
    CGFloat size = sizeNumber ? sizeNumber.floatValue : 16.0;
    return [UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular];
}

+ (CGFloat)verticalMarginForDevice
{
    int screenHeight = UIScreen.mainScreen.bounds.size.height;
    NSDictionary *fontSizes = @{
        @"896": @(64), // 11, 11 pro max
        @"812": @(64), // 11 pro
        @"736": @(32), // 6+/7+/8+
        @"667": @(32), // 6/7/8
        @"568": @(0), // SE
    };
    NSNumber *marginNumber = fontSizes[@(screenHeight).stringValue];
    return marginNumber.floatValue;
}

@end
