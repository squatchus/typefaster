//
//  ViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFTypingVC.h"

#import "TFAppDelegate.h"
#import "UIColor+TFColors.h"
#import "NSString+Extra.h"
#import "TFLevel.h"

#define kBaseFontSize 16
#define kBaseFontSizeIPhone6 18
#define kBaseFontSizeIPhone6p 20
#define kBaseFontName @"HelveticaNeue"

#pragma mark - Controller

@interface TFTypingVC () <UITextViewDelegate>

@property (nonatomic, strong, readonly) TFTypingVM *viewModel;

@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UILabel *secondsLabel;
@property (weak, nonatomic) IBOutlet UILabel *statsLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *currentWordLabel;
@property (weak, nonatomic) IBOutlet UIView *shiftView;
@property (weak, nonatomic) IBOutlet UIView *backspaceView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *currentWordBottomMargin;

@property (nonatomic, strong) TFToken *currentToken;
@property (nonatomic, strong) NSTimer *timer;

// Исп-ся только в режиме строгого набора
// Говорит о том, нажатие какой клавиши ожидает приложение
//
@property (nonatomic, strong) NSString *awaited_key;

@property (nonatomic, strong) NSMutableString *typed_string;

@property int textFontSize;

@end

@implementation TFTypingVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    _shiftView.layer.cornerRadius = 4;
    _backspaceView.layer.cornerRadius = 4;
    _textView.scrollEnabled = NO;
    
    _textFontSize = kBaseFontSize;
}

- (void)updateWithViewModel:(TFTypingVM *)viewModel
{
    _viewModel = viewModel;
    
    [self.completeButton setTitle:self.viewModel.completeTitle forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.onViewWillAppear ? self.onViewWillAppear() : nil;
    [self initSession];
    [self.textView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.textView resignFirstResponder];
}

- (void)initSession
{
    self.viewModel.result.symbols = 0;
    self.viewModel.result.mistakes = 0;
    
    _statsLabel.text = @"0";
    _secondsLabel.text = @"0:00";

    [self loadText];
    [self updateCurrentWord];

    if (self.viewModel.strictTyping)
    {
        _awaited_key = [_currentToken.string substringWithRange:NSMakeRange(0, 1)];
    }

    BOOL startsWithLowercase = ([_currentToken.string isUppercaseAtIndex:0] == NO);
    _shiftView.hidden = startsWithLowercase;
    _backspaceView.hidden = YES;
}

- (void)loadText
{
    _currentToken = self.viewModel.level.tokens.firstObject;
    _typed_string = [[NSMutableString alloc] initWithString:@""];

    NSMutableAttributedString *sourceText = [[NSMutableAttributedString alloc] initWithString:self.viewModel.level.text];
    [sourceText addAttribute:NSFontAttributeName
                       value:self.textViewFont
                       range:NSMakeRange(0, sourceText.length)];
    [sourceText addAttribute:NSForegroundColorAttributeName
                       value:UIColor.tf_dark
                       range:NSMakeRange(0, sourceText.length)];
    _textView.attributedText = sourceText;
    _textView.selectedRange = NSMakeRange(0, 0);

    // update TextView Layout
    //
    for (NSLayoutConstraint *c in _textView.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) c.constant = 200;
        if (c.firstAttribute == NSLayoutAttributeWidth) c.constant = 200;
    }
    [self.view layoutIfNeeded];
    CGSize size = CGSizeZero;
    NSString *category = self.viewModel.level.category;
    if ([category rangeOfString:@"Quotes"].location != NSNotFound) {
        size = [_textView sizeThatFits:CGSizeMake(self.view.frame.size.width-64, CGFLOAT_MAX)];
        if (size.height > _textView.frame.size.height)
            size = [_textView sizeThatFits:CGSizeMake(self.view.frame.size.width - 32, CGFLOAT_MAX)];
    }
    else
        size = [_textView sizeThatFits:CGSizeMake(self.view.frame.size.width - 32, CGFLOAT_MAX)];

    for (NSLayoutConstraint *c in _textView.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) c.constant = size.height;
        if (c.firstAttribute == NSLayoutAttributeWidth) c.constant = size.width + 16;
    }
}

