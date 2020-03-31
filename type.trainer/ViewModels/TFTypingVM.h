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

typedef NS_ENUM(NSUInteger, InputResult) {
    InputResultImpossible,
    InputResultMistaken,
    InputResultCorrect,
};

NS_ASSUME_NONNULL_BEGIN

@interface TFTypingVM : NSObject

@property (nonatomic, copy) void (^onSessionStarted)(void);
@property (nonatomic, copy) void (^onSessionEnded)(void);
@property (nonatomic, copy) void (^onTimerUpdated)(int min, int sec);

@property (nonatomic, strong, readonly) NSString *completeTitle;
@property (nonatomic, strong, readonly) TFLevel *level;
@property (nonatomic, strong, readonly) TFSessionResult *result;
@property (readonly) BOOL strictTyping;

- (instancetype)initWithLevel:(TFLevel *)level
                 strictTyping:(BOOL)strictTyping;

- (InputResult)processInput:(NSString *)input range:(NSRange)range;

- (BOOL)shiftHidden;
- (BOOL)backspaceHidden;

- (NSString *)symbolsEnteredString;
- (NSRange)getCursorRange;
- (NSAttributedString *)getText;
- (NSAttributedString *)getCurrentWord;

@end

NS_ASSUME_NONNULL_END
