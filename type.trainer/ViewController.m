//
//  ViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "ViewController.h"
#import "KBPanGestureRecognizer.h"
#import "AppDelegate.h"
#import "TFKeyboardView.h"
#import "UIColor+HexColor.h"
#import "Flurry.h"

#define kBaseFontSize 16
#define kBaseFontName @"HelveticaNeue"

#pragma mark - Tokens

@interface Token : NSObject
@property (nonatomic, strong) NSString *string;
@property int startIndex;
@property int endIndex;
- (id)initWithString:(NSString *)string startIndex:(int)start endIndex:(int)end;
@end
@implementation Token
- (id)initWithString:(NSString *)string startIndex:(int)start endIndex:(int)end {
    if (self = [super init]) {
        _string = string;
        _startIndex = start;
        _endIndex = end;
        return self;
    }
    return nil;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"[%@] (%d, %d)", _string, _startIndex, _endIndex];
}
@end



#pragma mark - Controller

@interface ViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) TFKeyboardView *keyboardView;
@property (weak, nonatomic) UILabel *lastTouchedKey;

@property (nonatomic, strong) NSDictionary *current_level;

@property (nonatomic, strong) NSTimer *session_timer;
@property int session_seconds;

@property int stat_symbols;
@property int stat_mistakes;

// popup, всплывающий над нажатой кнопкой клавиатуры
//
@property (nonatomic, strong) UIImageView *letter_popup;
@property (nonatomic, strong) UILabel *popup_label;

// Данные о прогрессе в текущем уровне
@property (nonatomic, strong) NSMutableArray *tokens;
@property (nonatomic, strong) Token *currentToken;

// Исп-ся только в режиме строгого набора
// Говорит о том, нажатие какой клавиши ожидает приложение
//
@property (nonatomic, strong) NSString *awaited_key;

@property (nonatomic, strong) NSArray *text_parts;
@property (nonatomic, strong) NSString *source_string;
@property (nonatomic, strong) NSMutableString *typed_string;
@property NSRange currentWordRange;

@property BOOL useClassic;
@property BOOL useCookies;
@property BOOL useHokku;
@property BOOL useQuotes;

