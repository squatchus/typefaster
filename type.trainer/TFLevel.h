//
//  TFLevel.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TFToken.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFLevel : NSObject

@property (nonatomic, strong, readonly) NSDictionary *dict;

@property (nonatomic, strong, readonly) NSString *title;
@property (nonatomic, strong, readonly) NSString *author;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *category;

@property (nonatomic, strong, readonly) NSArray<TFToken *> *tokens;

- (instancetype)initWithDict:(NSDictionary *)dict;
- (nullable TFToken *)tokenByPosition:(int)position;

@end

NS_ASSUME_NONNULL_END
