//
//  TFKeyboardView.m
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFKeyboardView.h"
#import "AppDelegate.h"
#import "KBPanGestureRecognizer.h"

#define kDebugKeyboard 0

@interface TFKeyboardView () <UIGestureRecognizerDelegate>

@property (weak, nonatomic) UILabel *lastTouchedKey;

// popup, всплывающий над нажатой кнопкой клавиатуры
//
@property (nonatomic, strong) UIImageView *letter_popup;
@property (nonatomic, strong) UILabel *popup_label;
@property int popupViewOffsetY;
@property int popupLabelHeight;

@end

@implementation TFKeyboardView

- (void)awakeFromNib {
    [super awakeFromNib];
    
    _popupLabelHeight = 54;
    _popupViewOffsetY = 32;
    
    UIImage *popup_image = [UIImage imageNamed:@"letter_popup.png"];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // BUG (keyboard out of view bounds)
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320]];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:216]];
    }
    if (IS_IPHONE_6) {
        [_backgroundView setImage:[self imageNamed:@"keyboard_background_iphone6.png"]];
        [_spaceButton setBackgroundImage:[self imageNamed:@"space@3x.png"] forState:UIControlStateNormal];
        [_spaceButton setBackgroundImage:[self imageNamed:@"space_sel@3x.png"] forState:UIControlStateHighlighted];
        [_backspaceButton setBackgroundImage:[self imageNamed:@"backspace@3x.png"] forState:UIControlStateNormal];
        [_backspaceButton setBackgroundImage:[self imageNamed:@"backspace_sel@3x.png"] forState:UIControlStateHighlighted];
        [_shiftButton setBackgroundImage:[self imageNamed:@"shift_button@3x.png"] forState:UIControlStateNormal];
        [_shiftButton setBackgroundImage:[self imageNamed:@"shift_button_sel@3x.png"] forState:UIControlStateHighlighted];
        [_shiftButton setBackgroundImage:[self imageNamed:@"shift_button_sel@3x.png"] forState:UIControlStateSelected];
        [_enterButton setBackgroundImage:[self imageNamed:@"corner_button_right@3x.png"] forState:UIControlStateNormal];
        [_enterButton setBackgroundImage:[self imageNamed:@"corner_button_right_sel@3x.png"] forState:UIControlStateHighlighted];
        [_switchButton setBackgroundImage:[self imageNamed:@"corner_button_left@3x.png"] forState:UIControlStateNormal];
        
        [self addConstraint:[NSLayoutConstraint constraintWithItem:_enterButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:93]];
        
        popup_image = [self imageNamed:@"letter_popup_iphone6.png"];
        _popupLabelHeight = 64;
        _popupViewOffsetY = 26;
    }
    else if (IS_IPHONE_6P) {
        _letterHeightConstraint.constant = 56;
        _keysTopMarginConstraint.constant = 3;
        _keysLeftMarginConstraint.constant = 1.75;
        _keysRightMarginConstraint.constant = 1.75;
        _popupViewOffsetY = 30;
        _popupLabelHeight = 64;
        [self layoutIfNeeded];
    }
    
    _letter_popup = [[UIImageView alloc] initWithImage:popup_image];
    _popup_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, _letter_popup.frame.size.width, _popupLabelHeight)];
    _popup_label.textAlignment = NSTextAlignmentCenter;
    [_letter_popup addSubview:_popup_label];
    
    if (&UIFontWeightRegular != nil)
        _popup_label.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
    else // UIFontWeightRegular available from iOS 8.2
        _popup_label.font = [UIFont systemFontOfSize:32];
    
    KBPanGestureRecognizer *panRec = [KBPanGestureRecognizer new];
    panRec.delegate = self;
    [panRec addTarget:self action:@selector(onKeyboardPan:)];
    [self addGestureRecognizer:panRec];
    
    if (kDebugKeyboard) {
        for (UILabel *label in self.subviews) {
            if ([label isKindOfClass:[UILabel class]] == NO) continue;
            label.alpha = 0.6;
            label.clipsToBounds = YES;
            label.backgroundColor = [UIColor yellowColor];
            label.layer.borderColor = [UIColor blackColor].CGColor;
            label.layer.borderWidth = 1;
            label.layer.cornerRadius = 4;
        }
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
       shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:[UIButton class]]) return NO;
    return YES;
}

- (void)onKeyboardPan:(UIPanGestureRecognizer *)recognizer {
    UIView* view = recognizer.view;
    CGPoint location = [recognizer locationInView:view];
    UIView *subview = [view hitTest:location withEvent:nil];
    
    if (recognizer.state == UIGestureRecognizerStateBegan
        || recognizer.state == UIGestureRecognizerStateChanged) {
        if ([subview isKindOfClass:[UILabel class]]) {
            _lastTouchedKey = (UILabel *)subview;
            _popup_label.text = _lastTouchedKey.text;
            
            _letter_popup.center = CGPointMake(_lastTouchedKey.center.x, _lastTouchedKey.center.y-_popupViewOffsetY);
            if (!_letter_popup.superview)
                [self addSubview:_letter_popup];
        }
    }
    else { // pan ended
        [_letter_popup removeFromSuperview];
        if (_lastTouchedKey) {
            if (self.shiftButton.selected) {
                [_delegate onKeyTapped:[_lastTouchedKey.text uppercaseString]];
                self.shiftButton.selected = NO;
            }
            else
                [_delegate onKeyTapped:[_lastTouchedKey.text lowercaseString]];
        }
        _lastTouchedKey = nil;
    }
}

- (UIImage *)imageNamed:(NSString *)name {
    return [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:nil]];
}

// Оставляет на кастомной клавиатуре, только буквы из указанной строки
//
- (void)showOnlyKeysWithCharactersInString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) string = @" ";
    
    NSMutableArray *not_visible = [NSMutableArray new];
    NSMutableArray *visible = [NSMutableArray new];
    
    for (UILabel *label in self.subviews) {
        if (![label isKindOfClass:[UILabel class]]) continue;
        NSRange range = [[string uppercaseString] rangeOfString:[label.text uppercaseString]];
        if (range.location == NSNotFound) { label.hidden = YES; [not_visible addObject:label]; }
        else { label.hidden = NO; [visible addObject:label]; }
    }
    
    int numberOfKeys = [AppDelegate numberOfKeysForCurrentRank];
    if (kDebugKeyboard) numberOfKeys = 31;
    
    if (visible.count < numberOfKeys && ![string isEqualToString:@" "]) {
        int additionalKeys = numberOfKeys - (int)visible.count;
        for (int i=0; i<not_visible.count; i++) {
            int remainingCount = (int)not_visible.count - i;
            int exchangeIndex = i + arc4random_uniform((u_int32_t )remainingCount);
            [not_visible exchangeObjectAtIndex:i withObjectAtIndex:exchangeIndex];
        }
        for (int i=0; i<additionalKeys; i++) {
            UILabel *label = not_visible[i];
            label.hidden = NO;
        }
    }
}

- (void)playClickSound {
    [[UIDevice currentDevice] playInputClick];
}

- (BOOL)enableInputClicksWhenVisible {
    return YES;
}

@end
