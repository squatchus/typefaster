//
//  MenuViewController.h
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *yourSpeedLabel;
@property (weak, nonatomic) IBOutlet UILabel *signsPerMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *signsPerMinTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *rankButton;
@property (weak, nonatomic) IBOutlet UILabel *rankHintLabel;

@property (weak, nonatomic) IBOutlet UIImageView *starView1;
@property (weak, nonatomic) IBOutlet UIImageView *starView2;
@property (weak, nonatomic) IBOutlet UIImageView *starView3;
@property (weak, nonatomic) IBOutlet UIImageView *starView4;
@property (weak, nonatomic) IBOutlet UIImageView *starView5;

@property (weak, nonatomic) IBOutlet UIButton *startTypingButton;
@property (weak, nonatomic) IBOutlet UIButton *gameCenterButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;


- (IBAction)onRateButtonPressed:(UIButton *)sender;
- (IBAction)onGameCenterButtonPressed:(UIButton *)sender;
- (IBAction)onSettingsButtonPressed:(UIButton *)sender;
- (IBAction)onPlayButtonPressed:(UIButton *)sender;

@end
