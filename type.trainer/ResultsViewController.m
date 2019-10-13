//
//  ResultsViewController.m
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "TFResultsVC.h"

#import "TFAppDelegate.h"
#import "UIAlertController+Alerts.h"

@interface TFResultsVC ()

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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _shareButton.layer.cornerRadius = _shareButton.frame.size.height/2.0;
    _continueButton.layer.cornerRadius = _continueButton.frame.size.height/2.0;
    _rateButton.layer.cornerRadius = _rateButton.frame.size.height/2.0;
    _settingsButton.layer.cornerRadius = _settingsButton.frame.size.height/2.0;
    
    NSMutableArray *results = [NSUserDefaults.standardUserDefaults objectForKey:@"results"];
    NSDictionary *level = [results lastObject][@"level"];
    NSString *text = level[@"text"];
    int seconds = [[results lastObject][@"seconds"] intValue];
    int symbols = [[results lastObject][@"symbols"] intValue];
    int mistakes = [[results lastObject][@"mistakes"] intValue];

    int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
    int mistakesPercent = mistakes * 100 / (text.length - ([text componentsSeparatedByString:@"\n"].count-1));
    NSString *subtitle = [NSString stringWithFormat:@"%@\n%@", level[@"title"], level[@"author"]];
    
    _signsPerMinLabel.text = [NSString stringWithFormat:@"%d", signsPerMin];
    _mistakesPercentLabel.text = [NSString stringWithFormat:@"%d", mistakesPercent];
    _textLabel.text = text;
    _authorLabel.text = subtitle;
    
    int lastDigit = signsPerMin % 10;
    NSString *ending = (lastDigit == 1)?@"":((lastDigit > 1 && lastDigit < 5)?@"а":@"ов");
    _signsPerMinTitleLabel.text = [NSString stringWithFormat:@"знак%@\nв минуту", ending];
    
    int bestResult = [APP.data bestResult];
    _bestResultLabel.text = [NSString stringWithFormat:@"%d", bestResult];

    NSString *currentRank = [APP.data currentRank];
    if (signsPerMin < bestResult) {
        _resultTitleLabel.text = NSLocalizedString(@"Ваш результат", nil);
    }
    else if ([currentRank isEqualToString:[APP.data prevRank]]) {
        _resultTitleLabel.text = NSLocalizedString(@"Новый рекорд!", nil); // в текущем ранге
        [APP.sounds playNewResultSound];
        [APP submitBestResultToLeaderboard];
    }
    else { // новый ранг
        _resultTitleLabel.text = [NSString stringWithFormat:@"Новый ранг - %@!", currentRank];
        [APP.sounds playNewRankSound];
        [APP submitBestResultToLeaderboard];
    }
        if (results.count == 3) {
            if (!APP.settings.notifications) {
                [UIAlertController showReminMeAlertWithHandler:^(BOOL remind) {
                    if (remind) {
                        APP.settings.notifications = YES;
                        [APP.reminder enableNotifications];
                    }
                    else {
                        APP.settings.notifications = NO;
                        [APP.reminder disableNotifications];
                    }
                }];
            }
        }
    
    [self updateStarsBySpeed:signsPerMin];
}

- (void)updateStarsBySpeed:(int)speed
{
    float numberOfStars = [APP.data numberOfStarsBySpeed:speed];
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
}

- (IBAction)onShareButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    
    NSMutableArray *results = [NSUserDefaults.standardUserDefaults objectForKey:@"results"];
    NSDictionary *level = [results lastObject][@"level"];
    
    NSString *text = level[@"text"];
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/app/id1013588476"];
    
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text, url] applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onRateButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1013588476"];
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (IBAction)onContinueButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSettingsButtonPressed:(UIButton *)sender
{
    [APP.sounds playButtonClickSound];
    [self performSegueWithIdentifier:@"resultsToSettings" sender:self];
}

@end
