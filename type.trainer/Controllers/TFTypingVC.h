//
//  ViewController.h
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

@import UIKit;

#import "TFTypingVM.h"

@interface TFTypingVC : UIViewController

@property (nonatomic, copy) void (^onViewWillAppear)(void);
@property (nonatomic, copy) void (^onMistake)(void);
@property (nonatomic, copy) void (^onDonePressed)(void);
@property (nonatomic, copy) void (^onLevelCompleted)(TFTypingVM *viewModel);

- (void)updateWithViewModel:(TFTypingVM *)viewModel;

@end

