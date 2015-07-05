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

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
    _gameCenterButton.layer.cornerRadius = _gameCenterButton.frame.size.height/2.0;
    _startTypingButton.layer.cornerRadius = _startTypingButton.frame.size.height/2.0;
}

- (void)viewWillAppear:(BOOL)animated {
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        int seconds = [result[@"seconds"] intValue];
        int symbols = [result[@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        if (signsPerMin > [_signsPerMinLabel.text intValue])
            _signsPerMinLabel.text = [NSString stringWithFormat:@"%d", signsPerMin];
    }
    
    [self updateStarsBySpeed:[_signsPerMinLabel.text intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateStarsBySpeed:(int)speed {
    NSString *rankString = [AppDelegate rankTitleBySpeed:[_signsPerMinLabel.text intValue]];
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
    NSLog(@"onRateButtonPressed");
}

- (IBAction)onGameCenterButtonPressed:(UIButton *)sender {
    NSLog(@"onGameCenterButtonPressed");
}

@end
