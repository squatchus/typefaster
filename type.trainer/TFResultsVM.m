//
//  TFResultsVM.m
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFResultsVM.h"

@implementation TFResultsVM

- (instancetype)initWithLevel:(TFLevel *)level
                       result:(TFSessionResult *)result
                        event:(TFResultEvent)event
                     provider:(TFResultProvider *)provider
{
    if (self = [super init])
    {
        int best = provider.bestSpeed;
        
        if (event == TFResultEventNewRank)
        {
            NSString *newRank = NSLocalizedString(@"results.vm.new.rank", @"Новый ранг");
            NSString *rankTitle = [provider rankTitleBySpeed:best];
            _resultTitle = [NSString stringWithFormat:@"%@ - %@!", newRank, rankTitle];
        }
        else if (event == TFResultEventNewRecord)
            _resultTitle = NSLocalizedString(@"results.vm.new.record", @"Новый рекорд!");
        else
            _resultTitle = NSLocalizedString(@"results.vm.your.result", @"Ваш результат");
        
        _bestResult = @(best).stringValue;
        _bestResultTitle = NSLocalizedString(@"results.vm.best.result", @"лучший\nрезультат");
        
        _signsPerMin = @(result.signsPerMin).stringValue;
        
        NSString *chars = [NSString localizedStringWithFormat:@"%d char(s)", result.signsPerMin];
        _signsPerMinTitle = [NSString stringWithFormat:@"%@\n%@", chars, NSLocalizedString(@"common.per.minute", @"в минуту")];
        
        int mistakesPercent = result.mistakes * 100 / (level.text.length - ([level.text componentsSeparatedByString:@"\n"].count-1));
        _mistakes = [NSString stringWithFormat:@"%d%%", mistakesPercent];
        _mistakesTitle = NSLocalizedString(@"results.vm.mistakes", @"процент\nошибок");
        
        _stars = [provider starsBySpeed:best];
        _text = level.text;
        _author = [NSString stringWithFormat:@"%@\n%@", level.title, level.author];
        
        _continueTitle = NSLocalizedString(@"results.vm.continue", @"Продолжить");
        _settingsTitle = NSLocalizedString(@"common.settings", @"Настройки");
        _rateTitle = NSLocalizedString(@"common.rate", @"Оценить");
    }
    return self;
}

@end
