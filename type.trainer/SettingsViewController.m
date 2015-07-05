//
//  SettingsViewController.m
//  type.trainer
//
//  Created by Squatch on 05.07.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+HexColor.h"

@interface SettingsViewController ()

- (IBAction)onSwitchValueChanged:(UISwitch *)sender;
- (IBAction)onCategoryButtonPressed:(UIButton *)sender;
- (IBAction)onDoneButtonPressed:(UIButton *)sender;

@property (weak, nonatomic) IBOutlet UISwitch *keyboardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *canMistakeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *categoryClassicButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryQuotesButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryHokkuButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryCookiesButton;
@end



@implementation SettingsViewController

- (void)dealloc {
    NSLog(@"settings dealloc: %p", self);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"settings did load: %p", self);
    
    // Update switchers & switcher's settings in UserDefaults
    //
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"])
        _keyboardSwitch.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"] boolValue];
    else
        [[NSUserDefaults standardUserDefaults] setValue:@(_keyboardSwitch.on) forKey:@"fullKeyboard"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"])
        _notificationSwitch.on  = [[[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"] boolValue];
    else
        [[NSUserDefaults standardUserDefaults] setValue:@(_notificationSwitch.on) forKey:@"notifications"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"])
        _canMistakeSwitch.on = [[[NSUserDefaults standardUserDefaults] valueForKey:@"strictTyping"] boolValue];
    else
        [[NSUserDefaults standardUserDefaults] setValue:@(_canMistakeSwitch.on) forKey:@"strictTyping"];
    
    // Update category buttons & button's settings in UserDefaults
    //
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryClassic"])
        _categoryClassicButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryClassic"] boolValue];
    else
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryClassicButton.selected) forKey:@"categoryClassic"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryQuotes"])
        _categoryQuotesButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryQuotes"] boolValue];
    else
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryQuotesButton.selected) forKey:@"categoryQuotes"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryHokku"])
        _categoryHokkuButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryHokku"] boolValue];
    else
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryHokkuButton.selected) forKey:@"categoryHokku"];
    if ([[NSUserDefaults standardUserDefaults] valueForKey:@"categoryCookies"])
        _categoryCookiesButton.selected = [[[NSUserDefaults standardUserDefaults] valueForKey:@"categoryCookies"] boolValue];
    else
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryCookiesButton.selected) forKey:@"categoryCookies"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    
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
    NSLog(@"onSwitchValueChanged");
    
    if (sender == _keyboardSwitch)
        [[NSUserDefaults standardUserDefaults] setValue:@(_keyboardSwitch.on) forKey:@"fullKeyboard"];
    else if (sender == _notificationSwitch)
        [[NSUserDefaults standardUserDefaults] setValue:@(_notificationSwitch.on) forKey:@"notifications"];
    else if (sender == _canMistakeSwitch)
        [[NSUserDefaults standardUserDefaults] setValue:@(_canMistakeSwitch.on) forKey:@"strictTyping"];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)onCategoryButtonPressed:(UIButton *)sender {
    NSLog(@"onCategoryButtonPressed");
    sender.selected = !sender.selected;
    
    if (sender == _categoryClassicButton)
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryClassicButton.selected) forKey:@"categoryClassic"];
    if (sender == _categoryQuotesButton)
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryQuotesButton.selected) forKey:@"categoryQuotes"];
    if (sender == _categoryHokkuButton)
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryHokkuButton.selected) forKey:@"categoryHokku"];
    if (sender == _categoryCookiesButton)
        [[NSUserDefaults standardUserDefaults] setValue:@(_categoryCookiesButton.selected) forKey:@"categoryCookies"];

    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateCategoryButton:sender];
}

- (void)updateCategoryButton:(UIButton *)sender {
    if (sender.selected)
        sender.backgroundColor = [UIColor colorWithHexString:@"a54466"];
    else
        sender.backgroundColor = [UIColor colorWithHexString:@"c1c1c1"];
}

- (IBAction)onDoneButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
