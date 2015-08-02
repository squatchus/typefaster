//
//  MenuViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "MenuViewController.h"
#import "UIColor+HexColor.h"
#import "AppDelegate.h"
#import "Flurry.h"
#import <Crashlytics/Crashlytics.h>

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
    _gameCenterButton.layer.cornerRadius = _gameCenterButton.frame.size.height/2.0;
    _startTypingButton.layer.cornerRadius = _startTypingButton.frame.size.height/2.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(viewWillAppear:) name:@"bestScoreUpdated" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    int bestResult = [AppDelegate bestResult];
    [self updateStarsBySpeed:bestResult];
    _signsPerMinLabel.text = [NSString stringWithFormat:@"%d", bestResult];
    int lastDigit = bestResult % 10;
    NSString *ending = (lastDigit == 1)?@"":((lastDigit > 1 && lastDigit < 5)?@"а":@"ов");
    _signsPerMinTitleLabel.text = [NSString stringWithFormat:@"знак%@ в минуту", ending];
    
    int firstResult = [AppDelegate firstResult];
    if (firstResult > 0) {
        if (firstResult == bestResult)
            _firstResultLabel.text = @"продолжайте тренироваться";
        else
            _firstResultLabel.text = [NSString stringWithFormat:@"а начинали со скорости %d", firstResult];
    }
    
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        _yourSpeedLabel.font = [_yourSpeedLabel.font fontWithSize:16];
        _signsPerMinTitleLabel.font = [_signsPerMinTitleLabel.font fontWithSize:16];
        _firstResultLabel.font = [_firstResultLabel.font fontWithSize:16];
        _rankHintLabel.font = [_rankHintLabel.font fontWithSize:16];
        _gameCenterButton.titleLabel.font = [_gameCenterButton.titleLabel.font fontWithSize:16];
        _rateButton.titleLabel.font = [_rateButton.titleLabel.font fontWithSize:14];
        _settingsButton.titleLabel.font = [_settingsButton.titleLabel.font fontWithSize:14];
        _starWidthConstraint.constant = 35;
        _starHeightConstraint.constant = 32;
        _rankTopSpaceConstraint.constant = 16;
        _rankBottomSpaceConstraint.constant = 16;
        _leaderboardWidthConstraint.constant = 64;
        [_settingsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateStarsBySpeed:(int)speed {
    NSString *rankString = [AppDelegate currentRank];
    NSString *buttonTitle = [NSString stringWithFormat:@"Ранг - %@", rankString];
    [_gameCenterButton setTitle:buttonTitle forState:UIControlStateNormal];
    float numberOfStars = [AppDelegate numberOfStarsBySpeed:speed];
    int numberOfFullStars = (int)numberOfStars;
    BOOL halfStar = (numberOfStars-numberOfFullStars > 0);
    NSArray *stars = @[_starView1, _starView2, _starView3, _starView4, _starView5];
    for (UIImageView *starView in stars) {
        if (numberOfFullStars > 0)
            starView.image = [UIImage imageNamed:@"star_gold.png"];
        else if (numberOfFullStars==0 && halfStar)
            starView.image = [UIImage imageNamed:@"star_goldgray.png"];
        else
            starView.image = [UIImage imageNamed:@"star_gray.png"];
        numberOfFullStars--;
    }
    
    NSString *nextRank = [AppDelegate rankAfterRank:rankString];
    if (nextRank) {
        int nextMinValue = [AppDelegate minValueForRank:nextRank];
        int nextMaxValue = [AppDelegate maxValueForRank:nextRank];
        _rankHintLabel.text = [NSString stringWithFormat:@"Следующая цель: %d знаков/мин.", (speed < nextMinValue)?nextMinValue:nextMaxValue];
    }
    else {
        _rankHintLabel.text = @"Вы бесподобны :)";
    }
}

- (IBAction)onRateButtonPressed:(UIButton *)sender {
    [Flurry logEvent:@"RateButton clicked"];
    [Answers logCustomEventWithName:@"RateButton clicked" customAttributes:nil];

    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    NSString *urlString = @"itms-apps://itunes.apple.com/app/id1013588476";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)onGameCenterButtonPressed:(UIButton *)sender {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [delegate playButtonClickSound];
    if (delegate.gameCenterEnabled && delegate.leaderboardIdentifier) {
        GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
        gcViewController.gameCenterDelegate = self;
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = delegate.leaderboardIdentifier;
        [self presentViewController:gcViewController animated:YES completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Таблица рекордов" message:@"Для доступа к таблице рекордов, необходимо войти в Game Center. Откройте 'Настройки' -> 'Game Center' и введите данные своей учётной записи" delegate:nil cancelButtonTitle:@"Ок" otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)onSettingsButtonPressed:(UIButton *)sender {
    [Flurry logEvent:@"SettingsButton clicked"];
    [Answers logCustomEventWithName:@"SettingsButton clicked" customAttributes:nil];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self performSegueWithIdentifier:@"menuToSettings" sender:self];
}

- (IBAction)onPlayButtonPressed:(UIButton *)sender {
    [Flurry logEvent:@"PlayButton clicked"];
    [Answers logCustomEventWithName:@"PlayButton clicked" customAttributes:nil];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self performSegueWithIdentifier:@"menuToGame" sender:self];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