@property BOOL useFullKeyboard;
@property BOOL useStrictTyping;
@property int numberOfKeys;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
    _shiftView.layer.cornerRadius = 4;
    _backspaceView.layer.cornerRadius = 4;
    _textView.scrollEnabled = NO;

    
    // custom keyboard
    _keyboardView = [[NSBundle mainBundle] loadNibNamed:@"TFKeyboardView" owner:self options:nil][0];
    [_keyboardView.shiftButton addTarget:self action:@selector(onShiftPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.backspaceButton addTarget:self action:@selector(onBackspacePressed:)
                            forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.spaceButton addTarget:self action:@selector(onSpacePressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.enterButton addTarget:self action:@selector(onEnterPressed:)
                        forControlEvents:UIControlEventTouchUpInside];

    
    KBPanGestureRecognizer *panRec = [KBPanGestureRecognizer new];
    panRec.delegate = self;
    [panRec addTarget:self action:@selector(onKeyboardPan:)];
    [_keyboardView addGestureRecognizer:panRec];
    
    UIImage *popup_image = [UIImage imageNamed:@"letter_popup"];
    _letter_popup = [[UIImageView alloc] initWithImage:popup_image];
    _popup_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    _popup_label.textAlignment = NSTextAlignmentCenter;
    [_letter_popup addSubview:_popup_label];
    
    if (&UIFontWeightRegular != nil)
        _popup_label.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
    else // UIFontWeightRegular available from iOS 8.2
        _popup_label.font = [UIFont systemFontOfSize:32];
    
//    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) { // BUG (keyboard out of view bounds)
//        [_keyboardView addConstraint:[NSLayoutConstraint constraintWithItem:_keyboardView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:320]];
//        
//        [_keyboardView addConstraint:[NSLayoutConstraint constraintWithItem:_keyboardView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:216]];
//        [_keyboardView layoutIfNeeded];
//    }
}

- (void)viewWillAppear:(BOOL)animated {
    _useClassic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryClassic"] boolValue];
    _useCookies = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryCookies"] boolValue];
    _useHokku = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryHokku"] boolValue];
    _useQuotes = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryQuotes"] boolValue];
    
    _useFullKeyboard = [[[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"] boolValue];
    _useStrictTyping = [[[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"] boolValue];
    _numberOfKeys = [AppDelegate numberOfKeysForCurrentRank];
    [self initSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [_textView becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameBegin CGRectValue];
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self updateCurrentWordBottomMargin:keyboardFrame.size.height withDuration:duration];
}

- (void)updateCurrentWordBottomMargin:(CGFloat)margin withDuration:(NSTimeInterval)duration {
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstItem == self.bottomLayoutGuide) {
            CGFloat height = margin;
            constraint.constant = height;
            break;
        }
    }
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)initSession {
    _stat_symbols = 0;
    _stat_mistakes = 0;
    [self updateStatsLabel];
    
    _secondsLabel.text = [NSString stringWithFormat:@"%d:%02d", 0, 0];

    [self loadText];
    [self updateCurrentWord];
    [self showOnlyKeysWithCharactersInString:_currentToken.string];
    if (_useStrictTyping)
        _awaited_key = [_currentToken.string substringWithRange:NSMakeRange(0, 1)];

    unichar character = [_currentToken.string characterAtIndex:0];
    if ([[self cyrillicUppercase] characterIsMember:character]) _shiftView.hidden = NO;

    if (_useFullKeyboard)
        _textView.inputView = nil;
    else
        _textView.inputView = _keyboardView;
}

- (void)loadText {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Texts" ofType:@"plist"];
    NSDictionary *texts = [NSDictionary dictionaryWithContentsOfFile:filePath];
    NSMutableArray *allTexts = [NSMutableArray new];
    if (_useClassic) [allTexts addObjectsFromArray:texts[@"categoryClassic"]];
    if (_useCookies) [allTexts addObjectsFromArray:texts[@"categoryCookies"]];
    if (_useQuotes) [allTexts addObjectsFromArray:texts[@"categoryQuotes"]];
    if (_useHokku) [allTexts addObjectsFromArray:texts[@"categoryHokku"]];
    
    int level_num = arc4random()%allTexts.count;
    _current_level = allTexts[level_num];
    _source_string = allTexts[level_num][@"text"];
    _typed_string = [[NSMutableString alloc] initWithString:@""];
    if (!_useFullKeyboard) {
        NSCharacterSet *symbols = [NSCharacterSet punctuationCharacterSet];
        NSArray *components = [_source_string componentsSeparatedByCharactersInSet:symbols];
        _source_string = [components componentsJoinedByString:@""];
    }

//    int numberOfLines = 8;
//    if ([[UIScreen mainScreen] bounds].size.height == 480) numberOfLines = 4;
//    NSCharacterSet *newlines = [NSCharacterSet newlineCharacterSet];
//    NSArray *lines = [_source_string componentsSeparatedByCharactersInSet:newlines];
//    NSMutableArray *firstLines = [NSMutableArray arrayWithArray:lines];
//    [firstLines removeObjectsInRange:NSMakeRange(4, firstLines.count-4)];
//    _source_string = [firstLines componentsJoinedByString:@"\n"];
    
    [self buildTokensFromString:_source_string];
    
//    current_level
    NSMutableAttributedString *sourceText = [[NSMutableAttributedString alloc] initWithString:_source_string];
    [sourceText addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:kBaseFontName size:kBaseFontSize]//@"HelveticaNeue" size:kBaseFontSize]
                       range:NSMakeRange(0, sourceText.length)];
    [sourceText addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithHexString:@"999999"]
                       range:NSMakeRange(0, sourceText.length)];
    _textView.attributedText = sourceText;
    _textView.selectedRange = NSMakeRange(0, 0);

    [self.view layoutIfNeeded];
    CGSize size = [_textView sizeThatFits:CGSizeMake(self.view.frame.size.width-32, CGFLOAT_MAX)];
    for (NSLayoutConstraint *c in _textView.constraints) {
        if (c.firstAttribute == NSLayoutAttributeHeight) {
            c.constant = size.height;
        }
        if (c.firstAttribute == NSLayoutAttributeWidth) {
            c.constant = size.width + 16;
        }
    }
}

- (void)buildTokensFromString:(NSString *)string {
    _tokens = [NSMutableArray new];
    NSString *curTokenString = @"";
    int curTokenStart=-1, curTokenEnd=-1;
    NSCharacterSet *letters = [self cyrillicLetters];
    for (int i=0; i<_source_string.length; i++) {
        unichar c = [_source_string characterAtIndex:i];
        NSString *cString = [NSString stringWithCharacters:&c length:1];
        if ([letters characterIsMember:c]) {
            if (curTokenString.length == 0) curTokenStart = i;
            curTokenString = [NSString stringWithFormat:@"%@%@", curTokenString, cString];
        }
        else {
            if (curTokenString.length > 0) {
                curTokenEnd = i-1;
                Token *token = [[Token alloc] initWithString:curTokenString startIndex:curTokenStart endIndex:curTokenEnd];
                [_tokens addObject:token];
                curTokenString = @"";
            }
            Token *token = [[Token alloc] initWithString:cString startIndex:i endIndex:i];
            [_tokens addObject:token];
        }
    }
    if (curTokenString.length > 0) {
        curTokenEnd = (int)string.length-1;
        Token *token = [[Token alloc] initWithString:curTokenString startIndex:curTokenStart endIndex:curTokenEnd];
        [_tokens addObject:token];
    }
    
    _currentToken = _tokens.firstObject;
}

- (void)startSession {
    _secondsLabel.textColor = [UIColor colorWithHexString:@"A54466"];
    _session_seconds = 0;
    _session_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];

    NSDictionary *params = @{@"author": _current_level[@"author"],
                             @"text": _current_level[@"text"],
                             @"category": [AppDelegate categoryByText:_current_level[@"text"]],
                             @"rankAtStart": [AppDelegate currentRank] };
    
    [Flurry logEvent:@"TrainingSession started" withParameters:params timed:YES];
}

- (void)endSession {
    [_textView resignFirstResponder];
    
    _secondsLabel.textColor = [UIColor colorWithHexString:@"CCCCCC"];
    [_session_timer invalidate];
    _session_timer = nil;
    
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstItem == self.bottomLayoutGuide) {
            constraint.constant = 0;
            break;
        }
    }
    
    // save results and show results controller
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    if (!results) results = [NSMutableArray new];
    else results = [NSMutableArray arrayWithArray:results]; // for mutability
    [results addObject:@{@"level": _current_level,
                         @"seconds": @(_session_seconds),
                         @"symbols": @(_stat_symbols),
                         @"mistakes": @(_stat_mistakes)}];
    [[NSUserDefaults standardUserDefaults] setValue:results forKey:@"results"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"showResultsVC" sender:self];
    NSDictionary *params = @{@"seconds": @(_session_seconds), @"symbols":@(_stat_symbols), @"mistakes":@(_stat_mistakes)};
    [Flurry endTimedEvent:@"TrainingSession started" withParameters:params];
}

