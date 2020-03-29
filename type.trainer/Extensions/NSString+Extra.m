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

- (BOOL)isSmartEqualToKey:(NSString *)awaitedKey
{
    NSString *typedKey = self;
    if ([awaitedKey isEqualToString:@"ё"] && [typedKey isEqualToString:@"е"])
        return YES;
    if ([awaitedKey isEqualToString:@"Ё"] && [typedKey isEqualToString:@"Е"])
        return YES;
    if ([awaitedKey isEqualToString:@"\n"] && [typedKey isEqualToString:@" "])
        return YES;
    return [typedKey isEqualToString:awaitedKey];
}

- (BOOL)hasSmartPrefix:(NSString *)typedPart
{
    NSString *fullWord = self;
    for (int i=0; i<typedPart.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *typedKey = [typedPart substringWithRange:range];
        NSString *wordKey = [fullWord substringWithRange:range];
        if ([typedKey isSmartEqualToKey:wordKey] == NO) {
            return NO;
        }
    }
    return YES;
}

@end
