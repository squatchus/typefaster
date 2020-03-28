//
//  UINib+TFViews.m
//  type.trainer
//
//  Created by Sergey Mazulev on 28.03.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

#import "UINib+TFViews.h"

@implementation UINib (TFViews)

+ (CurrentWordView *)currentWordView
{
    CurrentWordView *view = [NSBundle.mainBundle loadNibNamed:@"CurrentWordView" owner:self options:nil].firstObject;
    view.shift.layer.cornerRadius = 4;
    view.backspace.layer.cornerRadius = 4;
    return view;
}

@end
