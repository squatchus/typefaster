//
//  ViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "ViewController.h"
#import "KBPanGestureRecognizer.h"

#import "TFKeyboardView.h"
#import "UIColor+HexColor.h"

@interface ViewController () <UITextViewDelegate, UIGestureRecognizerDelegate>

@property (strong, nonatomic) TFKeyboardView *keyboardView;

@property (nonatomic, strong) NSDictionary *current_level;

@property (nonatomic, strong) NSTimer *session_timer;
@property int session_seconds;

@property int stat_symbols;
@property int stat_mistakes;

// popup, всплывающий над нажатой кнопкой клавиатуры
//
@property (nonatomic, strong) UIImageView *letter_popup;
@property (nonatomic, strong) UILabel *popup_label;

@property (nonatomic, strong) NSString *awaited_key;
@property (nonatomic, strong) NSString *source_string;
@property (nonatomic, strong) NSMutableString *typed_string;
@property NSRange currentWordRange;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // custom keyboard
    _keyboardView = [[NSBundle mainBundle] loadNibNamed:@"TFKeyboardView" owner:self options:nil][0];
    [_keyboardView.shiftButton addTarget:self action:@selector(onShiftPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.backspaceButton addTarget:self action:@selector(onBackspacePressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.enterButton addTarget:self action:@selector(onEnterPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.spaceButton addTarget:self action:@selector(onSpacePressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    [_keyboardView.fullKeyboardButton addTarget:self action:@selector(onFullKeyboardPressed:)
                        forControlEvents:UIControlEventTouchUpInside];
    
    KBPanGestureRecognizer *panRec = [KBPanGestureRecognizer new];
    panRec.delegate = self;
    [panRec addTarget:self action:@selector(onKeyboardPan:)];
    [_keyboardView addGestureRecognizer:panRec];
    
    UIImage *popup_image = [UIImage imageNamed:@"letter_popup"];
    _letter_popup = [[UIImageView alloc] initWithImage:popup_image];
    _popup_label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 54, 54)];
    _popup_label.textAlignment = NSTextAlignmentCenter;
    _popup_label.font = [UIFont systemFontOfSize:32 weight:UIFontWeightRegular];
    _popup_label.text = @"К";
    [_letter_popup addSubview:_popup_label];
    
    [self initSession];
}

- (void)initSession {
    _stat_symbols = 0;
    _stat_mistakes = 0;

    [self loadText];
    
    NSCharacterSet *white_spaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *firstWord = [_source_string componentsSeparatedByCharactersInSet:white_spaces][0];
    [self updateCurrentWordWithText:firstWord andPosition:0];
    
    _currentWordRange = NSMakeRange(0, firstWord.length);
    [self showOnlyKeysWithCharactersInString:firstWord];

    _awaited_key = [firstWord substringWithRange:NSMakeRange(0, 1)];
    
    _textView.inputView = _keyboardView;
    [_textView becomeFirstResponder];
    _textView.selectedRange = NSMakeRange(0, 0);
    
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstItem == self.bottomLayoutGuide) {
            CGFloat height = _keyboardView.frame.size.height;
            constraint.constant = height;
            break;
        }
    }
}

- (void)loadText {
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Texts" ofType:@"plist"];
    NSArray *texts = [NSArray arrayWithContentsOfFile:filePath];

    int level_num = arc4random()%texts.count;
    _current_level = texts[level_num];
    _source_string = texts[level_num][@"text"];
    _typed_string = [[NSMutableString alloc] initWithString:@""];

    
/*@"О сколько нам открытий чудных\nГотовят просвещенья дух\nИ Опыт сын ошибок трудных\nИ Гений парадоксов друг\nИ Случай бог изобретатель";*/
    
//    current_level
    NSMutableAttributedString *sourceText = [[NSMutableAttributedString alloc] initWithString:_source_string];
    [sourceText addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"HelveticaNeue" size:16]
                       range:NSMakeRange(0, sourceText.length)];
    [sourceText addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithHexString:@"999999"]
                       range:NSMakeRange(0, sourceText.length)];
    _textView.attributedText = sourceText;
}

- (void)startSession {
    _session_seconds = 0;
    _session_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTimer) userInfo:nil repeats:YES];
}

- (void)endSession {
    [_session_timer invalidate];
    [_textView resignFirstResponder];
    
    for (NSLayoutConstraint *constraint in self.view.constraints) {
        if (constraint.firstItem == self.bottomLayoutGuide) {
            constraint.constant = 0;
            break;
        }
    }
    
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    if (!results) results = [NSMutableArray new];
    else results = [NSMutableArray arrayWithArray:results]; // for mutability
    [results addObject:@{@"level": _current_level,
                         @"seconds": @(_session_seconds),
                         @"symbols": @(_stat_symbols),
                         @"mistakes": @(_stat_mistakes)}];
    [[NSUserDefaults standardUserDefaults] setObject:results forKey:@"results"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self performSegueWithIdentifier:@"showResultsVC" sender:self];
}

