//
//  ViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITextFieldDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIImageView *letter_popup;
@property (nonatomic, strong) UILabel *popup_label;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIPanGestureRecognizer *recognizer = [UIPanGestureRecognizer new];
    [recognizer addTarget:self action:@selector(onKeyboardPan:)];
    [_keyboardView addGestureRecognizer:recognizer];

    UIImage *popup_image = [UIImage imageNamed:@"letter_popup"];
    _letter_popup = [[UIImageView alloc] initWithImage:popup_image];
    _popup_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    _popup_label.textAlignment = NSTextAlignmentCenter;
    _popup_label.font = [UIFont systemFontOfSize:32 weight:UIFontWeightMedium];
    _popup_label.text = @"К";
    [_letter_popup addSubview:_popup_label];
}

//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    UIView *view = gestureRecognizer.view;
//    CGPoint location = [gestureRecognizer locationInView:view];
//    UIView *subview = [view hi]
//    
//    return YES;
//}

- (void)onKeyboardPan:(UIPanGestureRecognizer *)recognizer {
    
    UIView* view = recognizer.view;
    CGPoint location = [recognizer locationInView:view];
    UILabel *label = (UILabel *)[view hitTest:location withEvent:nil];
    if ([label isKindOfClass:[UILabel class]]) {
        _popup_label.text = label.text;
        if (recognizer.state == UIGestureRecognizerStateBegan
            || recognizer.state == UIGestureRecognizerStateChanged) {
            _letter_popup.center = CGPointMake(label.center.x, label.center.y-32);
            if (!_letter_popup.superview)
                [_keyboardView addSubview:_letter_popup];
        } // pan ended
        else [_letter_popup removeFromSuperview];
    } // not label
    else [_letter_popup removeFromSuperview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textFieldDidBeginEditing");
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing");
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    return YES;
}

@end
