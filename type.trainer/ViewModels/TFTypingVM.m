//
//  TFTypingVM.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFTypingVM.h"

@import UIKit;

#import "UIColor+TFColors.h"
#import "NSString+Extra.h"
#import "NSMutableString+Extra.h"

#define kBaseFontSize 16
#define kBaseFontName @"HelveticaNeue"

@interface TFTypingVM()

@property (nonatomic, strong) NSString *awaited_key;
@property (nonatomic, strong) NSMutableString *typed_string;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TFTypingVM

- (instancetype)initWithLevel:(TFLevel *)level
                 strictTyping:(BOOL)strictTyping
{
    if (self = [super init])
    {
        _completeTitle = NSLocalizedString(@"typing.vm.complete", nil);
        _level = level;
        _result = [TFSessionResult new];
        _strictTyping = strictTyping;
        _typed_string = [[NSMutableString alloc] initWithString:@""];
        _awaited_key = [self nextAwaitedKey];
    }
    return self;
}

- (void)startSession
{
    self.result.seconds = 0;
    self.result.symbols = 0;
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

- (void)endSession
{
    [_timer invalidate];
    _timer = nil;
    self.onSessionEnded ? self.onSessionEnded() : nil;
}

- (BOOL)shouldEndSession
{
    if (self.typed_string.length == self.level.text.length) {
        BOOL mistakeOnLastChar = [self.awaited_key isEqualToString:@""];
        BOOL strictTypingEnd = (self.strictTyping && !mistakeOnLastChar);
        if (strictTypingEnd || !self.strictTyping) return YES;
    }
    return NO;
}

- (void)updateTimer
{
    self.result.seconds++;
    int min = self.result.seconds/60;
    int sec = self.result.seconds % 60;
    self.onTimerUpdated ? self.onTimerUpdated(min, sec) : nil;
}

- (InputResult)processInput:(NSString *)text
{
    if ([self keyCanBeTyped:text])
    {
        long typedLength = self.typed_string.length;
        BOOL newLineExpceted = [self.level.text newLineAtIndex:typedLength];
        if (newLineExpceted && [text isEqualToString:@" "]) {
            text = @"\n";
        }
        // start session if key was typed for the first time
        if (!self.timer) [self startSession];
        // perform input
        BOOL backspaceTyped = (text && text.length == 0);
        if (backspaceTyped) {
            [self.typed_string deleteLastCharacter];
        } else {
            [self.typed_string appendString:text];
        }
        // update awaited key
        self.awaited_key = [self nextAwaitedKey];
        // check for mistakes
        int prevMistakes = self.result.mistakes;
        [self updateResults];
        BOOL newMistakes = (self.result.mistakes > prevMistakes);
        // end session if needed
        if ([self shouldEndSession]) [self endSession];
        return newMistakes ? InputMistaken : InputCorrect;
    }
    return InputImpossible;
}

- (void)updateResults
{
    BOOL backspaceAwaited = (self.awaited_key && self.awaited_key.length == 0);
    if (self.strictTyping) {
        self.result.symbols = (int)self.typed_string.length;
        if (backspaceAwaited) {
            self.result.mistakes++;
        }
    } else {
        // symbols used to determine typing speed (chars/min)
        // for non-strict typing mode, we count only symbols of correct words
        self.result.symbols = 0;
        int mistakes = 0;
        for (TFToken *token in self.level.tokens) {
            if (token.startIndex >= self.typed_string.length) break;
            int length = MIN((int)self.typed_string.length-token.startIndex, token.endIndex-token.startIndex+1);
            NSRange typedRange = NSMakeRange(token.startIndex, length);
            NSString *typedSubstring = [self.typed_string substringWithRange:typedRange];
            for (int i=0; i<typedSubstring.length; i++) {
                NSString *typedKey = [typedSubstring substringWithRange:NSMakeRange(i, 1)];
                NSString *supposedKey = [token.string substringWithRange:NSMakeRange(i, 1)];
                if ([self key:typedKey isEqualToKey:supposedKey] == NO) mistakes++;
            }
            if ([token.string hasPrefix:typedSubstring]) {
                self.result.symbols += length;
            }
        }
        self.result.mistakes = mistakes;
    }
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

- (BOOL)keyCanBeTyped:(NSString *)keyString
{
    long typedLength = self.typed_string.length;
    
    BOOL backspaceOnStart = (keyString.length == 0 && typedLength == 0);
    BOOL notBackspace = (keyString.length != 0);
    BOOL typedToEnd = (typedLength == self.level.text.length);
    BOOL newLineTyped = [keyString isEqualToString:@"\n"];
    BOOL newLineExpceted = [self.awaited_key isEqualToString:@"\n"];
    BOOL symbolExpected = self.awaited_key.length != 0 && !newLineExpceted;
    BOOL newLineOrSpaceTyped = [@"\n " rangeOfString:keyString].location != NSNotFound;
    // restrictions
    if (backspaceOnStart)
        return NO;
    if (notBackspace && typedToEnd)
        return NO;
    if (newLineTyped && !newLineExpceted)
        return NO;
    if (newLineExpceted && !newLineOrSpaceTyped)
        return NO;
    
    if (self.strictTyping) {
        BOOL matchAwaited = [self key:keyString isEqualToKey:self.awaited_key];
        if (matchAwaited) {
            return YES; // backspace or key match
        } else if (notBackspace && symbolExpected)
            return YES; // type 1 wrong key
        else return NO;
    }
    else {
        return YES;
    }
}

- (NSString *)symbolsEnteredString
{
    return [NSString stringWithFormat:@"%d", self.result.symbols];
}

- (BOOL)shiftHidden
{
    BOOL backspaceAwaited = (self.awaited_key && self.awaited_key.length == 0);
    BOOL hidden = backspaceAwaited || ![self.awaited_key isUppercaseAtIndex:0];
    return hidden;
}

- (BOOL)backspaceHidden
{
    BOOL backspaceAwaited = (self.awaited_key && self.awaited_key.length == 0);
    BOOL hidden = (backspaceAwaited == NO);
    return hidden;
}

// returns 'nil' if text typed to the end
// returns "" if awaited for backspace
// returns next character otherwise
//
- (NSString *)nextAwaitedKey
{
    if (self.typed_string.length == 0) {
        return [self.level.text substringToIndex:1];
    }
    NSString *lastTypedKey = [self.typed_string substringWithRange:NSMakeRange(self.typed_string.length-1, 1)];
    NSString *supposedKey = [self.level.text substringWithRange:NSMakeRange(self.typed_string.length-1, 1)];
    BOOL lastCorrect = [self key:lastTypedKey isEqualToKey:supposedKey];
    BOOL typedToEnd = (self.typed_string.length == self.level.text.length);
    if (lastCorrect) {
        if (typedToEnd) {
            return nil;
        } else {
            NSRange nextKeyRange = NSMakeRange(self.typed_string.length, 1);
            NSString *nextKey = [self.level.text substringWithRange:nextKeyRange];
            return nextKey;
        }
    }
    else return @""; // awaited for backspace
}

- (NSRange)getCursorRange
{
    return NSMakeRange(self.typed_string.length, 0);
}

- (NSAttributedString *)getText
{
    // join result string
    NSString *typed = self.typed_string;
    NSString *trail = [self.level.text substringFromIndex:self.typed_string.length];
    typed = [typed stringByAppendingString:trail];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:typed];
    
    // style for original text
    [text addAttribute:NSFontAttributeName
                 value:self.textViewFont
                 range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColor.tf_gray_text
                 range:NSMakeRange(0, text.length)];
    // style for printed part
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColor.tf_dark_text
                 range:NSMakeRange(0, self.typed_string.length)];
    
    for (int i=0; i<self.typed_string.length; i++)
    {
        NSRange range = NSMakeRange(i, 1);
        NSString *typedLetter = [self.typed_string substringWithRange:range];
        NSString *textLetter = [self.level.text substringWithRange:range];
        if ([typedLetter isEqualToString:textLetter] == NO) {
            [text addAttribute:NSForegroundColorAttributeName value:UIColor.tf_red range:range];
        }
    }
    return text;
}