- (void)startSession
{
    _secondsLabel.textColor = UIColor.tf_purple;
    self.viewModel.result.seconds = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];    
}

- (void)endSession
{
    _secondsLabel.textColor = UIColor.tf_light;
    [_timer invalidate];
    _timer = nil;
    self.onLevelCompleted ? self.onLevelCompleted(self.viewModel) : nil;
}

#pragma mark - Keyboard Buttons Handling

// Обработчик нажатий на кнопки клавиатуры (с буквой)
//
- (void)onKeyTapped:(NSString *)keyString {
    if (!_timer) [self startSession];
    
    if (_typed_string.length < self.viewModel.level.text.length) {
        unichar character = [self.viewModel.level.text characterAtIndex:_typed_string.length];
        // if next char is '\n'
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character]) {
            BOOL isSpace = [keyString isEqualToString:@" "];
            BOOL isBackspcae = keyString.length == 0;
            BOOL isNewline = [keyString isEqualToString:@"\n"];
            if (isSpace) keyString = @"\n";
            else if (!isNewline && !isBackspcae) keyString = nil;
        }
    }
    
    [self updateTextViewWithKey:keyString]; // also calculate stats
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if (text.length > 1)
    {
        return NO;
    }
    if ([text isEqualToString:@"\n"] == NO)
    {   // if not '\n' - just type
        [self onKeyTapped:text];
    }
    else if (_typed_string.length < self.viewModel.level.text.length)
    {   // if it is '\n'
        unichar character = [self.viewModel.level.text characterAtIndex:_typed_string.length];
        // and it on it's own spot
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character])
        {
            [self onKeyTapped:@"\n"]; // type '\n'
        }
    }

    // prevent from typing '\n' in the middle of the line
    return NO;
}

#pragma mark - Main Logic Is Here

- (NSString *)getAwaitedKey
{
    if (self.viewModel.strictTyping)
    {
        if (_typed_string.length == 0) return [self.viewModel.level.text substringToIndex:1];
        NSString *lastTypedKey = [_typed_string substringWithRange:NSMakeRange(_typed_string.length-1, 1)];
        NSString *supposedKey = [self.viewModel.level.text substringWithRange:NSMakeRange(_typed_string.length-1, 1)];
        BOOL keyMatched = [self key:lastTypedKey isEqualToKey:supposedKey];
        if (keyMatched) {
            if (_typed_string.length == self.viewModel.level.text.length) return nil;
            NSString *nextKey = [self.viewModel.level.text substringWithRange:NSMakeRange(_typed_string.length, 1)];
            return nextKey;
        }
        else return @""; // awaited for backspace
    }
    return nil;
}

