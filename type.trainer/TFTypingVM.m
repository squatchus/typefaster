//
//  TFTypingVM.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFTypingVM.h"

@implementation TFTypingVM

- (instancetype)initWithLevel:(TFLevel *)level
                 strictTyping:(BOOL)strictTyping
{
    if (self = [super init])
    {
        _level = level;
        _result = [TFSessionResult new];
        _strictTyping = strictTyping;
    }
    return self;
}

@end
