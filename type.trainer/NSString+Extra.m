//
//  NSString+Extra.m
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "NSString+Extra.h"

@implementation NSString (Extra)

- (BOOL)isUppercaseAtIndex:(NSUInteger)index
{
    NSString *one = [self substringWithRange:NSMakeRange(index, 1)];
    if (one.length > 0)
    {
        unichar c = [one characterAtIndex:0];
        BOOL isSymbol = [NSCharacterSet.symbolCharacterSet characterIsMember:c];
        BOOL isUppercase = [one isEqualToString:one.uppercaseString];
        return isSymbol && isUppercase;
    }
    return NO;
}

@end
