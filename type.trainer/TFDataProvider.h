//
//  DataProvider.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFLevel.h"
#import "TFLevelSession.h"
#import "TFSettingsVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFLevelProvider : NSObject

- (NSArray<TFLevelSession *> *)results;
- (void)saveResult:(TFLevelSession *)result;

- (TFLevel *)nextLevelForSettings:(TFSettingsVM *)settings;

- (float)numberOfStarsBySpeed:(int)speed;

- (int)firstResult;
- (int)bestResult;
- (int)prevBestResult;
- (NSString *)currentRank;
- (NSString *)prevRank;

@end

NS_ASSUME_NONNULL_END
