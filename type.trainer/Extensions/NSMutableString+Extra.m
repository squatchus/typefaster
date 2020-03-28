//
//  NSMutableString+Extra.m
//  type.trainer
//
//  Created by Sergey Mazulev on 28.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import "NSMutableString+Extra.h"

@implementation NSMutableString (Extra)

- (void)deleteLastCharacter
{
    NSRange range = NSMakeRange(self.length-1, 1);
    [self deleteCharactersInRange:range];
}

@end
