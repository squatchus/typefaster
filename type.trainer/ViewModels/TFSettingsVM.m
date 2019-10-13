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

#define kCategoryClassic @"categoryClassic"
#define kCategoryQuotes @"categoryQuotes"
#define kCategoryHokku @"categoryHokku"
#define kCategoryCookies @"categoryCookies"

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
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryClassic])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryClassic];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryQuotes])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryQuotes];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryHokku])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryHokku];
        if (![NSUserDefaults.standardUserDefaults valueForKey:kCategoryCookies])
            [NSUserDefaults.standardUserDefaults setValue:@(YES) forKey:kCategoryCookies];
        
        [NSUserDefaults.standardUserDefaults synchronize];
        
        _settingsTitle = NSLocalizedString(@"common.settings", @"Настройки");
        
        _notificationsTitle = NSLocalizedString(@"common.reminders", @"Напоминания");
        _strictTypingTitle = NSLocalizedString(@"settings.vm.strict.typing", @"Строгий режим набора");
        _notificationsInfo = NSLocalizedString(@"settings.vm.reminders.info", @"Если хотите заниматься регулярно, мы можем напоминать вам раз в день о предстоящей тренировке");
        _strictTypingInfo = NSLocalizedString(@"settings.vm.strict.typing.info", @"Не позволяет Вам набирать текст, пока не исправлена ошибка. По началу  раздражает, но очень дисциплинирует");
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

@end