//
//  SettingsViewController.m
//  type.trainer
//
//  Created by Squatch on 05.07.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+HexColor.h"
#import "AppDelegate.h"
#import "Flurry.h"
#import <Crashlytics/Crashlytics.h>

@interface SettingsViewController ()

- (IBAction)onSwitchValueChanged:(UISwitch *)sender;
- (IBAction)onCategoryButtonPressed:(UIButton *)sender;
- (IBAction)onDoneButtonPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *strictTypingTitleLabel;

@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *notificationDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *canMistakeSwitch;
@property (weak, nonatomic) IBOutlet UILabel *strictTypingDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *categoryClassicButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryQuotesButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryHokkuButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryCookiesButton;

@end


@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Update switchers & switcher's settings in UserDefaults
    //
    _notificationSwitch.on  = [[[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"] boolValue];
    _canMistakeSwitch.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"] boolValue];
    
//    if (IS_IPHONE_5 || IS_IPHONE_4_OR_LESS) {
        NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
        paragraphStyles.alignment = NSTextAlignmentJustified;
        paragraphStyles.firstLineHeadIndent = 1.0;
        NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyles};
        NSAttributedString *notificationText = [[NSAttributedString alloc] initWithString: _notificationDescriptionLabel.text attributes:attributes];
        _notificationDescriptionLabel.attributedText = notificationText;
        NSAttributedString *strictTypingText = [[NSAttributedString alloc] initWithString: _strictTypingDescriptionLabel.text attributes:attributes];
        _strictTypingDescriptionLabel.attributedText = strictTypingText;
//    }
    
    // Update category buttons & button's settings in UserDefaults
    //
    _categoryClassicButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryClassic"] boolValue];
    _categoryQuotesButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryQuotes"] boolValue];
    _categoryHokkuButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryHokku"] boolValue];
    _categoryCookiesButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryCookies"] boolValue];
    
    [self updateCategoryButton:_categoryClassicButton];
    [self updateCategoryButton:_categoryQuotesButton];
    [self updateCategoryButton:_categoryHokkuButton];
    [self updateCategoryButton:_categoryCookiesButton];
    
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]])
            subview.layer.cornerRadius = subview.frame.size.height/2.0;
        if ([subview isKindOfClass:[UISwitch class]]) {
            UISwitch *switcher = (UISwitch *)subview;
            switcher.onTintColor = [UIColor colorWithHexString:@"c55c77"];
        }
    }
    
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        _settingsTitleLabel.font = [_settingsTitleLabel.font fontWithSize:16];
        _notificationTitleLabel.font = [_notificationTitleLabel.font fontWithSize:16];
        _notificationDescriptionLabel.font = [_notificationDescriptionLabel.font fontWithSize:16];
        _strictTypingTitleLabel.font = [_strictTypingTitleLabel.font fontWithSize:16];
        _strictTypingDescriptionLabel.font = [_strictTypingDescriptionLabel.font fontWithSize:16];
        _categoryClassicButton.titleLabel.font = [_categoryClassicButton.titleLabel.font fontWithSize:16];
        _categoryQuotesButton.titleLabel.font = [_categoryQuotesButton.titleLabel.font fontWithSize:16];
        _categoryHokkuButton.titleLabel.font = [_categoryHokkuButton.titleLabel.font fontWithSize:16];
        _categoryCookiesButton.titleLabel.font = [_categoryCookiesButton.titleLabel.font fontWithSize:16];
        _doneWidthConstraint.constant = 280;
//        NSAttributedString *notificationText = [[NSAttributedString alloc] initWithString:@"Если хотите заниматься регулярно, мы можем напоминать вам раз в день о предстоящей тренировке" attributes:attributes];
//        _notificationDescriptionLabel.attributedText = notificationText;
//        NSAttributedString *strictTypingText = [[NSAttributedString alloc] initWithString:@"Не позволяет Вам набирать текст, пока не исправлена ошибка. По началу  раздражает, но очень дисциплинирует" attributes:attributes];
//        _strictTypingDescriptionLabel.attributedText = strictTypingText;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSwitchValueChanged:(UISwitch *)sender {
    if (sender == _notificationSwitch) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_notificationSwitch.on) forKey:@"notifications"];
        if (_notificationSwitch.on)
            [AppDelegate enableNotifications];
        else
            [AppDelegate disableNotifications];
        
        NSNumber *state = @(_notificationSwitch.on);
        [Flurry logEvent:@"Notifications switched" withParameters:@{@"state": state}];
        [Answers logCustomEventWithName:@"Notifications switched" customAttributes:@{@"state": state}];
    }
    else if (sender == _canMistakeSwitch) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_canMistakeSwitch.on) forKey:@"strictTyping"];
        
        NSNumber *state = @(_canMistakeSwitch.on);
        [Flurry logEvent:@"StrictTyping switched" withParameters:@{@"state": state}];
        [Answers logCustomEventWithName:@"StrictTyping switched" customAttributes:@{@"state": state}];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onCategoryButtonPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    NSDictionary *params;
    if (sender == _categoryClassicButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryClassicButton.selected) forKey:@"categoryClassic"];
        params = @{@"name":@"categoryClassic"};
    }
    if (sender == _categoryQuotesButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryQuotesButton.selected) forKey:@"categoryQuotes"];
        params = @{@"name":@"categoryQuotes"};
    }
    if (sender == _categoryHokkuButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryHokkuButton.selected) forKey:@"categoryHokku"];
        params = @{@"name":@"categoryHokku"};
    }
    if (sender == _categoryCookiesButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryCookiesButton.selected) forKey:@"categoryCookies"];
        params = @{@"name":@"categoryCookies"};
    }
    
    if (sender.selected) {
        [Flurry logEvent:@"ContentCategory enabled" withParameters:params];
        [Answers logCustomEventWithName:@"ContentCategory enabled" customAttributes:params];
    }
    else {
        [Flurry logEvent:@"ContentCategory disabled" withParameters:params];
        [Answers logCustomEventWithName:@"ContentCategory disabled" customAttributes:params];
    }

    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateCategoryButton:sender];
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
}

- (void)updateCategoryButton:(UIButton *)sender {
    if (sender.selected)
        sender.backgroundColor = [UIColor colorWithHexString:@"a54466"];
    else
        sender.backgroundColor = [UIColor colorWithHexString:@"c1c1c1"];
}

- (IBAction)onDoneButtonPressed:(UIButton *)sender {
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
