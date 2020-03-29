//
//  TFTextView.h
//  type.trainer
//
//  Created by Sergey Mazulev on 29.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TFTypingVM.h"

NS_ASSUME_NONNULL_BEGIN

@interface TFTextView : UITextView

@property (weak, nonatomic) TFTypingVM *viewModel;

@end

NS_ASSUME_NONNULL_END
