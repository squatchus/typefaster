//
//  ResultsViewController.m
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "ResultsViewController.h"
#import "AppDelegate.h"

@interface ResultsViewController ()

@property (weak, nonatomic) IBOutlet UILabel *resultTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *signsPerMinLabel;
@property (weak, nonatomic) IBOutlet UILabel *mistakesPercentLabel;
@property (weak, nonatomic) IBOutlet UILabel *bestResultLabel;
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
    
    int bestResult = [AppDelegate bestResult];
    _bestResultLabel.text = [NSString stringWithFormat:@"%d", bestResult];

    NSString *currentRank = [AppDelegate currentRank];
    if (signsPerMin < bestResult) {
        _resultTitleLabel.text = @"Ваш результат";
    }
    else if ([currentRank isEqualToString:[AppDelegate prevRank]]) {
        _resultTitleLabel.text = @"Новый рекорд!";
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playNewResultSound];
    }
    else {
        _resultTitleLabel.text = [NSString stringWithFormat:@"Новый ранг - %@!", currentRank];
        [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playNewRankSound];
    }
    
    [self updateStarsBySpeed:signsPerMin];
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

    NSString *text = @"Я увеличил свою скорость печати с приложением #ПечатайБыстрее";
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/ru/app/id436693646/"];
    UIImage *image = [UIImage imageNamed:@"keyboard_background.png"];
    
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:@[text, url, image]
     applicationActivities:nil];
    
    controller.excludedActivityTypes = @[UIActivityTypePostToWeibo,
                                         UIActivityTypePrint,
                                         UIActivityTypeCopyToPasteboard,
                                         UIActivityTypeAssignToContact,
                                         UIActivityTypeSaveToCameraRoll,
                                         UIActivityTypeAddToReadingList,
                                         UIActivityTypePostToVimeo,
                                         UIActivityTypePostToTencentWeibo,
                                         UIActivityTypeAirDrop];
    
    [self presentViewController:controller animated:YES completion:nil];
}

- (IBAction)onRateButtonPressed:(UIButton *)sender {
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    NSLog(@"onRateButtonPressed");
}

- (IBAction)onContinueButtonPressed:(UIButton *)sender {
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onSettingsButtonPressed:(UIButton *)sender {
    [((AppDelegate *)[[UIApplication sharedApplication] delegate]) playButtonClickSound];
    [self performSegueWithIdentifier:@"resultsToSettings" sender:self];
}

@end
