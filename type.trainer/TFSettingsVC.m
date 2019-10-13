//
//  SettingsViewController.m
//  type.trainer
//
//  Created by Squatch on 05.07.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFSettingsVC.h"

#import "UIColor+TFColors.h"

@interface TFSettingsVC ()

@property (strong, nonatomic, readonly) TFSettingsVM *viewModel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *doneWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *settingsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *notificationTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *strictTypingTitleLabel;

@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UILabel *notificationDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *strictTypingSwitch;
@property (weak, nonatomic) IBOutlet UILabel *strictTypingDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIButton *categoryClassicButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryQuotesButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryHokkuButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryCookiesButton;

@end

@implementation TFSettingsVC

- (void)updateWithViewModel:(TFSettingsVM *)viewModel
{
    _viewModel = viewModel;
    
    self.notificationSwitch.on  = self.viewModel.notifications;
    self.strictTypingSwitch.on = self.viewModel.strictTyping;
    
    self.settingsTitleLabel.text = self.viewModel.settingsTitle;
    self.notificationTitleLabel.text = self.viewModel.notificationsTitle;
    self.strictTypingTitleLabel.text = self.viewModel.strictTypingTitle;
    
    NSMutableParagraphStyle *paragraphStyles = [[NSMutableParagraphStyle alloc] init];
    paragraphStyles.alignment = NSTextAlignmentJustified;
    paragraphStyles.firstLineHeadIndent = 1.0;
    NSDictionary *attributes = @{NSParagraphStyleAttributeName: paragraphStyles};
    
    NSAttributedString *notificationText = [[NSAttributedString alloc] initWithString:self.viewModel.notificationsInfo attributes:attributes];
    self.notificationDescriptionLabel.attributedText = notificationText;
    NSAttributedString *strictTypingText = [[NSAttributedString alloc] initWithString:self.viewModel.strictTypingInfo attributes:attributes];
    self.strictTypingDescriptionLabel.attributedText = strictTypingText;
    
    self.categoryClassicButton.selected = self.viewModel.categoryClassic;
    self.categoryQuotesButton.selected = self.viewModel.categoryQuotes;
    self.categoryHokkuButton.selected = self.viewModel.categoryHokku;
    self.categoryCookiesButton.selected = self.viewModel.categoryCookies;
    
    [self updateCategoryButton:_categoryClassicButton];
    [self updateCategoryButton:_categoryQuotesButton];
    [self updateCategoryButton:_categoryHokkuButton];
    [self updateCategoryButton:_categoryCookiesButton];
    
    for (UIView *subview in self.view.subviews)
    {
        if ([subview isKindOfClass:[UIButton class]])
            subview.layer.cornerRadius = subview.frame.size.height/2.0;
        if ([subview isKindOfClass:[UISwitch class]])
        {
            UISwitch *switcher = (UISwitch *)subview;
            switcher.onTintColor = UIColor.tf_purple;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.onViewWillAppear ? self.onViewWillAppear() : nil;
}

#pragma mark - IBActions

- (IBAction)onSwitchValueChanged:(UISwitch *)sender
{
    if (sender == self.notificationSwitch)
    {
        BOOL notifications = self.notificationSwitch.on;
        self.viewModel.notifications = notifications;
        self.onNotificationsSettingChanged ? self.onNotificationsSettingChanged(notifications) : nil;
    }
    else if (sender == self.strictTypingSwitch)
    {
        self.viewModel.strictTyping = self.strictTypingSwitch.on;
    }
}

- (IBAction)onCategoryButtonPressed:(UIButton *)sender
{
    sender.selected = !sender.selected;
    if (sender == self.categoryClassicButton)
    {
        self.viewModel.categoryClassic = self.categoryClassicButton.selected;
    }
    if (sender == self.categoryQuotesButton)
    {
        self.viewModel.categoryQuotes = self.categoryQuotesButton.selected;
    }
    if (sender == self.categoryHokkuButton)
    {
        self.viewModel.categoryHokku = self.categoryHokkuButton.selected;
    }
    if (sender == self.categoryCookiesButton)
    {
        self.viewModel.categoryCookies = self.categoryCookiesButton.selected;
    }    
    [self updateCategoryButton:sender];
    self.onCategorySettingChanged ? self.onCategorySettingChanged() : nil;
}

- (IBAction)onDoneButtonPressed:(UIButton *)sender
{
    self.onDonePressed ? self.onDonePressed() : nil;
}

#pragma mark - Helper

- (void)updateCategoryButton:(UIButton *)sender
{
    UIColor *color = sender.selected ? UIColor.tf_purple : UIColor.tf_light;
    sender.backgroundColor = color;
}

@end
