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

@interface SettingsViewController ()

- (IBAction)onSwitchValueChanged:(UISwitch *)sender;
- (IBAction)onCategoryButtonPressed:(UIButton *)sender;
- (IBAction)onDoneButtonPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *canMistakeSwitch;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)onSwitchValueChanged:(UISwitch *)sender {
    if (sender == _notificationSwitch) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_notificationSwitch.on) forKey:@"notifications"];
        if (_notificationSwitch.on) [AppDelegate enableNotifications];
        else [AppDelegate disableNotifications];
        [Flurry logEvent:@"Notifications switched" withParameters:@{@"state": @(_notificationSwitch.on)}];
    }
    else if (sender == _canMistakeSwitch) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_canMistakeSwitch.on) forKey:@"strictTyping"];
        [Flurry logEvent:@"StrictTyping switched" withParameters:@{@"state": @(_canMistakeSwitch.on)}];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onCategoryButtonPressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    
    NSDictionary *params;
    if (sender == _categoryClassicButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryClassicButton.selected) forKey:@"categoryClassic"];
        params = @{@"state": @(_categoryClassicButton.selected), @"name":@"categoryClassic"};
    }
    if (sender == _categoryQuotesButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryQuotesButton.selected) forKey:@"categoryQuotes"];
        params = @{@"state": @(_categoryQuotesButton.selected), @"name":@"categoryQuotes"};
    }
    if (sender == _categoryHokkuButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryHokkuButton.selected) forKey:@"categoryHokku"];
        params = @{@"state": @(_categoryHokkuButton.selected), @"name":@"categoryHokku"};
    }
    if (sender == _categoryCookiesButton) {
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryCookiesButton.selected) forKey:@"categoryCookies"];
        params = @{@"state": @(_categoryCookiesButton.selected), @"name":@"categoryCookies"};
    }
    [Flurry logEvent:@"ContentCategory switched" withParameters:params];

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
