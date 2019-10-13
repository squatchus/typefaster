//
//  TFResultProvider.m
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFResultProvider.h"

@implementation TFResultProvider

- (instancetype)init
{
    if (self = [super init])
    {
        [self ifNeededMigrateTo_1_1];
    }
    return self;
}

- (NSArray<TFSessionResult *> *)results
{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSArray *results = [defaults objectForKey:@"results"];
    NSMutableArray *sessions = [NSMutableArray new];
    for (NSDictionary *dict in results)
    {
        TFSessionResult *session = [[TFSessionResult alloc] initWithDict:dict];
        [sessions addObject:session];
    }
    return sessions.copy;
}

- (TFResultEvent)saveResult:(TFSessionResult *)result
{
    int prevRecord = self.bestSpeed;
    TFRank prevRank = self.currentRank;
    
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSMutableArray *results = [[defaults objectForKey:@"results"] mutableCopy];
    if (!results) results = [NSMutableArray new];
    [results addObject:result.dict];
    [defaults setValue:results forKey:@"results"];
    [defaults synchronize];
    
    BOOL newRecord = (result.signsPerMin > prevRecord);
    BOOL newRank = (self.currentRank > prevRank);
    
    if (newRecord && newRank)
        return TFResultEventNewRank;
    else if (newRecord)
        return TFResultEventNewRecord;
    else
        return TFResultEventNone;
}

- (void)saveScore:(int)score
{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setValue:@(score) forKey:@"gameCenterScore"];
    [defaults synchronize];
}

- (void)ifNeededMigrateTo_1_1
{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSMutableArray *migratedTo = [[defaults objectForKey:@"migratedTo"] mutableCopy];
    if (!migratedTo) migratedTo = [NSMutableArray new];
    if ([migratedTo containsObject:@"1.1"] == NO)
    {
        NSArray *results = [defaults objectForKey:@"results"];
        NSMutableArray *newResults = [NSMutableArray new];
        for (NSDictionary *dict in results)
        {
            NSMutableDictionary *newDict = dict.mutableCopy;
            [newDict removeObjectForKey:@"level"];
            [newResults addObject:newDict];
        }
        [defaults setValue:newResults forKey:@"results"];
        [migratedTo addObject:@"1.1"];
        [defaults setObject:migratedTo forKey:@"migratedTo"];
        [defaults synchronize];
    }
}

- (int)firstSpeed
{
    NSArray<TFSessionResult *> *results = self.results;
    if (results && results.count > 0)
    {
        return results.firstObject.signsPerMin;
    }
    return 0;
}

- (int)bestSpeed
{
    int maxSpeed = 0;
    NSArray<TFSessionResult *> *results = self.results;
    for (TFSessionResult *result in results)
    {
        if (result.signsPerMin > maxSpeed)
        {
            maxSpeed = result.signsPerMin;
        }
    }
    int score = [[NSUserDefaults.standardUserDefaults objectForKey:@"gameCenterScore"] intValue];
    return MAX(maxSpeed, score);
}

- (TFRank)currentRank
{
    return [self rankBySpeed:[self bestSpeed]];
}

- (int)nextGoalBySpeed:(int)speed
{
    TFRank rank = [self rankBySpeed:speed];
    if (rank < TFRankLevel10)
    {
        TFRank nextRank = (TFRank)((NSUInteger)rank+1);
        int nextMinValue = [self minValueForRank:nextRank];
        int nextMaxValue = [self maxValueForRank:nextRank];
        int goal = (speed < nextMinValue) ? nextMinValue : nextMaxValue;
        return goal;
    }
    return 0;
}

- (NSString *)rankTitleBySpeed:(int)speed
{
    TFRank rank = [self rankBySpeed:speed];
    NSString *rankTitle = @[NSLocalizedString(@"rank.lvl.0", nil),
                            NSLocalizedString(@"rank.lvl.1", nil),
                            NSLocalizedString(@"rank.lvl.2", nil),
                            NSLocalizedString(@"rank.lvl.3", nil),
                            NSLocalizedString(@"rank.lvl.4", nil),
                            NSLocalizedString(@"rank.lvl.5", nil),
                            NSLocalizedString(@"rank.lvl.6", nil),
                            NSLocalizedString(@"rank.lvl.7", nil),
                            NSLocalizedString(@"rank.lvl.8", nil),
                            NSLocalizedString(@"rank.lvl.9", nil),
                            NSLocalizedString(@"rank.lvl.10", nil)][rank];
    return rankTitle;
}

- (TFRank)rankBySpeed:(int)speed
{
    if (speed < 30) return TFRankLevel0;        // [0..29]
    else if (speed < 40) return TFRankLevel1;   // [30..39]
    else if (speed < 55) return TFRankLevel2;   // [40..54]
    else if (speed < 75) return TFRankLevel3;   // [55..74]
    else if (speed < 100) return TFRankLevel4;  // [75..99]
    else if (speed < 130) return TFRankLevel5;  // [100..129]
    else if (speed < 165) return TFRankLevel6;  // [130..164]
    else if (speed < 205) return TFRankLevel7;  // [165..204]
    else if (speed < 250) return TFRankLevel8;  // [204..249]
    else if (speed < 300) return TFRankLevel9;  // [250..299]
    else return TFRankLevel10;
}

- (int)minValueForRank:(TFRank)rank
{
    int maxValue = [@[@0, @30, @40, @55, @75, @100, @130, @165, @205, @250, @350][rank] intValue];
    return maxValue;
}

- (int)maxValueForRank:(TFRank)rank
{
    int maxValue = [@[@30, @40, @55, @75, @100, @130, @165, @205, @250, @300, @400][rank] intValue];
    return maxValue;
}

- (float)starsBySpeed:(int)speed
{
    NSArray *starRatings = @[@0, @0.5, @1, @1.5, @2, @2.5, @3, @3.5, @4, @4.5, @5]; // 11
    TFRank rank = [self rankBySpeed:speed];
    int maxValue = [self maxValueForRank:rank];
    float percent = MIN(100, (float)speed * 100.0 / (float)maxValue);
    int index = percent/10;
    float numberOfStars = [starRatings[index] floatValue];
    return numberOfStars;
}

@end
