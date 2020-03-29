//
//  MenuViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFMenuVC.h"

#import "UIScreen+Extra.h"

@interface TFMenuVC()

@property (strong, nonatomic, readonly) TFMenuVM *viewModel;

@property (weak, nonatomic) IBOutlet UILabel *yourSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *signsPerMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *signsPerMinTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *firstResultLabel;

@property (weak, nonatomic) IBOutlet UILabel *rankHintLabel;

@property (weak, nonatomic) IBOutlet UIImageView *starView1;
@property (weak, nonatomic) IBOutlet UIImageView *starView2;
@property (weak, nonatomic) IBOutlet UIImageView *starView3;
@property (weak, nonatomic) IBOutlet UIImageView *starView4;
@property (weak, nonatomic) IBOutlet UIImageView *starView5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leaderboardWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rankTopSpaceConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rankBottomSpaceConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topMargin;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomMargin;

@property (weak, nonatomic) IBOutlet UIButton *startTypingButton;
@property (weak, nonatomic) IBOutlet UIButton *gameCenterButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;

@end

@implementation TFMenuVC

- (void)updateWithViewModel:(TFMenuVM *)viewModel
{
    _viewModel = viewModel;
    
    _yourSpeedLabel.text = self.viewModel.bestResultTitle;
    _signsPerMinLabel.text = self.viewModel.signsPerMin;
    _signsPerMinTitleLabel.text = self.viewModel.signsPerMinTitle;
    _firstResultLabel.text = self.viewModel.firstResultTitle;
    
    int numberOfFullStars = (int)self.viewModel.stars;
    BOOL halfStar = (self.viewModel.stars-numberOfFullStars > 0);
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
    
    [_gameCenterButton setTitle:self.viewModel.rankTitle forState:UIControlStateNormal];
    _rankHintLabel.text = self.viewModel.rankSubtitle;
    
    [_startTypingButton setTitle:self.viewModel.typeFasterTitle forState:UIControlStateNormal];
    [_settingsButton setTitle:self.viewModel.settingsTitle forState:UIControlStateNormal];
    [_rateButton setTitle:self.viewModel.rateTitle forState:UIControlStateNormal];
    
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
    _gameCenterButton.layer.cornerRadius = _gameCenterButton.frame.size.height/2.0;
    _startTypingButton.layer.cornerRadius = _startTypingButton.frame.size.height/2.0;
}

- (void)reloadViewModel
{
    [self updateWithViewModel:self.viewModel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.onViewWillAppear ? self.onViewWillAppear() : nil;
    
    self.topMargin.constant = UIScreen.verticalMarginForDevice;
    self.bottomMargin.constant = UIScreen.verticalMarginForDevice;
}

#pragma mark - IBActions

- (IBAction)onRateButtonPressed:(UIButton *)sender
{
    self.onRatePressed ? self.onRatePressed() : nil;
}

- (IBAction)onGameCenterButtonPressed:(UIButton *)sender
{
    self.onLeaderboardPressed ? self.onLeaderboardPressed() : nil;
}

- (IBAction)onSettingsButtonPressed:(UIButton *)sender
{
    self.onSetttingsPressed ? self.onSetttingsPressed() : nil;
}

- (IBAction)onPlayButtonPressed:(UIButton *)sender
{
    self.onPlayPressed ? self.onPlayPressed() : nil;
}

@end
