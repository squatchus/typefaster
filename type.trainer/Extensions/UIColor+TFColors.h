//
//  UIColor+TFColors.h
//  type.trainer
//
//  Created by Sergey Mazulev on 12.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

@import UIKit;

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (TFColors)

+ (UIColor *)tf_red;
+ (UIColor *)tf_green;
+ (UIColor *)tf_background_red;
+ (UIColor *)tf_dark;
+ (UIColor *)tf_light;

// match colors from assets
+ (UIColor *)tf_background;
+ (UIColor *)tf_gray_button;
+ (UIColor *)tf_purple_button;
+ (UIColor *)tf_gray_text;
+ (UIColor *)tf_dark_text;
+ (UIColor *)tf_purple_text;



@end

NS_ASSUME_NONNULL_END
