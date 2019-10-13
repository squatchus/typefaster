//
//  ResultsViewController.h
//  type.trainer
//
//  Created by Squatch on 29.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

@import UIKit;

#import "TFResultsVM.h"

@interface TFResultsVC : UIViewController

@property (nonatomic, copy) void (^onViewWillAppear)(void);
@property (nonatomic, copy) void (^onSharePressed)(NSString *text);
@property (nonatomic, copy) void (^onContinuePressed)(void);
@property (nonatomic, copy) void (^onSettingsPressed)(void);
@property (nonatomic, copy) void (^onRatePressed)(void);

- (void)updateWithViewModel:(TFResultsVM *)viewModel;
- (void)reloadViewModel;

@end
