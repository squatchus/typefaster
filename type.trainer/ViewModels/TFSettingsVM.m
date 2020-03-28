//
//  SettingsService.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFSettingsVM.h"

#define kNotifications @"notifications"
#define kStrictTyping @"strictTyping"

@implementation TFSettingsVM

- (instancetype)init
{
    if (self = [super init])
    {
        // Update switcher's settings in UserDefaults
        //
        if (![NSUserDefaults.standardUserDefaults valueForKey:kNotifications])
            [NSUserDefaults.standardUserDefaults setValue:@(NO) forKey:kNotifications];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kStrictTyping])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kStrictTyping];
        
        // Update button's settings in UserDefaults
        //
        NSString *langCode = NSBundle.mainBundle.preferredLocalizations.firstObject;
        BOOL showEngTexts = [langCode isEqualToString:@"en"];

        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryClassic])
            [NSUserDefaults.standardUserDefaults setValue:@(showEngTexts ? NO : YES) forKey:kCategoryClassic];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryQuotes])
            [NSUserDefaults.standardUserDefaults setValue:@(showEngTexts ? NO : YES) forKey:kCategoryQuotes];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryHokku])
            [NSUserDefaults.standardUserDefaults setValue:@(showEngTexts ? NO : YES) forKey:kCategoryHokku];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryCookies])
            [NSUserDefaults.standardUserDefaults setValue:@(showEngTexts ? NO : YES) forKey:kCategoryCookies];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryEnglish])
        [NSUserDefaults.standardUserDefaults setValue:@(showEngTexts ? YES : NO) forKey:kCategoryEnglish];
        
        [NSUserDefaults.standardUserDefaults synchronize];
        
        _settingsTitle = NSLocalizedString(@"common.settings", nil);
        
        _notificationsTitle = NSLocalizedString(@"common.reminders", nil);
        _strictTypingTitle = NSLocalizedString(@"settings.vm.strict.typing", nil);
        _notificationsInfo = NSLocalizedString(@"settings.vm.reminders.info", nil);
        _strictTypingInfo = NSLocalizedString(@"settings.vm.strict.typing.info", nil);
        _doneTitle = NSLocalizedString(@"button.done", nil);
    }
    return self;
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

- (void)setCategoryEnglish:(BOOL)categoryEnglish
{
    [NSUserDefaults.standardUserDefaults setBool:categoryEnglish forKey:kCategoryEnglish];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (BOOL)categoryEnglish
{
    return [NSUserDefaults.standardUserDefaults boolForKey:kCategoryEnglish];
}

@end
