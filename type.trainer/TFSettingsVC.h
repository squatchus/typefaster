//
//  SettingsViewController.h
//  type.trainer
//
//  Created by Squatch on 05.07.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

@import UIKit;

#import "TFSettingsVM.h"

@interface TFSettingsVC : UIViewController

@property (nonatomic, copy) void (^onViewWillAppear)(void);
@property (nonatomic, copy) void (^onNotificationsSettingChanged)(BOOL enabled);
@property (nonatomic, copy) void (^onCategorySettingChanged)(void);
@property (nonatomic, copy) void (^onDonePressed)(void);

- (void)updateWithViewModel:(TFSettingsVM *)viewModel;

@end