#pragma mark - Keyboard Buttons Handling

// Обработчик нажатий на кнопки клавиатуры (с буквой)
//
- (void)onKeyTapped:(NSString *)keyString {
    if (!_session_timer) [self startSession];
    [_keyboardView playClickSound];
    
    if (_typed_string.length < _source_string.length) {
        unichar character = [_source_string characterAtIndex:_typed_string.length];
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

// Нажатие небуквенных кнопок на базовой клавиатуре
//
- (void)onBackspacePressed:(UIButton *)sender {
    [self onKeyTapped:@""];
}

- (void)onShiftPressed:(UIButton *)sender {
    [_keyboardView playClickSound];
    sender.selected = !sender.selected;
}

- (void)onSpacePressed:(UIButton *)sender {
    [self onKeyTapped:@" "];
}

- (void)onEnterPressed:(UIButton *)sender {
    if (_typed_string.length < _source_string.length) {
        unichar character = [_source_string characterAtIndex:_typed_string.length];
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character]) [self onKeyTapped:@"\n"];
        else [_keyboardView playClickSound];
    }
    else [_keyboardView playClickSound];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"] == NO) // if not '\n' - just type
        [self onKeyTapped:text];
    else if (_typed_string.length < _source_string.length) { // if it is '\n'
        unichar character = [_source_string characterAtIndex:_typed_string.length];
        // and it on it's own spot
        if ([[NSCharacterSet newlineCharacterSet] characterIsMember:character])
            [self onKeyTapped:@"\n"]; // type '\n'
    }
    else [_keyboardView playClickSound]; // prevent from typing '\n' in the middle of the line
    return NO;
}

