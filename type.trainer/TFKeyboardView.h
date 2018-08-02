//
//  TFKeyboardView.h
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

// iPhone Keyboard Frames (Portrait)
//
// 4/5  - 320 x 216
// 6    - 375 x 216
// 6+   - 414 x 226

#import <UIKit/UIKit.h>

@protocol TFKeyboardDelegate <NSObject>

- (void)onKeyTapped:(NSString *)keyString;

@end

@interface TFKeyboardView : UIView <UIInputViewAudioFeedback>

@property (weak, nonatomic) id<TFKeyboardDelegate> delegate;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundView;
@property (weak, nonatomic) IBOutlet UIButton *backspaceButton;
@property (weak, nonatomic) IBOutlet UIButton *shiftButton;
@property (weak, nonatomic) IBOutlet UIButton *spaceButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;
@property (weak, nonatomic) IBOutlet UIButton *switchButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *letterHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keysTopMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keysLeftMarginConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *keysRightMarginConstraint;

- (void)playClickSound;
- (void)showOnlyKeysWithCharactersInString:(NSString *)string;

@end