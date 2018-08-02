//
//  KBPanGestureRecognizer.m
//  type.trainer
//
//  Created by Squatch on 28.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "KBPanGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation KBPanGestureRecognizer

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    self.state = UIGestureRecognizerStateBegan;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    self.state = UIGestureRecognizerStateChanged;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
    self.state = UIGestureRecognizerStateEnded;
}

@end