#pragma mark - Main Logic Is Here

- (NSString *)getAwaitedKey {
    if (_useStrictTyping) {
        if (_typed_string.length == 0) return [_source_string substringToIndex:1];
        NSString *lastTypedKey = [_typed_string substringWithRange:NSMakeRange(_typed_string.length-1, 1)];
        NSString *supposedKey = [_source_string substringWithRange:NSMakeRange(_typed_string.length-1, 1)];
//        if ([lastTypedKey isEqualToString:@"\n"])
//            lastTypedKey = [_typed_string substringWithRange:NSMakeRange(_typed_string.length-2, 1)];
//        if ([supposedKey isEqualToString:@"\n"])
//            supposedKey = [_source_string substringWithRange:NSMakeRange(_typed_string.length-2, 1)];
        BOOL keyMatched = [self key:lastTypedKey isEqualToKey:supposedKey];
        if (keyMatched) {
            if (_typed_string.length == _source_string.length) return nil;
            NSString *nextKey = [_source_string substringWithRange:NSMakeRange(_typed_string.length, 1)];
//            if ([nextKey isEqualToString:@"\n"])
//                nextKey = [_source_string substringWithRange:NSMakeRange(_typed_string.length+1, 1)];
            return nextKey;
        }
        else return @""; // awaited for backspace
    }
    return nil;
}


// keyString == nil     - can't be typed (not '\n' || ' ', when '\n' expected)
// keyString == @""     - backspace
//
- (void)updateTextViewWithKey:(NSString *)keyString {
    BOOL canBeTyped = [self keyCanBeTyped:keyString];
    BOOL backspace = (keyString && keyString.length == 0);
    
    if (canBeTyped) {
        if (backspace) {
            NSRange charPosition;
            // если курсор в начале строки
//            if ([_typed_string hasSuffix:@"\n"]) // удаляем 2 символа: '\n' + посл. букву прошлой строки
//                charPosition = NSMakeRange(_typed_string.length-2, 2);
//            else // если курсор после буквы, удаляем только саму букву
                charPosition = NSMakeRange(_typed_string.length-1, 1);
            [_typed_string deleteCharactersInRange:charPosition];
            _stat_symbols--;
        }
        else {
            [_typed_string appendString:keyString];
//            // если после буквы должен быть перенос
//            if ([[_source_string substringFromIndex:_typed_string.length] hasPrefix:@"\n"])
//                [_typed_string appendString:@"\n"];
            _stat_symbols++;
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
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playErrorSound];
            _stat_mistakes++;
        }
        else {
            unichar character = [_awaited_key characterAtIndex:0];
            if ([[self cyrillicUppercase] characterIsMember:character]) _shiftView.hidden = NO;
        }
    }
    
    int tokenPosOffset = (_awaited_key && [_awaited_key isEqualToString:@""]) ? 1 : 0;
