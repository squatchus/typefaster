//
//  ResultsViewController.m
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "ResultsViewController.h"

@interface ResultsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *signsPerMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *mistakesPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *prevResultLabel;
@property (weak, nonatomic) IBOutlet UIImageView *starView1;
@property (weak, nonatomic) IBOutlet UIImageView *starView2;
@property (weak, nonatomic) IBOutlet UIImageView *starView3;
@property (weak, nonatomic) IBOutlet UIImageView *starView4;
@property (weak, nonatomic) IBOutlet UIImageView *starView5;

@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *shareButton;
@property (weak, nonatomic) IBOutlet UIButton *settingsButton;
@property (weak, nonatomic) IBOutlet UIButton *rateButton;


- (IBAction)onShareButtonPressed:(UIButton *)sender;
- (IBAction)onRateButtonPressed:(UIButton *)sender;
- (IBAction)onContinueButtonPressed:(UIButton *)sender;

@end

@implementation ResultsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _shareButton.layer.cornerRadius = _shareButton.frame.size.height/2.0;
    _continueButton.layer.cornerRadius = _continueButton.frame.size.height/2.0;
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
    
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    NSDictionary *level = [results lastObject][@"level"];
    int seconds = [[results lastObject][@"seconds"] intValue];
    int symbols = [[results lastObject][@"symbols"] intValue];
    int mistakes = [[results lastObject][@"mistakes"] intValue];

    int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
    int mistakesPercent = mistakes * 100 / symbols;
    NSString *subtitle = [NSString stringWithFormat:@"%@\n%@", level[@"title"], level[@"author"]];
    
    _signsPerMinLabel.text = [NSString stringWithFormat:@"%d", signsPerMin];
    _mistakesPercentLabel.text = [NSString stringWithFormat:@"%d", mistakesPercent];
    _textLabel.text = level[@"text"];
    _authorLabel.text = subtitle;
    
    if (results.count > 1) {
        int prevSeconds = [results[results.count-2][@"seconds"] intValue];
        int prevSymbols = [results[results.count-2][@"symbols"] intValue];
        int prevSignsPerMin = (int)((float)prevSymbols / (float)prevSeconds * 60.0);
        _prevResultLabel.text = [NSString stringWithFormat:@"%d", prevSignsPerMin];
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


- (IBAction)onShareButtonPressed:(UIButton *)sender {
    NSLog(@"onShareButtonPressed");
}

- (IBAction)onRateButtonPressed:(UIButton *)sender {
    NSLog(@"onRateButtonPressed");
}

- (IBAction)onContinueButtonPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

@end
