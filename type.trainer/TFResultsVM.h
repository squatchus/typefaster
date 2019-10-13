//
//  TFResultsVM.h
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFLevel.h"
#import "TFResultProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFResultsVM : NSObject

@property (nonatomic, strong, readonly) NSString *resultTitle;
@property (nonatomic, strong, readonly) NSString *bestResult;
@property (nonatomic, strong, readonly) NSString *bestResultTitle;
@property (nonatomic, strong, readonly) NSString *signsPerMin;
@property (nonatomic, strong, readonly) NSString *signsPerMinTitle;
@property (nonatomic, strong, readonly) NSString *mistakes;
@property (nonatomic, strong, readonly) NSString *mistakesTitle;
@property (readonly) float stars;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *author;

@property (nonatomic, strong, readonly) NSString *continueTitle;
@property (nonatomic, strong, readonly) NSString *settingsTitle;
@property (nonatomic, strong, readonly) NSString *rateTitle;

- (instancetype)initWithLevel:(TFLevel *)level
                       result:(TFSessionResult *)result
                        event:(TFResultEvent)event
                     provider:(TFResultProvider *)results;

@end

NS_ASSUME_NONNULL_END
