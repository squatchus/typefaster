//
//  SettingsService.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFSettingsVM.h"

#define kBestScore @"gameCenterScore"

#define kNotifications @"notifications"
#define kStrictTyping @"strictTyping"

#define kCategoryClassic @"categoryClassic"
#define kCategoryQuotes @"categoryQuotes"
#define kCategoryHokku @"categoryHokku"
#define kCategoryCookies @"categoryCookies"

@implementation TFSettingsVM

- (instancetype)init
{
    if (self = [super init])
    {
        if ([NSUserDefaults.standardUserDefaults valueForKey:kBestScore])
            self.bestScore = [[NSUserDefaults.standardUserDefaults valueForKey:kBestScore] intValue];
        
        // Update switcher's settings in UserDefaults
        //
        if (![NSUserDefaults.standardUserDefaults valueForKey:kNotifications])
            [NSUserDefaults.standardUserDefaults setValue:@(NO) forKey:kNotifications];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kStrictTyping])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kStrictTyping];
                
        // Update button's settings in UserDefaults
        //
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryClassic])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryClassic];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryQuotes])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryQuotes];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryHokku])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryHokku];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryCookies])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryCookies];
        
        [NSUserDefaults.standardUserDefaults synchronize];
    }
    return self;
}

- (void)setBestScore:(int)bestScore
{
    [NSUserDefaults.standardUserDefaults setInteger:bestScore forKey:kBestScore];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (int)bestScore
{
    return (int)[NSUserDefaults.standardUserDefaults integerForKey:kBestScore];
}

- (void)setNotifications:(BOOL)notifications
{
    [NSUserDefaults.standardUserDefaults setBool:notifications forKey:kNotifications];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (BOOL)notifications
{
    return [NSUserDefaults.standardUserDefaults boolForKey:kNotifications];
}

- (void)setStrictTyping:(BOOL)strictTyping
{
    [NSUserDefaults.standardUserDefaults setBool:strictTyping forKey:kStrictTyping];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (BOOL)strictTyping
{
    return [NSUserDefaults.standardUserDefaults boolForKey:kStrictTyping];
}

- (void)setCategoryClassic:(BOOL)categoryClassic
{
    [NSUserDefaults.standardUserDefaults setBool:categoryClassic forKey:kCategoryClassic];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (BOOL)categoryClassic
{
    return [NSUserDefaults.standardUserDefaults boolForKey:kCategoryClassic];
}

- (void)setCategoryQuotes:(BOOL)categoryQuotes
{
    [NSUserDefaults.standardUserDefaults setBool:categoryQuotes forKey:kCategoryQuotes];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (BOOL)categoryQuotes
{
    return [NSUserDefaults.standardUserDefaults boolForKey:kCategoryQuotes];
}

- (void)setCategoryHokku:(BOOL)categoryHokku
{
    [NSUserDefaults.standardUserDefaults setBool:categoryHokku forKey:kCategoryHokku];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (BOOL)categoryHokku
{
    return [NSUserDefaults.standardUserDefaults boolForKey:kCategoryHokku];
}

- (void)setCategoryCookies:(BOOL)categoryCookies
{
    [NSUserDefaults.standardUserDefaults setBool:categoryCookies forKey:kCategoryCookies];
    [NSUserDefaults.standardUserDefaults synchronize];
}
- (BOOL)categoryCookies
{
    return [NSUserDefaults.standardUserDefaults boolForKey:kCategoryCookies];
}

@end
