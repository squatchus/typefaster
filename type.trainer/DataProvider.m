//
//  DataProvider.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFDataProvider.h"

#import "AppDelegate.h"

@implementation TFDataProvider

- (float)numberOfStarsBySpeed:(int)speed
{
    NSArray *starRatings = @[@0, @0.5, @1, @1.5, @2, @2.5, @3, @3.5, @4, @4.5, @5]; // 11
    NSString *rankString = [self currentRank];
    int maxValue = [self maxValueForRank:rankString];
    float percent = MIN(100, (float)speed * 100.0 / (float)maxValue);
    int index = percent/10;
    float numberOfStars = [starRatings[index] floatValue];
    return numberOfStars;
}

- (NSString *)rankTitleBySpeed:(int)speed
{
    if (speed < 30) return @"Новичек";              // [0..29]
    else if (speed < 40) return @"Ученик";          // [30..39]
    else if (speed < 55) return @"Освоившийся";     // [40..54]
    else if (speed < 75) return @"Уверенный";       // [55..74]
    else if (speed < 100) return @"Опытный";        // [75..99]
    else if (speed < 130) return @"Бывалый";        // [100..129]
    else if (speed < 165) return @"Продвинутый";    // [130..164]
    else if (speed < 205) return @"Мастер";         // [165..204]
    else if (speed < 250) return @"Гуру";           // [204..249]
    else if (speed < 300) return @"Запредельный";   // [250..299]
    else return @"Ну очень быстрый";
}

- (int)minValueForRank:(NSString *)rankString
{
    NSDictionary *maxValues = @{@"Новичек": @0,
                                @"Ученик": @30,
                                @"Освоившийся": @40,
                                @"Уверенный": @55,
                                @"Опытный": @75,
                                @"Бывалый": @100,
                                @"Продвинутый": @130,
                                @"Мастер": @165,
                                @"Гуру": @205,
                                @"Запредельный": @250,
                                @"Ну очень быстрый": @350};
    return [maxValues[rankString] intValue];
}

- (int)maxValueForRank:(NSString *)rankString
{
    NSDictionary *maxValues = @{@"Новичек": @30,
                                @"Ученик": @40,
                                @"Освоившийся": @55,
                                @"Уверенный": @75,
                                @"Опытный": @100,
                                @"Бывалый": @130,
                                @"Продвинутый": @165,
                                @"Мастер": @205,
                                @"Гуру": @250,
                                @"Запредельный": @300,
                                @"Ну очень быстрый": @400};
    return [maxValues[rankString] intValue];
}

- (NSString *)rankAfterRank:(NSString *)rankString
{
    NSArray *ranks = @[@"Новичек", @"Ученик", @"Освоившийся", @"Уверенный", @"Опытный", @"Бывалый", @"Продвинутый", @"Мастер", @"Гуру", @"Запредельный", @"Ну очень быстрый"];
    NSInteger index = [ranks indexOfObject:rankString];
    index++;
    if (index < ranks.count) return ranks[index];
    return nil;
}

- (int)firstResult {
    NSArray *results = [NSUserDefaults.standardUserDefaults objectForKey:@"results"];
    if (results && results.count > 0) {
        int seconds = [[results firstObject][@"seconds"] intValue];
        int symbols = [[results firstObject][@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        return signsPerMin;
    }
    return 0;
}

- (int)bestResult {
    int maxSpeed = 0;
    NSArray *results = [NSUserDefaults.standardUserDefaults objectForKey:@"results"];
    for (NSDictionary *result in results) {
        int seconds = [result[@"seconds"] intValue];
        int symbols = [result[@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        if (signsPerMin > maxSpeed)
            maxSpeed = signsPerMin;
    }
    
    return MAX(maxSpeed, APP.leaderboards.gameCenterScore);
}

- (int)prevBestResult {
    int maxSpeed = 0;
    NSArray *results = [NSUserDefaults.standardUserDefaults objectForKey:@"results"];
    for (NSDictionary *result in results) {
        if (result == results.lastObject) break;
        int seconds = [result[@"seconds"] intValue];
        int symbols = [result[@"symbols"] intValue];
        int signsPerMin = (int)((float)symbols / (float)seconds * 60.0);
        if (signsPerMin > maxSpeed)
            maxSpeed = signsPerMin;
    }
    return maxSpeed;
}

- (NSString *)currentRank {
    return [self rankTitleBySpeed:[self bestResult]];
}

- (NSString *)prevRank {
    return [self rankTitleBySpeed:[self prevBestResult]];
}

@end
