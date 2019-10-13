//
//  MenuViewController.h
//  type.trainer
//
//  Created by Squatch on 27.06.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

@import UIKit;

#import "TFMenuVM.h"

@interface TFMenuVC : UIViewController

@property (nonatomic, copy) void (^onViewWillAppear)(void);
@property (nonatomic, copy) void (^onLeaderboardPressed)(void);
@property (nonatomic, copy) void (^onPlayPressed)(void);
@property (nonatomic, copy) void (^onRatePressed)(void);
@property (nonatomic, copy) void (^onSetttingsPressed)(void);

- (void)updateWithViewModel:(TFMenuVM *)viewModel;
- (void)reloadViewModel;

@end
