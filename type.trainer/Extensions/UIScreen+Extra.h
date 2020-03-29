//
//  UIScreen+Extra.h
//  type.trainer
//
//  Created by Sergey Mazulev on 29.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIScreen (Extra)

+ (UIFont *)textFontForDevice;
+ (CGFloat)verticalMarginForDevice;

@end

NS_ASSUME_NONNULL_END
