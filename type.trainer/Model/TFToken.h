//
//  TFToken.h
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TFToken : NSObject

@property (nonatomic, strong) NSString *string;
@property int startIndex;
@property int endIndex;

- (id)initWithString:(NSString *)string startIndex:(int)start endIndex:(int)end;

@end

NS_ASSUME_NONNULL_END