#pragma mark - Keyboard Buttons Handling

// Обработчик нажатий на кнопки клавиатуры (с буквой)
//
- (void)onKeyTapped:(NSString *)keyString {
    if (!_session_timer) {
        [self startSession];
    }
    [_keyboardView playClickSound];
    [self updateTextViewWithKey:keyString]; // also calculate stats
}

// Нажатие небуквенных кнопок на базовой клавиатуре
//
- (void)onBackspacePressed:(UIButton *)sender {
    [_keyboardView playClickSound];
    if (_textView.selectedRange.location > 0) {
        [self updateTextViewWithKey:nil];
        [self updateStats];
    }
}

- (void)onShiftPressed:(UIButton *)sender {
    [_keyboardView playClickSound];
    sender.selected = !sender.selected;
}

- (void)onSpacePressed:(UIButton *)sender {
    [_keyboardView playClickSound];
    [self onKeyTapped:@" "];
}

- (void)onEnterPressed:(UIButton *)sender {
    [_keyboardView playClickSound];
    [self onKeyTapped:@"\n"];
}

// Переключение на стандартную клавиатуру
//
- (void)onFullKeyboardPressed:(UIButton *)sender {
    [_keyboardView playClickSound];
    [_textView resignFirstResponder];
    _textView.inputView = nil;
    [_textView becomeFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    [self onKeyTapped:text];
    return NO;
}

#pragma mark - Update User Interface

// Оставляет на кастомной клавиатуре, только буквы из указанной строки
//
- (void)showOnlyKeysWithCharactersInString:(NSString *)string {
    for (UILabel *label in _keyboardView.subviews) {
        if (![label isKindOfClass:[UILabel class]]) continue;
        NSRange range = [[string uppercaseString] rangeOfString:[label.text uppercaseString]];
        if (range.location == NSNotFound) label.hidden = YES;
        else label.hidden = NO;
    }
}

// Обновление вью с текстом, который надо напечатать (расставляет аттрибуты)
//
- (void)updateTextViewWithKey:(NSString *)keyString {
    BOOL levelComplete = NO;
    
    if (keyString.length > 0) { // key was pressed
        if ([_awaited_key isEqualToString:@""] == NO &&
            !([_awaited_key isEqualToString:@"\n"] && ![keyString isEqualToString:@"\n"])) {
            [_typed_string appendString:keyString];

            NSRange range = NSMakeRange(_typed_string.length, 1);
            if (![keyString isEqualToString:_awaited_key]) _awaited_key = @"";
            else if (range.location < _source_string.length)
                _awaited_key = [_source_string substringWithRange:range];
            else
                levelComplete = YES;
        }
        else {
            _stat_mistakes++;
            [self pulseTextViewBackgroundColor];
        }
    }
    else { // backspace
        if ([_awaited_key isEqualToString:@""]) {
            NSRange charPosition = NSMakeRange(_typed_string.length-1, 1);
            [_typed_string deleteCharactersInRange:charPosition];
            _awaited_key = [_source_string substringWithRange:NSMakeRange(_typed_string.length, 1)];
        }
        else {
            // false backspace pressed
            _stat_mistakes++;
            [self pulseTextViewBackgroundColor];
        }
    }
    
    _stat_symbols = (int)_typed_string.length;
    
    if ([_awaited_key isEqualToString:@""])
        _currentWordLabel.text = @"[Стереть]";
    else if ([_awaited_key isEqualToString:@" "])
        _currentWordLabel.text = @"\" \"";
    else if ([_awaited_key isEqualToString:@"\n"])
        [self onKeyTapped:@"\n"];
//        _currentWordLabel.text = @"[Ввод]";
    else {
        NSString *string = [_source_string substringWithRange:_currentWordRange];
        int position = (int)(_typed_string.length-_currentWordRange.location);
        if (position >= 0 && position < string.length)
            [self updateCurrentWordWithText:string andPosition:position];
    }
    
    BOOL shouldBackspace = [_awaited_key isEqualToString:@""];
    NSString *typed = _typed_string;
    NSString *trail = [_source_string substringFromIndex:_typed_string.length];
    typed = [typed stringByAppendingString:trail];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:typed];
    
    // Базовый стиль текста в textView
    [text addAttribute:NSFontAttributeName
                       value:[UIFont fontWithName:@"HelveticaNeue" size:16]
                       range:NSMakeRange(0, text.length)];
    [text addAttribute:NSForegroundColorAttributeName
                       value:[UIColor colorWithHexString:@"999999"]
                       range:NSMakeRange(0, text.length)];
    // Цвет уже напечатанной части текста (черный)
    [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor blackColor]
                 range:NSMakeRange(0, _typed_string.length)];

    // Цвет текущего слова (зеленый)
    if (_typed_string.length-(_currentWordRange.location+_currentWordRange.length) > 0) {
        [text addAttribute:NSForegroundColorAttributeName
                 value:[UIColor colorWithHexString:@"009900"]
                 range:NSMakeRange(_currentWordRange.location, MAX(0, _typed_string.length-_currentWordRange.location))];
    }
    else {
        if (!shouldBackspace) {
            // next word
            NSCharacterSet *white_spaces = [NSCharacterSet whitespaceAndNewlineCharacterSet];
            NSString *trail = [_source_string substringFromIndex:_typed_string.length];
            NSArray *words = [trail componentsSeparatedByCharactersInSet:white_spaces];
            NSString *next_word;
            for (NSString *word in words) if (word.length > 0) { next_word = word; break; }
            if (next_word && [next_word hasPrefix:_awaited_key]) {
                NSInteger next_loc = [trail rangeOfString:next_word].location + _typed_string.length;
                [self updateCurrentWordWithText:next_word andPosition:0];
                _currentWordRange = NSMakeRange(next_loc, next_word.length);
                [self showOnlyKeysWithCharactersInString:next_word];
            }
            else {
                _currentWordRange = NSMakeRange(_typed_string.length, 1);
            }
        }
    }
    // Цвет последней буквы-опечатки (красный)
    if (shouldBackspace) {
        _stat_mistakes++;
        [self pulseTextViewBackgroundColor];
        [text addAttribute:NSForegroundColorAttributeName
                     value:[UIColor colorWithHexString:@"FF3333"]
                     range:NSMakeRange(_typed_string.length-1, 1)];
    }

    _textView.attributedText = text;
    _textView.selectedRange = NSMakeRange(_typed_string.length, 0);

    [self updateStats];
    if (levelComplete) {
        [self endSession];
    }
}

