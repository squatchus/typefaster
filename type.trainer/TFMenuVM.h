//
//  TFMenuVM.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFResultProvider.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFMenuVM : NSObject

@property (nonatomic, strong, readonly) NSString *bestResultTitle;
@property (nonatomic, strong, readonly) NSString *signsPerMin;
@property (nonatomic, strong, readonly) NSString *signsPerMinTitle;
@property (nonatomic, strong, readonly) NSString *firstResultTitle;
@property (readonly) float stars;
@property (nonatomic, strong, readonly) NSString *rankTitle;
@property (nonatomic, strong, readonly) NSString *rankSubtitle;
@property (nonatomic, strong, readonly) NSString *typeFasterTitle;
@property (nonatomic, strong, readonly) NSString *settingsTitle;
@property (nonatomic, strong, readonly) NSString *rateTitle;

- (instancetype)initWithResultProvider:(TFResultProvider *)results;

@end

NS_ASSUME_NONNULL_END
