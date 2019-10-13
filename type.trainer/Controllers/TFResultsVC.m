//
//  ResultsViewController.m
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFResultsVC.h"

@interface TFResultsVC ()

@property (strong, nonatomic, readonly) TFResultsVM *viewModel;

@property (weak, nonatomic) IBOutlet UILabel *resultTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *signsPerMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *signsPerMinTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *mistakesPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *mistakesPercentTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestResultLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestResultTitleLabel;

@property (weak, nonatomic) IBOutlet UIImageView *starView1;
@property (weak, nonatomic) IBOutlet UIImageView *starView2;
@property (weak, nonatomic) IBOutlet UIImageView *starView3;
@property (weak, nonatomic) IBOutlet UIImageView *starView4;
@property (weak, nonatomic) IBOutlet UIImageView *starView5;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starWidthConstraint;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;

@end

@implementation TFResultsVC

- (void)updateWithViewModel:(TFResultsVM *)viewModel
{
    _viewModel = viewModel;
    
    self.resultTitleLabel.text = self.viewModel.resultTitle;
    self.bestResultLabel.text = self.viewModel.bestResult;
    self.bestResultTitleLabel.text = self.viewModel.bestResultTitle;
    self.signsPerMinLabel.text = self.viewModel.signsPerMin;
    self.signsPerMinTitleLabel.text = self.viewModel.signsPerMinTitle;
    self.mistakesPercentLabel.text = self.viewModel.mistakes;
    self.mistakesPercentTitleLabel.text = self.viewModel.mistakesTitle;
    
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
    
    self.textLabel.text = self.viewModel.text;
    self.authorLabel.text = self.viewModel.author;
    
    [self.continueButton setTitle:self.viewModel.continueTitle forState:UIControlStateNormal];
    [self.settingsButton setTitle:self.viewModel.settingsTitle forState:UIControlStateNormal];
    [self.rateButton setTitle:self.viewModel.rateTitle forState:UIControlStateNormal];
    
    _shareButton.layer.cornerRadius = _shareButton.frame.size.height/2.0;
    _continueButton.layer.cornerRadius = _continueButton.frame.size.height/2.0;
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
}

- (void)reloadViewModel
{
    [self updateWithViewModel:self.viewModel];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.onViewWillAppear ? self.onViewWillAppear() : nil;
}

#pragma mark - IBActions

- (IBAction)onShareButtonPressed:(UIButton *)sender
{
    self.onSharePressed ? self.onSharePressed(self.textLabel.text) : nil;
}

- (IBAction)onRateButtonPressed:(UIButton *)sender
{
    self.onRatePressed ? self.onRatePressed() : nil;
}

- (IBAction)onContinueButtonPressed:(UIButton *)sender
{
    self.onContinuePressed ? self.onContinuePressed() : nil;
}

- (IBAction)onSettingsButtonPressed:(UIButton *)sender
{
    self.onSettingsPressed ? self.onSettingsPressed() : nil;
}

@end
