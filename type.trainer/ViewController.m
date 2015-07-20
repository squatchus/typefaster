//
//  ViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "TFKeyboardView.h"
#import "UIColor+HexColor.h"
#import "Flurry.h"

#define kBaseFontSize 16
#define kBaseFontSizeIPhone6 18
#define kBaseFontSizeIPhone6p 20
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

@interface ViewController () <UITextViewDelegate, TFKeyboardDelegate>

@property (strong, nonatomic) TFKeyboardView *keyboardView;

@property (nonatomic, strong) NSDictionary *current_level;

@property (nonatomic, strong) NSTimer *session_timer;
@property int session_seconds;

@property int stat_symbols;
@property int stat_mistakes;

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

@property int textFontSize;

@property int wordTaps;
@property int backspaceTaps;
@property int shiftTaps;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

    
    _shiftView.layer.cornerRadius = 4;
    _backspaceView.layer.cornerRadius = 4;
    _textView.scrollEnabled = NO;

    
    // custom keyboard
    _keyboardView = [[NSBundle mainBundle] loadNibNamed:@"TFKeyboardView" owner:self options:nil][0];
    _keyboardView.delegate = self;
    
    [_keyboardView.shiftButton addTarget:self action:@selector(onShiftPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.backspaceButton addTarget:self action:@selector(onBackspacePressed:)
                            forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.spaceButton addTarget:self action:@selector(onSpacePressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.enterButton addTarget:self action:@selector(onEnterPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    UITapGestureRecognizer *tapRecShift = [[UITapGestureRecognizer alloc]
                                           initWithTarget:self action:@selector(shiftViewTapped)];
    UITapGestureRecognizer *tapRecBackspace = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(backspaceViewTapped)];
    UITapGestureRecognizer *tapRecCurrentWord = [[UITapGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(currentWordLabelTapped)];
    [_shiftView addGestureRecognizer:tapRecShift];
    [_backspaceView addGestureRecognizer:tapRecBackspace];
    [_currentWordLabel addGestureRecognizer:tapRecCurrentWord];
}

- (void)shiftViewTapped {
    _shiftTaps++;
}

- (void)backspaceViewTapped {
    _backspaceTaps++;
}

- (void)currentWordLabelTapped {
    _wordTaps++;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    _useClassic = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryClassic"] boolValue];
    _useCookies = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryCookies"] boolValue];
    _useHokku = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryHokku"] boolValue];
    _useQuotes = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryQuotes"] boolValue];
    
    _useFullKeyboard = [[[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"] boolValue];
    _useStrictTyping = [[[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"] boolValue];
    
    if (IS_IPHONE_6P) _textFontSize = kBaseFontSizeIPhone6p;
    else if (IS_IPHONE_6) _textFontSize = kBaseFontSizeIPhone6;
    else _textFontSize = kBaseFontSize;
    
    [self initSession];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [_textView becomeFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary* keyboardInfo = [notification userInfo];
    NSValue* keyboardFrameBegin = [keyboardInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = [keyboardFrameBegin CGRectValue];
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self updateCurrentWordBottomMargin:keyboardFrame.size.height withDuration:duration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSTimeInterval duration = [[[notification userInfo] valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    [self updateCurrentWordBottomMargin:0 withDuration:duration];
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
    _wordTaps = 0;
    _backspaceTaps = 0;
    _shiftTaps = 0;
    
    _stat_symbols = 0;
    _stat_mistakes = 0;
    _statsLabel.text = [NSString stringWithFormat:@"%d", _stat_symbols];
    
    _secondsLabel.text = [NSString stringWithFormat:@"%d:%02d", 0, 0];

    [self loadText];
    [self updateCurrentWord];
    [_keyboardView showOnlyKeysWithCharactersInString:_currentToken.string];
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
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Levels" ofType:@"plist"];
    NSMutableArray *allLevels = [[NSArray arrayWithContentsOfFile:filePath] mutableCopy];
    NSMutableArray *allowedLevels = [NSMutableArray new];
    
    NSMutableArray *disabledCategories = [NSMutableArray new];
    if (!_useClassic) [disabledCategories addObject:@"categoryClassic"];
    if (!_useCookies) [disabledCategories addObject:@"categoryCookies"];
    if (!_useQuotes) [disabledCategories addObject:@"categoryQuotes"];
    if (!_useHokku) [disabledCategories addObject:@"categoryHokku"];
    for (NSDictionary *level in allLevels) {
        BOOL allowed = YES;
        for (NSString *disabled in disabledCategories)
            if ([level[@"category"] isEqualToString:disabled]) {
                allowed = NO;
                break;
            }
        if (allowed || disabledCategories.count == 4)
            [allowedLevels addObject:level];
    }
    
    int level_num = 0;
    NSNumber *prev_num = [[NSUserDefaults standardUserDefaults] valueForKey:@"prevLevel"];
    if (prev_num) {
        int new_num = [prev_num intValue]+1;
        if (new_num < allowedLevels.count) {
            level_num = new_num;
        }
    }
    [[NSUserDefaults standardUserDefaults] setValue:@(level_num) forKey:@"prevLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"LEVEL LOADED: %d/%d (%@)", level_num, (int)allowedLevels.count, allowedLevels[level_num][@"category"]);
    
    _current_level = allowedLevels[level_num];
    _source_string = allowedLevels[level_num][@"text"];
    _typed_string = [[NSMutableString alloc] initWithString:@""];
    if (!_useFullKeyboard) {
        _source_string = [_source_string stringByReplacingOccurrencesOfString:@"как-нибудь"
                                                                   withString:@"как нибудь"];
        _source_string = [_source_string stringByReplacingOccurrencesOfString:@"по-настоящему"
                                                                   withString:@"по настоящему"];
        _source_string = [_source_string stringByReplacingOccurrencesOfString:@"что-то"
                                                                   withString:@"что то"];
        NSCharacterSet *symbols = [NSCharacterSet punctuationCharacterSet];
        NSArray *components = [_source_string componentsSeparatedByCharactersInSet:symbols];
        _source_string = [components componentsJoinedByString:@""];
        _source_string = [_source_string stringByReplacingOccurrencesOfString:@"  " withString:@" "];
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
                       value:[UIFont fontWithName:kBaseFontName size:_textFontSize]
                       range:NSMakeRange(0, sourceText.length)];
    [sourceText addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithHexString:@"999999"]
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
    NSString *category = allowedLevels[level_num][@"category"];
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
                             @"category": _current_level[@"category"],
                             @"rankAtStart": [AppDelegate currentRank]};
    
    [Flurry logEvent:@"TrainingRound" withParameters:[params mutableCopy] timed:YES];
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

    int progressSpeed = -1;
    if (results.count > 3) {
        int sumOfSeconds = 0;
        float firstAvg = 0, lastAvg = 0;
        for (int i=0; i<results.count; i++) {
            int symbols = [results[i][@"symbols"] intValue];
            int seconds = [results[i][@"seconds"] intValue];
            int speed = (int)((float)symbols / (float)seconds * 60.0);
            sumOfSeconds += seconds;
            if (i < 3) firstAvg += speed;
            if (i >= results.count-3) lastAvg += speed;
        }
        progressSpeed = (lastAvg/3.0 - firstAvg/3.0) * 1000.0 / sumOfSeconds;
    }
    
    NSDictionary *params = @{@"seconds": @(_session_seconds), @"symbols":@(_stat_symbols),
                             @"mistakes":@(_stat_mistakes), @"progressSpeed": @(progressSpeed),
                             @"status": @"complete"};
    [Flurry endTimedEvent:@"TrainingRound" withParameters:params];
    
    [Flurry logEvent:@"WrongTaps" withParameters:@{@"shiftTaps": @(_shiftTaps),
                                                   @"backspaceTaps": @(_backspaceTaps),
                                                   @"wordTaps": @(_wordTaps)}];
    
    [self performSegueWithIdentifier:@"showResultsVC" sender:self];
}

#pragma mark - Keyboard Buttons Handling

// Обработчик нажатий на кнопки клавиатуры (с буквой)
//
- (void)onKeyTapped:(NSString *)keyString {
    if (!_session_timer) [self startSession];
    
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
    if (text.length > 1) return NO;
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
    BOOL playErrorSound = NO;
    
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
            playErrorSound = YES;
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
            [_keyboardView showOnlyKeysWithCharactersInString:_currentToken.string];
    }
    
    // join result string
    NSString *typed = _typed_string;
    NSString *trail = [_source_string substringFromIndex:_typed_string.length];
    typed = [typed stringByAppendingString:trail];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:typed];
    
    // Базовый стиль текста в textView
    [text addAttribute:NSFontAttributeName
                 value:[UIFont fontWithName:kBaseFontName size:kBaseFontSize]
                 range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:@"999999"] // gray
                 range:NSMakeRange(0, text.length)];
    // Цвет уже напечатанной части текста (черный)
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blackColor]
                 range:NSMakeRange(0, _typed_string.length)];
    
    // Контроль ошибок
    if (_useStrictTyping) {
        if (_awaited_key && _awaited_key.length == 0) {
            [text addAttribute:NSForegroundColorAttributeName
                         value:[UIColor colorWithHexString:@"FF3333"] // red
                         range:NSMakeRange(_typed_string.length-1, 1)];
        }
    }
    else {
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
            playErrorSound = YES;
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
    
    _statsLabel.text = [NSString stringWithFormat:@"%d", _stat_symbols];

    if (!_useFullKeyboard)
        [_keyboardView playClickSound];
    if (playErrorSound) {
        AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [delegate playErrorSound];
    }
    
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
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
    NSDictionary *params = @{@"seconds": @(_session_seconds), @"symbols":@(_stat_symbols),
                             @"mistakes":@(_stat_mistakes), @"status":@"aborted"};
    [Flurry endTimedEvent:@"TrainingRound" withParameters:params];
    
    [Flurry logEvent:@"WrongTaps" withParameters:@{@"shiftTaps": @(_shiftTaps),
                                                   @"backspaceTaps": @(_backspaceTaps),
                                                   @"wordTaps": @(_wordTaps)}];
    
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