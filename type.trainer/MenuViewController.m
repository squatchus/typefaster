//
//  MenuViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFMenuVC.h"

#import "UIColor+HexColor.h"
#import "TFAppDelegate.h"
#import "UIAlertController+Alerts.h"

@implementation TFMenuVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
    _gameCenterButton.layer.cornerRadius = _gameCenterButton.frame.size.height/2.0;
    _startTypingButton.layer.cornerRadius = _startTypingButton.frame.size.height/2.0;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(viewWillAppear:) name:@"bestScoreUpdated" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    int bestResult = [APP.data bestResult];
    [self updateStarsBySpeed:bestResult];
    _signsPerMinLabel.text = [NSString stringWithFormat:@"%d", bestResult];
    int lastDigit = bestResult % 10;
    NSString *ending = (lastDigit == 1)?@"":((lastDigit > 1 && lastDigit < 5)?@"а":@"ов");
    _signsPerMinTitleLabel.text = [NSString stringWithFormat:@"знак%@ в минуту", ending];
    
    int firstResult = [APP.data firstResult];
    if (firstResult > 0)
    {
        if (firstResult == bestResult)
            _firstResultLabel.text = NSLocalizedString(@"продолжайте тренироваться", nil);
        else
            _firstResultLabel.text = [NSString stringWithFormat:NSLocalizedString(@"а начинали со скорости %d", nil), firstResult];
    }
}

- (void)updateStarsBySpeed:(int)speed
{
    NSString *rankString = [APP.data currentRank];
    NSString *buttonTitle = [NSString stringWithFormat:@"Ранг - %@", rankString];
    [_gameCenterButton setTitle:buttonTitle forState:UIControlStateNormal];
    float numberOfStars = [APP.data numberOfStarsBySpeed:speed];
    int numberOfFullStars = (int)numberOfStars;
    BOOL halfStar = (numberOfStars-numberOfFullStars > 0);
    NSArray *stars = @[_starView1, _starView2, _starView3, _starView4, _starView5];
    for (UIImageView *starView in stars)
    {
        if (numberOfFullStars > 0)
            starView.image = [UIImage imageNamed:@"star_gold.png"];
        else if (numberOfFullStars==0 && halfStar)
            starView.image = [UIImage imageNamed:@"star_goldgray.png"];
        else
            starView.image = [UIImage imageNamed:@"star_gray.png"];
        numberOfFullStars--;
    }
    
    NSString *nextRank = [APP.data rankAfterRank:rankString];
    if (nextRank)
    {
        int nextMinValue = [APP.data minValueForRank:nextRank];
        int nextMaxValue = [APP.data maxValueForRank:nextRank];
        _rankHintLabel.text = [NSString stringWithFormat:@"Следующая цель: %d знаков/мин.", (speed < nextMinValue)?nextMinValue:nextMaxValue];
    }
    else
    {
        _rankHintLabel.text = NSLocalizedString(@"Вы бесподобны :)", nil);
    }
}

- (IBAction)onRateButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1013588476"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (IBAction)onGameCenterButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    if ([APP.leaderboards canShowLeaderboard])
    {
        [APP.leaderboards showLeaderboard];
    }
    else
    {
        [UIAlertController showLoginToGameCenterAlert];
    }
}

- (IBAction)onSettingsButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    [self performSegueWithIdentifier:@"menuToSettings" sender:self];
}

- (IBAction)onPlayButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    [self performSegueWithIdentifier:@"menuToGame" sender:self];
}

@end
