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

+ (UIColor *)tf_pink
{
    return [UIColor colorWithHexString:@"FFDEDE"];
}

+ (UIColor *)tf_purple
{
    return [UIColor colorWithHexString:@"A54466"];
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
