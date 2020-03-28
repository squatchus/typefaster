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
        BOOL isLetter = [NSCharacterSet.letterCharacterSet characterIsMember:c];
        BOOL isUppercase = [one isEqualToString:one.uppercaseString];
        return isLetter && isUppercase;
    }
    return NO;
}

- (BOOL)newLineAtIndex:(NSUInteger)index
{
    if (index < self.length) {
        unichar c = [self characterAtIndex:index];
        BOOL newLine = [NSCharacterSet.newlineCharacterSet characterIsMember:c];
        return newLine;
    }
    return NO;
}

- (NSString *)trimmedSpacesAndNewlines
{
    NSCharacterSet *set = NSCharacterSet.whitespaceAndNewlineCharacterSet;
    NSString *result = [self stringByTrimmingCharactersInSet:set];
    return result;
}

@end
