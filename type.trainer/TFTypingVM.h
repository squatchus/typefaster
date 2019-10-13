//
//  TFTypingVM.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFLevel.h"
#import "TFSessionResult.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFTypingVM : NSObject

@property (nonatomic, strong, readonly) TFLevel *level;
@property (nonatomic, strong, readonly) TFSessionResult *result;
@property (readonly) BOOL strictTyping;

- (instancetype)initWithLevel:(TFLevel *)level
                 strictTyping:(BOOL)strictTyping;

@end

NS_ASSUME_NONNULL_END
