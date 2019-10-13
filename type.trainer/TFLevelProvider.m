//
//  DataProvider.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFLevelProvider.h"

#import "TFAppDelegate.h"

@implementation TFLevelProvider

- (TFLevel *)nextLevelForSettings:(TFSettingsVM *)settings;
{
    NSMutableArray *disabledCategories = [NSMutableArray new];
    if (!settings.categoryClassic) [disabledCategories addObject:@"categoryClassic"];
    if (!settings.categoryCookies) [disabledCategories addObject:@"categoryCookies"];
    if (!settings.categoryQuotes) [disabledCategories addObject:@"categoryQuotes"];
    if (!settings.categoryHokku) [disabledCategories addObject:@"categoryHokku"];
    
    NSMutableArray<TFLevel *> *allowedLevels = [NSMutableArray new];
    for (TFLevel *level in [self levels]) {
        BOOL allowed = ([disabledCategories containsObject:level.category] == NO);
        if (allowed || disabledCategories.count == 4)
        {
            [allowedLevels addObject:level];
        }
    }
    
    int level_num = 0;
    NSNumber *prev_num = [NSUserDefaults.standardUserDefaults valueForKey:@"prevLevel"];
    if (prev_num)
    {
        int new_num = [prev_num intValue]+1;
        if (new_num < allowedLevels.count) {
            level_num = new_num;
        }
    }
    [NSUserDefaults.standardUserDefaults setValue:@(level_num) forKey:@"prevLevel"];
    [NSUserDefaults.standardUserDefaults synchronize];
    NSLog(@"LEVEL LOADED: %d/%d (%@)", level_num, (int)allowedLevels.count, allowedLevels[level_num].category);
    
    return allowedLevels[level_num];
}

- (NSMutableArray<TFLevel *> *)levels
{
    NSMutableArray *levels = [NSMutableArray new];
    NSString *filePath = [NSBundle.mainBundle pathForResource:@"Levels" ofType:@"plist"];
    for (NSDictionary *dict in [NSArray arrayWithContentsOfFile:filePath])
    {
        TFLevel *lvl = [[TFLevel alloc] initWithDict:dict];
        [levels addObject:lvl];
    }
    return levels;
}

@end
