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

- (NSString *)rankTitleBySpeed:(int)speed {
    if (speed < 30) return @"Новичек";              // [0..29]
    else if (speed < 40) return @"Ученик";          // [30..39]
    else if (speed < 55) return @"Освоившийся";     // [40..54]
    else if (speed < 75) return @"Уверенный";       // [55..74]
    else if (speed < 100) return @"Опытный";        // [75..99]
    else if (speed < 130) return @"Бывалый";        // [100..129]
    else if (speed < 165) return @"Продвинутый";    // [130..164]
    else if (speed < 205) return @"Мастер";         // [165..204]
    else if (speed < 250) return @"Гуру";           // [204..249]
    else return @"Запредельный";                    // [250..250+]
}

- (int)minValueForRank:(NSString *)rankString {
    NSDictionary *maxValues = @{@"Новичек": @0,
                                @"Ученик": @30,
                                @"Освоившийся": @40,
                                @"Уверенный": @55,
                                @"Опытный": @75,
                                @"Бывалый": @100,
                                @"Продвинутый": @130,
                                @"Мастер": @165,
                                @"Гуру": @205,
                                @"Запредельный": @250};
    return [maxValues[rankString] intValue];
}

- (int)maxValueForRank:(NSString *)rankString {
    NSDictionary *maxValues = @{@"Новичек": @30,
                                @"Ученик": @40,
                                @"Освоившийся": @55,
                                @"Уверенный": @75,
                                @"Опытный": @100,
                                @"Бывалый": @130,
                                @"Продвинутый": @165,
                                @"Мастер": @205,
                                @"Гуру": @250,
                                @"Запредельный": @300};
    return [maxValues[rankString] intValue];
}

- (NSString *)nextRankForRank:(NSString *)rankString {
    NSArray *ranks = @[@"Новичек", @"Ученик", @"Освоившийся", @"Уверенный", @"Опытный", @"Бывалый", @"Продвинутый", @"Мастер", @"Гуру", @"Запредельный"];
    int index = [ranks indexOfObject:rankString];
    index++;
    if (index < ranks.count) return ranks[index];
    return nil;
}

- (void)updateStarsBySpeed:(int)speed {
    NSArray *starRatings = @[@0, @0.5, @1, @1.5, @2, @2.5, @3, @3.5, @4, @4.5, @5]; // 11
    NSString *rankString = [self rankTitleBySpeed:[_signsPerMinLabel.text intValue]];
    NSString *buttonTitle = [NSString stringWithFormat:@"Ранг - %@", rankString];
    [_gameCenterButton setTitle:buttonTitle forState:UIControlStateNormal];
    int maxValue = [self maxValueForRank:rankString];
    float percent = (float)speed * 100.0 / (float)maxValue;
    int index = percent/10;
    float numberOfStars = [starRatings[index] floatValue];
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
    
    NSString *nextRank = [self nextRankForRank:rankString];
    if (nextRank) {
        int nextMinValue = [self minValueForRank:nextRank];
        int nextMaxValue = [self maxValueForRank:nextRank];
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