// keyString == nil     - can't be typed (not '\n' || ' ', when '\n' expected)
// keyString == @""     - backspace
//
- (void)updateTextViewWithKey:(NSString *)keyString
{
    BOOL canBeTyped = [self keyCanBeTyped:keyString];
    BOOL backspace = (keyString && keyString.length == 0);
    BOOL playErrorSound = NO;
    
    if (canBeTyped) {
        if (backspace) {
            NSRange charPosition = NSMakeRange(_typed_string.length-1, 1);
            [_typed_string deleteCharactersInRange:charPosition];
            self.viewModel.result.symbols--;
        }
        else {
            [_typed_string appendString:keyString];
            self.viewModel.result.symbols++;
        }
    }
    else {
        [self pulseTextViewBackgroundColor];
    }

    // update awaited key (for strictTyping mode)
    _awaited_key = [self getAwaitedKey];
    // update shiftView and backspaceView
    _backspaceView.hidden = YES;
    _shiftView.hidden = YES;
    if (_awaited_key) { // _awaited key exists only in strictTyping mode
        if (_awaited_key.length == 0) { // backspace show if we made a mistake
            _backspaceView.hidden = NO;
            playErrorSound = YES;
            self.viewModel.result.mistakes++;
        }
        else {
            if ([_awaited_key isUppercaseAtIndex:0])
                _shiftView.hidden = NO;
        }
    }
    
    int tokenPosOffset = (_awaited_key && [_awaited_key isEqualToString:@""]) ? 1 : 0;

    int tokenPosition = ((int)_typed_string.length - tokenPosOffset);
    _currentToken = [self.viewModel.level tokenByPosition:tokenPosition];
    if (_currentToken)
    {
        [self updateCurrentWord];
    }
    
    // join result string
    NSString *typed = _typed_string;
    NSString *trail = [self.viewModel.level.text substringFromIndex:_typed_string.length];
    typed = [typed stringByAppendingString:trail];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:typed];
    
    // Базовый стиль текста в textView
    [text addAttribute:NSFontAttributeName
                 value:self.textViewFont
                 range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColor.tf_dark
                 range:NSMakeRange(0, text.length)];
    // Цвет уже напечатанной части текста (черный)
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blackColor]
                 range:NSMakeRange(0, _typed_string.length)];
    
    // Контроль ошибок
    if (self.viewModel.strictTyping) {
        if (_awaited_key && _awaited_key.length == 0) {
            [text addAttribute:NSForegroundColorAttributeName
                         value:UIColor.tf_red
                         range:NSMakeRange(_typed_string.length-1, 1)];
        }
    }
    else {
        self.viewModel.result.symbols = 0;
        int mistakes = 0;
        for (TFToken *token in self.viewModel.level.tokens) {
            if (token.startIndex >= _typed_string.length) break;
            int length = MIN((int)_typed_string.length-token.startIndex, token.endIndex-token.startIndex+1);
            NSRange range = NSMakeRange(token.startIndex, length);
            NSString *typed = [_typed_string substringWithRange:range];
            for (int i=0; i<typed.length; i++) {
                NSString *typedKey = [typed substringWithRange:NSMakeRange(i, 1)];
                NSString *supposedKey = [token.string substringWithRange:NSMakeRange(i, 1)];
                if ([self key:typedKey isEqualToKey:supposedKey] == NO) mistakes++;
            }
            if ([token.string hasPrefix:typed]/* && ![typed isEqualToString:@"\n"]*/)
                self.viewModel.result.symbols+=length;
            else
                [text addAttribute:NSForegroundColorAttributeName
                                    value:UIColor.tf_red
                                    range:NSMakeRange(token.startIndex, length)];
        }
        _shiftView.hidden = YES;
        _backspaceView.hidden = YES;
        if (mistakes > self.viewModel.result.mistakes)
        {   // was a mistake in non strict typing mode
            playErrorSound = YES;
            _backspaceView.hidden = NO;
        }
        else if (_typed_string.length < self.viewModel.level.text.length)
        {
            if ([self.viewModel.level.text isUppercaseAtIndex:_typed_string.length])
                _shiftView.hidden = NO;
        }
        self.viewModel.result.mistakes = mistakes;
    }
    
    _textView.attributedText = text;
    _textView.selectedRange = NSMakeRange(_typed_string.length, 0);
    
    _statsLabel.text = [NSString stringWithFormat:@"%d", self.viewModel.result.symbols];

    if (playErrorSound) {
        self.onMistake ? self.onMistake() : nil;
    }
    
    if (_typed_string.length == self.viewModel.level.text.length) {
        BOOL mistakeOnLastChar = [_awaited_key isEqualToString:@""];
        if (self.viewModel.strictTyping && !mistakeOnLastChar) [self endSession];
        if (!self.viewModel.strictTyping) [self endSession];
    }
}

