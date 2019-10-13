//
//  TFResultProvider.h
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFSessionResult.h"

typedef NS_ENUM(NSUInteger, TFRank)
{
    TFRankLevel0 = 0,
    TFRankLevel1,
    TFRankLevel2,
    TFRankLevel3,
    TFRankLevel4,
    TFRankLevel5,
    TFRankLevel6,
    TFRankLevel7,
    TFRankLevel8,
    TFRankLevel9,
    TFRankLevel10,
};

typedef NS_ENUM(NSUInteger, TFResultEvent)
{
    TFResultEventNone = 0,
    TFResultEventNewRecord,
    TFResultEventNewRank,
};

NS_ASSUME_NONNULL_BEGIN

@interface TFResultProvider : NSObject

- (TFResultEvent)saveResult:(TFSessionResult *)result;
- (void)saveScore:(int)score;

- (NSArray<TFSessionResult *> *)results;

- (int)firstSpeed;
- (int)bestSpeed;

- (TFRank)currentRank;

- (int)nextGoalBySpeed:(int)speed;
- (NSString *)rankTitleBySpeed:(int)speed;
- (float)starsBySpeed:(int)speed;

@end

NS_ASSUME_NONNULL_END
