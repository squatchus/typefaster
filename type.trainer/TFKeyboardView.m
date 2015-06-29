//
//  TFKeyboardView.m
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFKeyboardView.h"

@implementation TFKeyboardView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)playClickSound {
    [[UIDevice currentDevice] playInputClick];
}

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
