//
//  UIColor+TFColors.m
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "UIColor+TFColors.h"

@implementation UIColor (TFColors)

+ (UIColor *)tf_red
{
    return [UIColor colorWithHexString:@"FF3333"];
}

+ (UIColor *)tf_green
{
    return [UIColor colorWithHexString:@"009900"];
}

+ (UIColor *)tf_background_red
{
    return [UIColor colorNamed:@"tf_background_red"];
}

+ (UIColor *)tf_background
{
    return [UIColor colorNamed:@"tf_background"];
}

+ (UIColor *)tf_gray_button
{
    return [UIColor colorNamed:@"tf_gray_button"];
}

+ (UIColor *)tf_purple_button
{
    return [UIColor colorNamed:@"tf_purple_button"];
}

+ (UIColor *)tf_gray_text
{
    return [UIColor colorNamed:@"tf_text"];
}

+ (UIColor *)tf_dark_text
{
    return [UIColor colorNamed:@"tf_dark_text"];
}

+ (UIColor *)tf_purple_text
{
    return [UIColor colorNamed:@"tf_purple_text"];
}

+ (UIColor *)tf_dark
{
    return [UIColor colorWithHexString:@"999999"];
}

+ (UIColor *)tf_light
{
    return [UIColor colorWithHexString:@"C1C1C1"];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    if (!hexString || [hexString isEqual:NSNull.null])
    {
        return nil;
    }
    if (![hexString hasPrefix:@"#"])
    {
        hexString = [@"#" stringByAppendingString:hexString];
    }
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1];
    [scanner scanHexInt:&rgbValue];
    CGFloat red = ((rgbValue & 0xFF0000) >> 16);
    CGFloat green = ((rgbValue & 0xFF00) >> 8);
    CGFloat blue = (rgbValue & 0xFF);
    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}

@end