- (NSAttributedString *)getCurrentWord
{
    BOOL backspaceAwaited = (self.awaited_key && self.awaited_key.length == 0);
    int tokenPosOffset = (backspaceAwaited) ? 1 : 0;
    int tokenPosition = (int)self.typed_string.length - tokenPosOffset;
    TFToken *currentWordToken = [self.level tokenByPosition:tokenPosition];
    if (currentWordToken == nil) {
        currentWordToken = self.level.tokens.lastObject;
    }
    
    NSString *string = currentWordToken.string;
    int length = MIN((int)self.typed_string.length-currentWordToken.startIndex, currentWordToken.endIndex-currentWordToken.startIndex+1);
    NSRange range = NSMakeRange(currentWordToken.startIndex, length);
    NSString *typed = [self.typed_string substringWithRange:range];
    typed = [typed stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    NSString *trail = [string substringFromIndex:typed.length];
    NSString *word = [typed stringByAppendingString:trail];
    if ([word isEqualToString:@" "] || [word isEqualToString:@"\n"]) word = @"\" \"";

    NSMutableAttributedString *currentWord = [[NSMutableAttributedString alloc] initWithString:word];
    [currentWord addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
                        range:NSMakeRange(0, currentWord.length)];
    [currentWord addAttribute:NSForegroundColorAttributeName
                        value:UIColor.tf_dark_text
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
    return currentWord;
}

- (void)dealloc
{
    self.timer.isValid ? [self.timer invalidate] : nil;
}

- (UIFont *)textViewFont
{
    int screenHeight = UIScreen.mainScreen.bounds.size.height;
    NSDictionary *fontSizes = @{
        @"896": @(18), // 11, 11 pro max
        @"812": @(17), // 11 pro
        @"736": @(18), // 6+/7+/8+
        @"667": @(17), // 6/7/8
        @"568": @(16), // SE
    };
    NSNumber *sizeNumber = fontSizes[@(screenHeight).stringValue];
    CGFloat size = sizeNumber ? sizeNumber.floatValue : 16.0;
    return [UIFont monospacedSystemFontOfSize:size weight:UIFontWeightRegular];
}

@end