//    if (tokenPosOffset == 1) {
//        NSString *prev = [_typed_string substringFromIndex:_typed_string.length-1];
//        if ([prev isEqualToString:@"\n"]) tokenPosOffset = 2;
//    }
    Token *prevToken = _currentToken;
    _currentToken = [self tokenByPosition:((int)_typed_string.length - tokenPosOffset)];
    if (_currentToken) {
        [self updateCurrentWord];
        if (_useFullKeyboard == NO && prevToken != _currentToken)
            [self showOnlyKeysWithCharactersInString:_currentToken.string];
    }
    
    // join result string
    NSString *typed = _typed_string;
    NSString *trail = [_source_string substringFromIndex:_typed_string.length];
    typed = [typed stringByAppendingString:trail];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:typed];
    
    // Базовый стиль текста в textView
    [text addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:kBaseFontName size:kBaseFontSize]//@"HelveticaNeue" size:kBaseFontSize]
                 range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:@"999999"] // gray
                 range:NSMakeRange(0, text.length)];
    // Цвет уже напечатанной части текста (черный)
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blackColor]
                 range:NSMakeRange(0, _typed_string.length)];
    
    
    if (_useStrictTyping == NO) {
        _stat_symbols = 0;
        int mistakes = 0;
        for (Token *token in _tokens) {
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
                _stat_symbols+=length;
            else
                [text addAttribute:NSForegroundColorAttributeName
                                    value:[UIColor colorWithHexString:@"FF3333"] // red
                                    range:NSMakeRange(token.startIndex, length)];
        }
        _shiftView.hidden = YES;
        _backspaceView.hidden = YES;
        if (mistakes > _stat_mistakes) { // was a mistake in non strict typing mode
            [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playErrorSound];
            _backspaceView.hidden = NO;
        }
        else if (_typed_string.length < _source_string.length) {
            unichar character = [_source_string characterAtIndex:_typed_string.length];
            if ([[self cyrillicUppercase] characterIsMember:character]) _shiftView.hidden = NO;
        }
        _stat_mistakes = mistakes;
    }
    
    _textView.attributedText = text;
    _textView.selectedRange = NSMakeRange(_typed_string.length, 0);
    
    [self updateStatsLabel];
    
    if (_typed_string.length == _source_string.length) {
        BOOL mistakeOnLastChar = [_awaited_key isEqualToString:@""];
        if (_useStrictTyping && !mistakeOnLastChar) [self endSession];
        if (!_useStrictTyping) [self endSession];
    }
}

// Обновляем label с текущим словом, которое находится в процессе набора
//
- (void)updateCurrentWord {
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
                        value:[UIColor colorWithHexString:@"009900"] // green
                        range:NSMakeRange(0, typed.length)];
    for (int i=0; i<typed.length; i++) {
        NSString *typpedKey = [typed substringWithRange:NSMakeRange(i, 1)];
        NSString *supposedKey = [string substringWithRange:NSMakeRange(i, 1)];
        if ([self key:typpedKey isEqualToKey:supposedKey] == NO) {
            [currentWord addAttribute:NSForegroundColorAttributeName
                                value:[UIColor colorWithHexString:@"FF3333"] // red
                                range:NSMakeRange(i, 1)];
        }
    }

    _currentWordLabel.attributedText = currentWord;
}

- (BOOL)keyCanBeTyped:(NSString *)keyString {
    if (!keyString)
        return NO;
    if (keyString.length == 0 && _typed_string.length == 0) // backspace on start
        return NO;
    if (keyString.length != 0 && _typed_string.length == _source_string.length) // level complete
        return NO;
    if (_useStrictTyping) {
        if ([self key:keyString isEqualToKey:_awaited_key]) // backspace or key match
            return YES;
        else if (keyString.length !=0 && _awaited_key.length != 0 && ![_awaited_key isEqualToString:@"\n"]) // type 1 wrong key
            return YES;
        else return NO;
    }
    else return YES;
}

- (BOOL)key:(NSString *)typedKey isEqualToKey:(NSString *)awaitedKey {
    if ([awaitedKey isEqualToString:@"ё"] && [typedKey isEqualToString:@"е"])
        return YES;
    if ([awaitedKey isEqualToString:@"Ё"] && [typedKey isEqualToString:@"Е"])
        return YES;
    if ([awaitedKey isEqualToString:@"\n"] && [typedKey isEqualToString:@" "])
        return YES;
    return [typedKey isEqualToString:awaitedKey];
}

#pragma mark - Update User Interface

