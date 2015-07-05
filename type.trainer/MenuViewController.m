//
//  MenuViewController.m
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "MenuViewController.h"
#import "UIColor+HexColor.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
    _gameCenterButton.layer.cornerRadius = _gameCenterButton.frame.size.height/2.0;
    _startTypingButton.layer.cornerRadius = _startTypingButton.frame.size.height/2.0;
    
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    for (NSDictionary *result in results) {
        int seconds = [result[@"seconds"] intValue];
        int symbols = [result[@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        if (signsPerMin > [_signsPerMinLabel.text intValue])
            _signsPerMinLabel.text = [NSString stringWithFormat:@"%d", signsPerMin];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onRateButtonPressed:(UIButton *)sender {
    NSLog(@"onRateButtonPressed");
}

- (IBAction)onGameCenterButtonPressed:(UIButton *)sender {
}

@end
