//
//  ResultsViewController.m
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "ResultsViewController.h"
#import "AppDelegate.h"
#import "TFShareView.h"
#import "Flurry.h"
#import <Crashlytics/Crashlytics.h>

@interface ResultsViewController () <UIAlertViewDelegate>

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


- (IBAction)onShareButtonPressed:(UIButton *)sender;
- (IBAction)onRateButtonPressed:(UIButton *)sender;
- (IBAction)onContinueButtonPressed:(UIButton *)sender;
- (IBAction)onSettingsButtonPressed:(UIButton *)sender;

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
    
    int bestResult = [AppDelegate bestResult];
    _bestResultLabel.text = [NSString stringWithFormat:@"%d", bestResult];

    BOOL switchToFullKeyboardJustHappened = NO;
    NSString *currentRank = [AppDelegate currentRank];
    if (signsPerMin < bestResult) {
        _resultTitleLabel.text = @"Ваш результат";
    }
    else if ([currentRank isEqualToString:[AppDelegate prevRank]]) {
        _resultTitleLabel.text = @"Новый рекорд!"; // в текущем ранге
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playNewResultSound];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) reportScore];
    }
    else { // новый ранг
        _resultTitleLabel.text = [NSString stringWithFormat:@"Новый ранг - %@!", currentRank];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playNewRankSound];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) reportScore];
        
        NSDictionary *params = @{@"rank": currentRank,
                                 @"highestScores": @([AppDelegate numberOfHighestScores]),
                                 @"summaryTime": @([AppDelegate summaryTimeOfAllTrainings])};
        [Flurry logEvent:@"NewRank achieved" withParameters:params];
        [Answers logCustomEventWithName:@"NewRank achieved" customAttributes:params];
        
        if (signsPerMin >= 100) { // switch to full keyboard
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"fullKeyboard"] boolValue]) {
                [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"fullKeyboard"];
                switchToFullKeyboardJustHappened = YES;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ура!" message:@"Вы преодолели этап обучения! Продолжайте увеличивать скорость\nна полной клавиатуре (включающей знаки препинания)" delegate:nil cancelButtonTitle:@"Поехали!" otherButtonTitles: nil];
                [alert show];
            }
        }
    }
    
    if (!switchToFullKeyboardJustHappened) {
        if (results.count == 1 && signsPerMin < 100) {
            [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"fullKeyboard"];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Результат" message:@"Ваш результат меньше 100 знаков в минуту. Попробуйте его улучшить в режиме обучения\n(нет знаков препинания, количество букв ограничено)" delegate:nil cancelButtonTitle:@"Поехали!" otherButtonTitles: nil];
            [alert show];
        }
        else if (results.count == 3) {
            if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"notifications"] boolValue]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Напоминания" message:@"Регулярные тренировки помогут быстрее развить скорость печати. Напоминать о них\n1 раз в день?" delegate:self cancelButtonTitle:@"Нет" otherButtonTitles: @"Напоминать", nil];
                [alert show];
            }
        }
    }
    
    [self updateStarsBySpeed:signsPerMin];
    
    if (IS_IPHONE_6 || IS_IPHONE_6P) {
        _resultTitleLabel.font = [_resultTitleLabel.font fontWithSize:16];
        
        _bestResultTitleLabel.font = [_bestResultTitleLabel.font fontWithSize:16];
        _signsPerMinTitleLabel.font = [_signsPerMinTitleLabel.font fontWithSize:16];
        _mistakesPercentTitleLabel.font = [_mistakesPercentTitleLabel.font fontWithSize:16];
        _authorLabel.font = [_authorLabel.font fontWithSize:14];
    
        _rateButton.titleLabel.font = [_rateButton.titleLabel.font fontWithSize:14];
        _settingsButton.titleLabel.font = [_settingsButton.titleLabel.font fontWithSize:14];
        _starWidthConstraint.constant = 35;
        _starHeightConstraint.constant = 32;
        [_settingsButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [[NSUserDefaults standardUserDefaults] setValue:@(YES) forKey:@"notifications"];
        [AppDelegate enableNotifications];
    }
    else {
        [[NSUserDefaults standardUserDefaults] setValue:@(NO) forKey:@"notifications"];
        [AppDelegate disableNotifications];
    }
}

- (void)updateStarsBySpeed:(int)speed {
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
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    
    NSMutableArray *results = [[NSUserDefaults standardUserDefaults] objectForKey:@"results"];
    NSDictionary *level = [results lastObject][@"level"];
    
    TFShareView *shareView = [[NSBundle mainBundle] loadNibNamed:@"TFShareView" owner:self options:nil][0];
    shareView.frame = self.view.frame;
    [shareView updateWithText:level[@"text"] author:level[@"author"] andSpeed:[AppDelegate bestResult]];
    UIImage *image = [shareView renderImage];
    
    NSString *text = @"Я увеличил свою скорость печати с приложением #ПечатайБыстрее";
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/app/id1013588476"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url, image]
     applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop];

    NSNumber *contentId = @([AppDelegate levelIdentifierByText:level[@"text"]]);
    NSInteger firstNewLine = [level[@"text"] rangeOfString:@"\n"].location;
    NSString *contentName = [level[@"text"] substringToIndex:MIN(30, firstNewLine)];
    
    [Flurry logEvent:@"ShareButton Clicked" withParameters:@{@"author": level[@"author"], @"text": level[@"text"], @"category": level[@"category"]}];
    [Answers logCustomEventWithName:@"ShareButton Clicked" customAttributes:@{@"name": contentName, @"type": level[@"category"], @"id": contentId}];
    
    [controller setCompletionHandler:^(NSString *activityType, BOOL completed) {
        [Flurry logEvent:@"ContentShared" withParameters:@{@"share-method": activityType, @"name": contentName, @"type": level[@"category"], @"id": contentId, @"completed": @(completed)}];
        [Answers logShareWithMethod:activityType contentName:@"" contentType:level[@"category"] contentId:[contentId stringValue] customAttributes:@{@"completed": @(completed)}];
    }];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onRateButtonPressed:(UIButton *)sender {
    [Flurry logEvent:@"RateButton clicked"];
    [Answers logCustomEventWithName:@"RateButton clicked" customAttributes:nil];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    NSString *urlString = @"itms-apps://itunes.apple.com/app/id1013588476";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

- (IBAction)onContinueButtonPressed:(UIButton *)sender {
    [Flurry logEvent:@"ContinueButton clicked"];
    [Answers logCustomEventWithName:@"ContinueButton clicked" customAttributes:nil];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSettingsButtonPressed:(UIButton *)sender {
    [Flurry logEvent:@"SettingsButton clicked"];
    [Answers logCustomEventWithName:@"SettingsButton clicked" customAttributes:nil];
    
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self performSegueWithIdentifier:@"resultsToSettings" sender:self];
}

@end
