//
//  ViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFTypingVC.h"

#import "UIColor+TFColors.h"
#import "UINib+TFViews.h"

#pragma mark - Controller

@interface TFTypingVC () <UITextViewDelegate>

@property (nonatomic, strong, readonly) TFTypingVM *viewModel;

@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statsLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (strong, nonatomic) CurrentWordView *currentWord;

@end

@implementation TFTypingVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.currentWord = UINib.currentWordView;
    self.textView.inputAccessoryView = self.currentWord;
    
    // will initiate viewModel update from coordinator
    // cause we need to update text each time VC appears
    self.onViewWillAppear ? self.onViewWillAppear() : nil;
    
    self.statsLabel.text = @"0";
    self.secondsLabel.text = @"0:00";
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)updateWithViewModel:(TFTypingVM *)viewModel
{
    _viewModel = viewModel;
    __weak typeof(self) weakSelf = self;
    _viewModel.onSessionStarted = ^{
        weakSelf.secondsLabel.textColor = UIColor.tf_purple;
    };
    _viewModel.onTimerUpdated = ^(int min, int sec) {
        weakSelf.secondsLabel.text = [NSString stringWithFormat:@"%d:%02d", min, sec];
    };
    _viewModel.onSessionEnded = ^{
        weakSelf.secondsLabel.textColor = UIColor.tf_light;
        weakSelf.onLevelCompleted ? weakSelf.onLevelCompleted(weakSelf.viewModel) : nil;
    };
    [self.completeButton setTitle:self.viewModel.completeTitle forState:UIControlStateNormal];
    [self update];
    [self updateTextViewLayout];
}

- (void)updateTextViewLayout
{
    CGSize size = self.view.frame.size;
    size.width -= 24; // with 12+12 margins
    size.height *= 0.66; // 2/3 of the screen
    for (NSLayoutConstraint *c in _textView.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) c.constant = size.height;
        if (c.firstAttribute == NSLayoutAttributeWidth) c.constant = size.width;
    }
    [self.view layoutIfNeeded];
    
    size = [_textView sizeThatFits:size];

    for (NSLayoutConstraint *c in _textView.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) c.constant = size.height;
        if (c.firstAttribute == NSLayoutAttributeWidth) c.constant = size.width;
    }
    [self.view layoutIfNeeded];
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    // ignore smart keyboard behaviour (like double space / '.')
    if (text.length > 1) return NO;
    // process input
    InputResult result = [self.viewModel processInput:text];
    // show results
    [self update];
    // respond to results
    if (result == InputImpossible) {
        [self pulseTextViewBackgroundColor];
    }
    else if (result == InputMistaken) {
        self.onMistake ? self.onMistake() : nil;
    }
    return NO; // because we called update manually
}

- (void)update
{
    _textView.attributedText = [self.viewModel getText];
    _textView.selectedRange = [self.viewModel getCursorRange];
    _currentWord.label.attributedText = [self.viewModel getCurrentWord];
    _currentWord.backspace.hidden = self.viewModel.backspaceHidden;
    _currentWord.shift.hidden = self.viewModel.shiftHidden;
    _statsLabel.text = self.viewModel.symbolsEnteredString;
}

- (IBAction)onDoneButtonPressed:(UIButton *)sender
{
    self.onDonePressed ? self.onDonePressed() : nil;
}

#pragma mark - Helpers

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)pulseTextViewBackgroundColor
{
    [UIView animateWithDuration:0.15 animations:^{
        self.view.backgroundColor = UIColor.tf_pink;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.view.backgroundColor = [UIColor whiteColor];
        }];
    }];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary* keyboardInfo = notification.userInfo;
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameBegin CGRectValue];
    NSTimeInterval duration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        self.bottomMargin.constant = keyboardFrame.size.height;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        self.bottomMargin.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

@end
