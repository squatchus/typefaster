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
            NSString *newRank = NSLocalizedString(@"results.vm.new.rank", nil);
            NSString *rankTitle = [provider rankTitleBySpeed:best];
            _resultTitle = [NSString stringWithFormat:@"%@:\n%@!", newRank, rankTitle];
        }
        else if (event == TFResultEventNewRecord)
            _resultTitle = NSLocalizedString(@"results.vm.new.record", nil);
        else
            _resultTitle = NSLocalizedString(@"results.vm.your.result", nil);
        
        _bestResult = @(best).stringValue;
        _bestResultTitle = NSLocalizedString(@"results.vm.best.result", nil);
        
        _signsPerMin = @(result.signsPerMin).stringValue;
        
        NSString *chars = [NSString localizedStringWithFormat:NSLocalizedString(@"%d char(s)", nil), result.signsPerMin];
        _signsPerMinTitle = [NSString stringWithFormat:@"%@\n%@", chars, NSLocalizedString(@"common.per.minute", nil)];
        
        int mistakesPercent = result.mistakes * 100 / (level.text.length - ([level.text componentsSeparatedByString:@"\n"].count-1));
        _mistakes = [NSString stringWithFormat:@"%d%%", mistakesPercent];
        _mistakesTitle = NSLocalizedString(@"results.vm.mistakes", nil);
        
        _stars = [provider starsBySpeed:best];
        _text = level.text;
        _author = [NSString stringWithFormat:@"%@\n%@", level.title, level.author];
        
        _continueTitle = NSLocalizedString(@"results.vm.continue", nil);
        _settingsTitle = NSLocalizedString(@"common.settings", nil);
        _rateTitle = NSLocalizedString(@"common.rate", nil);
    }
    return self;
}

@end
