//
//  TFShareView.h
//  type.trainer
//
//  Created by Squatch on 09.07.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TFShareView : UIView

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

- (void)updateWithText:(NSString *)text author:(NSString *)author andSpeed:(int)speed;
- (UIImage *)renderImage;

@end