// Обновляем label с текущим словом, которое находится в процессе набора
//
- (void)updateCurrentWordWithText:(NSString *)string andPosition:(int)position {
    NSMutableAttributedString *currentWord = [[NSMutableAttributedString alloc] initWithString:string];
    [currentWord addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"HelveticaNeue-Bold" size:24]
                        range:NSMakeRange(0, currentWord.length)];
    [currentWord addAttribute:NSForegroundColorAttributeName
                        value:[UIColor colorWithHexString:@"A54466"]
                        range:NSMakeRange(0, currentWord.length)];
    if (position >= 0) {
        [currentWord addAttribute:NSForegroundColorAttributeName
                            value:[UIColor colorWithHexString:@"336699"]
                            range:NSMakeRange(position, 1)];
    }
    
    _currentWordLabel.attributedText = currentWord;
}

// Обновляем данные о количестве набранных символов и совершенных ошибках
//
- (void)updateStats {
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

- (void)updateTimer {
    _session_seconds++;
    int minutes = _session_seconds/60;
    int seconds = _session_seconds % 60;
    _secondsLabel.text = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
}

#pragma mark - Helpers

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    if (_session_timer) [_session_timer invalidate];
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
    
    if ([subview isKindOfClass:[UILabel class]]) {
        UILabel *label = (UILabel *)subview;
        _popup_label.text = label.text;
//        if (recognizer.state == UIGestureRecognizerStateBegan) [_keyboardView playClickSound];
        
        if (recognizer.state == UIGestureRecognizerStateBegan
            || recognizer.state == UIGestureRecognizerStateChanged) {
            _letter_popup.center = CGPointMake(label.center.x, label.center.y-32);
            if (!_letter_popup.superview)
                [_keyboardView addSubview:_letter_popup];
        }
        else { // pan ended
            [_letter_popup removeFromSuperview];
            if (_keyboardView.shiftButton.selected)
                [self onKeyTapped:[label.text uppercaseString]];
            else
                [self onKeyTapped:[label.text lowercaseString]];
            _keyboardView.shiftButton.selected = NO;
        }
    }
    else { // not label
        [_letter_popup removeFromSuperview];
    }
}

- (void)pulseTextViewBackgroundColor;
{
    [UIView animateWithDuration:0.15 animations:^{
        self.view.backgroundColor = [UIColor colorWithHexString:@"ffdede"];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.15 animations:^{
            self.view.backgroundColor = [UIColor whiteColor];
        }];
    }];
}

@end
