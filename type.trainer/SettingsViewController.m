//
//  SettingsViewController.m
//  type.trainer
//
//  Created by Squatch on 05.07.15.
//  Copyright (c) 2015 Suricatum. All rights reserved.
//

#import "SettingsViewController.h"
#import "UIColor+HexColor.h"

@interface SettingsViewController ()

- (IBAction)onSwitchValueChanged:(UISwitch *)sender;
- (IBAction)onCategoryButtonPressed:(UIButton *)sender;


@property (weak, nonatomic) IBOutlet UISwitch *keyboardSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *notificationSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *canMistakeSwitch;
@property (weak, nonatomic) IBOutlet UIButton *categoryClassicButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryQuotesButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryHokkuButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryCookiesButton;
@end



@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    for (UIView *subview in self.view.subviews) {
        if ([subview isKindOfClass:[UIButton class]])
            subview.layer.cornerRadius = subview.frame.size.height/2.0;
        if ([subview isKindOfClass:[UISwitch class]]) {
            UISwitch *switcher = (UISwitch *)subview;
            switcher.onTintColor = [UIColor colorWithHexString:@"c55c77"];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)onSwitchValueChanged:(UISwitch *)sender {
    NSLog(@"onSwitchValueChanged");
}

- (IBAction)onCategoryButtonPressed:(UIButton *)sender {
    NSLog(@"onCategoryButtonPressed");
    sender.selected = !sender.selected;
    if (sender.selected)
        sender.backgroundColor = [UIColor colorWithHexString:@"a54466"];
    else
        sender.backgroundColor = [UIColor colorWithHexString:@"c1c1c1"];
}

@end