// Обновляем label с текущим словом, которое находится в процессе набора
//
- (void)updateCurrentWord
{
    NSString *string = _currentToken.string;
    int length = MIN((int)_typed_string.length-_currentToken.startIndex, _currentToken.endIndex-_currentToken.startIndex+1);
    NSRange range = NSMakeRange(_currentToken.startIndex, length);
    NSString *typed = [_typed_string substringWithRange:range];
    typed = [typed stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *trail = [string substringFromIndex:typed.length];
    NSString *word = [typed stringByAppendingString:trail];
    if ([word isEqualToString:@" "] || [word isEqualToString:@"\n"]) word = @"\" \"";
    
    NSMutableAttributedString *currentWord = [[NSMutableAttributedString alloc] initWithString:word];
    [currentWord addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
                        range:NSMakeRange(0, currentWord.length)];
    [currentWord addAttribute:NSForegroundColorAttributeName
                        value:[UIColor blackColor]
                        range:NSMakeRange(0, currentWord.length)];
    [currentWord addAttribute:NSForegroundColorAttributeName
                        value:UIColor.tf_green
                        range:NSMakeRange(0, typed.length)];
    for (int i=0; i<typed.length; i++) {
        NSString *typpedKey = [typed substringWithRange:NSMakeRange(i, 1)];
        NSString *supposedKey = [string substringWithRange:NSMakeRange(i, 1)];
        if ([self key:typpedKey isEqualToKey:supposedKey] == NO) {
            [currentWord addAttribute:NSForegroundColorAttributeName
                                value:UIColor.tf_red
                                range:NSMakeRange(i, 1)];
        }
    }

    _currentWordLabel.attributedText = currentWord;
}

- (BOOL)keyCanBeTyped:(NSString *)keyString
{
    if (!keyString)
        return NO;
    if (keyString.length == 0 && _typed_string.length == 0) // backspace on start
        return NO;
    if (keyString.length != 0 && _typed_string.length == self.viewModel.level.text.length) // level complete
        return NO;
    if (self.viewModel.strictTyping) {
        if ([self key:keyString isEqualToKey:_awaited_key]) // backspace or key match
            return YES;
        else if (keyString.length !=0 && _awaited_key.length != 0 && ![_awaited_key isEqualToString:@"\n"]) // type 1 wrong key
            return YES;
        else return NO;
    }
    else return YES;
}

- (BOOL)key:(NSString *)typedKey isEqualToKey:(NSString *)awaitedKey
{
    if ([awaitedKey isEqualToString:@"ё"] && [typedKey isEqualToString:@"е"])
        return YES;
    if ([awaitedKey isEqualToString:@"Ё"] && [typedKey isEqualToString:@"Е"])
        return YES;
    if ([awaitedKey isEqualToString:@"\n"] && [typedKey isEqualToString:@" "])
        return YES;
    return [typedKey isEqualToString:awaitedKey];
}

#pragma mark - Update User Interface

- (void)updateTimer
{
    self.viewModel.result.seconds++;
    int minutes = self.viewModel.result.seconds/60;
    int seconds = self.viewModel.result.seconds % 60;
    _secondsLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

#pragma mark - Helpers

- (void)dealloc
{
    self.timer.isValid ? [self.timer invalidate] : nil;
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
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameBegin CGRectValue];
    NSTimeInterval duration = [[keyboardInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        self.currentWordBottomMargin.constant = keyboardFrame.size.height;
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:duration animations:^{
        self.currentWordBottomMargin.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)onDoneButtonPressed:(UIButton *)sender
{
    self.onDonePressed ? self.onDonePressed() : nil;
}

#pragma mark - Helpers

- (UIFont *)textViewFont
{
    if (@available(iOS 12.0, *))
    {
        return [UIFont monospacedSystemFontOfSize:kBaseFontSize weight:UIFontWeightRegular];
    }
    else
    {
        return [UIFont fontWithName:kBaseFontName size:kBaseFontSize];
    }
}

@end
