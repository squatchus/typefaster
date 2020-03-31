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
#import "UIScreen+Extra.h"

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

- (InputResult)processInput:(NSString *)input range:(NSRange)range
{
    BOOL impossibleOccured = NO;
    BOOL mistakeOccured = NO;
    
    // process backspaces
    NSInteger backspacesNeeded = self.typed_string.length - range.location;
    for (int i=0; i<backspacesNeeded; i++) {
        NSString *backspace = @"";
        InputResult result = [self processKey:backspace];
        if (result == InputResultImpossible) impossibleOccured = YES;
        if (result == InputResultMistaken) mistakeOccured = YES;
    }
    
    // process typed text
    for (int i=0; i<input.length; i++) {
        NSRange range = NSMakeRange(i, 1);
        NSString *key = (input.length > 0) ? [input substringWithRange:range] : input;
        // process input
        InputResult result = [self processKey:key];
        if (result == InputResultImpossible) impossibleOccured = YES;
        if (result == InputResultMistaken) mistakeOccured = YES;
    }
    
    if (impossibleOccured) {
        return InputResultImpossible;
    } else if (mistakeOccured) {
        return InputResultMistaken;
    } else {
        return InputResultCorrect;
    }
}

- (InputResult)processKey:(NSString *)key
{
    if ([self keyCanBeTyped:key])
    {
        long typedLength = self.typed_string.length;
        BOOL newLineExpceted = [self.level.text newLineAtIndex:typedLength];
        if (newLineExpceted && [key isEqualToString:@" "]) {
            key = @"\n";
        }
        // start session if key was typed for the first time
        if (!self.timer) [self startSession];
        // perform input
        BOOL backspaceTyped = (key && key.length == 0);
        if (backspaceTyped) {
            [self.typed_string deleteLastCharacter];
        } else {
            [self.typed_string appendString:key];
        }
        // update awaited key
        self.awaited_key = [self nextAwaitedKey];
        // check for mistakes
        int prevMistakes = self.result.mistakes;
        [self updateResults];
        BOOL newMistakes = (self.result.mistakes > prevMistakes);
        // end session if needed
        if ([self shouldEndSession]) [self endSession];
        return newMistakes ? InputResultMistaken : InputResultCorrect;
    }
    return InputResultImpossible;
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
                if ([typedKey isSmartEqualToKey:supposedKey] == NO) mistakes++;
            }
            if ([token.string hasSmartPrefix:typedSubstring]) {
                self.result.symbols += length;
            }
        }
        self.result.mistakes = mistakes;
    }
}

- (BOOL)keyCanBeTyped:(NSString *)keyString
{
    long typedLength = self.typed_string.length;
    
    BOOL backspace = (keyString.length == 0);
    BOOL backspaceOnStart = (backspace && typedLength == 0);
    BOOL typedToEnd = (typedLength == self.level.text.length);
    BOOL newLineTyped = [keyString isEqualToString:@"\n"];
    BOOL newLineExpceted = [self.awaited_key isEqualToString:@"\n"];
    BOOL symbolExpected = self.awaited_key.length != 0 && !newLineExpceted;
    BOOL newLineOrSpaceTyped = [@"\n " rangeOfString:keyString].location != NSNotFound;
    // restrictions
    if (backspaceOnStart)
        return NO;
    if (!backspace && typedToEnd)
        return NO;
    if (newLineTyped && !newLineExpceted)
        return NO;
    if (newLineExpceted && !newLineOrSpaceTyped)
        return NO;
    
    if (self.strictTyping) {
        if ([keyString isSmartEqualToKey:self.awaited_key]) {
            return YES; // backspace or key match
        } else if (!backspace && symbolExpected) {
            return YES; // type 1 wrong key
        } else {
            return NO;
        }
    }
    else { // non strict typing
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
    BOOL lastCorrect = [lastTypedKey isSmartEqualToKey:supposedKey];
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
                 value:UIScreen.textFontForDevice
                 range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:UIColor.tf_light_text
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
        if ([typedLetter isSmartEqualToKey:textLetter] == NO) {
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
        if ([typpedKey isSmartEqualToKey:supposedKey] == NO) {
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

@end
