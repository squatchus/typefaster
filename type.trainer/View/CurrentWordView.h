//
//  CurrentWordView.h
//  type.trainer
//
//  Created by Sergey Mazulev on 28.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CurrentWordView : UIView

@property (weak, nonatomic) IBOutlet UIView *shift;
@property (weak, nonatomic) IBOutlet UIView *backspace;
@property (weak, nonatomic) IBOutlet UILabel *label;

@end

NS_ASSUME_NONNULL_END