// Оставляет на кастомной клавиатуре, только буквы из указанной строки
//
- (void)showOnlyKeysWithCharactersInString:(NSString *)string {
    if ([string isEqualToString:@"\n"]) string = @" ";
    
    NSMutableArray *not_visible = [NSMutableArray new];
    NSMutableArray *visible = [NSMutableArray new];
    
    for (UILabel *label in _keyboardView.subviews) {
        if (![label isKindOfClass:[UILabel class]]) continue;
        NSRange range = [[string uppercaseString] rangeOfString:[label.text uppercaseString]];
        if (range.location == NSNotFound) { label.hidden = YES; [not_visible addObject:label]; }
        else { label.hidden = NO; [visible addObject:label]; }
    }
    
    if (visible.count < _numberOfKeys && ![string isEqualToString:@" "]) {
        int additionalKeys = _numberOfKeys - (int)visible.count;
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

// Обновляем данные о количестве набранных символов и совершенных ошибках
//
- (void)updateStatsLabel {
    NSString *statString = [NSString stringWithFormat:@"%d/%d", _stat_symbols, _stat_mistakes];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:statString];
    NSInteger sep_loc = [statString rangeOfString:@"/"].location;
    NSInteger length = [statString substringFromIndex:sep_loc].length;
    [text addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:21]
                   range:NSMakeRange(0, sep_loc)];
    [text addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithHexString:@"A54466"]
                       range:NSMakeRange(0, sep_loc)];
    [text addAttribute:NSFontAttributeName
                   value:[UIFont fontWithName:@"HelveticaNeue-Medium" size:16]
                   range:NSMakeRange(sep_loc, length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:@"CCCCCC"]
                 range:NSMakeRange(sep_loc, length)];
    _statsLabel.attributedText = text;
}

// Обновляем показатель таймера
//
- (void)updateTimer {
    _session_seconds++;
    int minutes = _session_seconds/60;
    int seconds = _session_seconds % 60;
    _secondsLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

#pragma mark - Helpers

- (void)dealloc {
    if (_session_timer) [_session_timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
}

- (NSCharacterSet *)cyrillicLowercase {
    NSString *string = @"абвгдеёжзийклмнопрстуфхцчшщьыъэюя";
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:string];
    return set;
}

- (NSCharacterSet *)cyrillicUppercase {
    NSString *string = [@"абвгдеёжзийклмнопрстуфхцчшщьыъэюя" uppercaseString];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:string];
    return set;
}

- (NSCharacterSet *)cyrillicLetters {
    NSString *string = @"абвгдеёжзийклмнопрстуфхцчшщьыъэюя";
    string = [string stringByAppendingString:[string uppercaseString]];
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:string];
    return set;
}

- (NSCharacterSet *)canBeTyped {
    if (_textView.inputView == _keyboardView) { // custom keyboard
        NSString *string = @"абвгдеёжзийклмнопрстуфхцчшщьыъэюя";
        string = [string stringByAppendingString:[string uppercaseString]];
        string = [string stringByAppendingString:@" \n"];
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:string];
        return set;
    }
    else { // apple keyboard
        NSString *string = @"";
        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:string];
        return [set invertedSet]; // all possible characters
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

            _letter_popup.center = CGPointMake(_lastTouchedKey.center.x, _lastTouchedKey.center.y-32);
            if (!_letter_popup.superview)
                [_keyboardView addSubview:_letter_popup];
        }
    }
    else { // pan ended
        [_letter_popup removeFromSuperview];
        if (_lastTouchedKey) {
            if (_keyboardView.shiftButton.selected) {
                [self onKeyTapped:[_lastTouchedKey.text uppercaseString]];
                _keyboardView.shiftButton.selected = NO;
            }
            else
                [self onKeyTapped:[_lastTouchedKey.text lowercaseString]];
        }
        _lastTouchedKey = nil;
    }
}

- (void)pulseTextViewBackgroundColor {
    [UIView animateWithDuration:0.15 animations:^{
        self.view.backgroundColor = [UIColor colorWithHexString:@"ffdede"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.view.backgroundColor = [UIColor whiteColor];
        }];
    }];
}

- (IBAction)onDoneButtonPressed:(UIButton *)sender {
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (Token *)tokenByPosition:(int)position {
    for (Token *t in _tokens) {
        if (position >= t.startIndex && position <= t.endIndex) return t;
    }
    return nil;
}

@end