//
//  TFMenuVM.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFMenuVM.h"

@implementation TFMenuVM

- (instancetype)initWithResultProvider:(TFResultProvider *)results
{
    if (self = [super init])
    {
        int first = [results firstSpeed];
        int best = [results bestSpeed];
        _bestResultTitle = NSLocalizedString(@"menu.vm.best.result", @"Ваш лучший результат");
        _signsPerMin = @(best).stringValue;
        
        NSString *chars = [NSString localizedStringWithFormat:NSLocalizedString(@"%d char(s)", nil), best];
        
        for (int i=0; i<30; i++)
        {
            NSLog(@"i:%d - %@", i, [NSString localizedStringWithFormat:NSLocalizedString(@"%d char(s)", nil), i]);
        }
        
        _signsPerMinTitle = [NSString stringWithFormat:@"%@ %@", chars, NSLocalizedString(@"common.per.minute", @"в минуту")];
        
        if (first == 0 && best == 0) {
            _firstResultTitle = NSLocalizedString(@"menu.vm.complete.first", @"пройдите первую тренировку");
        } else if (first > 0 && best > first) {
            _firstResultTitle = [NSString localizedStringWithFormat:@"%@ %d", NSLocalizedString(@"menu.vm.began.with", @"а начинали со скорости"), first];
        } else {
            _firstResultTitle = NSLocalizedString(@"menu.vm.keep.training", @"продолжайте тренироваться");
        }
        _stars = [results starsBySpeed:best];
        
        NSString *rank = NSLocalizedString(@"menu.vm.rank", @"Ранг");
        NSString *rankLevel = [results rankTitleBySpeed:best];
        _rankTitle = [NSString stringWithFormat:@"%@ - %@", rank, rankLevel];
        
        int goal = [results nextGoalBySpeed:best];
        _rankSubtitle = [self rankSubtitleByGoal:goal];
        
        _typeFasterTitle = NSLocalizedString(@"menu.vm.type.faster", @"Печатать быстрее!");
        _settingsTitle = NSLocalizedString(@"common.settings", @"Настройки");
        _rateTitle = NSLocalizedString(@"common.rate", @"Оценить");
    }
    return self;
}

- (NSString *)rankSubtitleByGoal:(int)goal
{
    if (goal > 0)
    {
        NSString *chars = [NSString localizedStringWithFormat:NSLocalizedString(@"%d char(s)", nil), goal];
        NSString *perMin = NSLocalizedString(@"menu.vm.min", @"мин.");
        NSString *nextGoal = NSLocalizedString(@"menu.vm.next.goal", @"Следующая цель:");
        NSString *signsPerMin = [NSString localizedStringWithFormat:@"%d %@/%@", goal, chars, perMin];
        return [NSString stringWithFormat:@"%@ %@", nextGoal, signsPerMin];
    }
    else
    {
        return NSLocalizedString(@"menu.vm.incredible", @"Вы бесподобны :)");
    }
}

@end
