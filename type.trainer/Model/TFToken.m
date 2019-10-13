//
//  TFToken.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFToken.h"

@implementation TFToken

- (id)initWithString:(NSString *)string startIndex:(int)start endIndex:(int)end {
    if (self = [super init])
    {
        _string = string;
        _startIndex = start;
        _endIndex = end;
        return self;
    }
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%@] (%d, %d)", self.string, self.startIndex, self.endIndex];
}

@end
