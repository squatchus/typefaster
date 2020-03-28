//
//  UINib+TFViews.h
//  type.trainer
//
//  Created by Sergey Mazulev on 28.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CurrentWordView.h"

NS_ASSUME_NONNULL_BEGIN

@interface UINib (TFViews)

+ (CurrentWordView *)currentWordView;

@end

NS_ASSUME_NONNULL_END
