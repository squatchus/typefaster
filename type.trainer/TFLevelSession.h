//
//  TFLevelSession.h
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFSessionResult : NSObject

@property int seconds;
@property int symbols;
@property int mistakes;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (NSDictionary *)dict;

- (int)signsPerMin;

@end

NS_ASSUME_NONNULL_END
