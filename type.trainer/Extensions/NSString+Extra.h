//
//  NSString+Extra.h
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Extra)

- (BOOL)isUppercaseAtIndex:(NSUInteger)index;
- (BOOL)newLineAtIndex:(NSUInteger)index;
- (NSString *)trimmedSpacesAndNewlines;

@end

NS_ASSUME_NONNULL_END
