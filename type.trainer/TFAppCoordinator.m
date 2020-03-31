//
//  TFAppCoordinator.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFAppCoordinator.h"

#import "type_trainer-Swift.h"

#import "UIStoryboard+TFControllers.h"
#import "UIAlertController+Alerts.h"

@implementation TFAppCoordinator

- (instancetype)init
{
    if (self = [super init])
    {
        NSString *levelsPath = [NSBundle.mainBundle pathForResource:@"Levels" ofType:@"plist"];
        _levelProvider = [[LevelProvider alloc] initWithLevelsPath:levelsPath];
        _resultsProvider = [TFResultProvider new];
        _sounds = [TFSoundService new];
        _settings = [[SettingsVM alloc] initWithUserDefaults:NSUserDefaults.standardUserDefaults];
        _reminder = [TFNotificationService new];
        
        __weak typeof(self) weakSelf = self;
        _leaderboards = [TFLeaderboardService new];
        _leaderboards.onScoreReceived = ^(int score) {
            [weakSelf.resultsProvider saveScore:score];
            [weakSelf reloadBestScoreIfNeeded];
        };
        [_leaderboards authenticateLocalPlayer];
    }
    return self;
}

- (void)start
{
    [self showMenu];
}

- (void)showMenu
{
    MenuVM *menuVM = [[MenuVM alloc] initWithResultProvider:self.resultsProvider];
    MenuVC *menuVC = [[MenuVC alloc] initWithViewModel:menuVM];
    menuVC.onLeaderboardPressed = ^{
        [self.sounds playButtonClickSound];
        if ([self.leaderboards canShowLeaderboard]) {
            [self.leaderboards showLeaderboard];
        } else {
            [UIAlertController showLoginToGameCenterAlert];
        }
    };
    menuVC.onPlayPressed = ^{
        [self.sounds playButtonClickSound];
        [self showGame];
    };
    menuVC.onRatePressed = ^{
        [self.sounds playButtonClickSound];
        [self rateApp];
    };
    menuVC.onSetttingsPressed = ^{
        [self.sounds playButtonClickSound];
        [self showSettings];
    };
    [self.rootNC pushViewController:menuVC animated:NO];
}

- (void)showGame
{
    TFTypingVC *typingVC = UIStoryboard.typingVC;
    __weak typeof(typingVC) weakTypingVC = typingVC;
    typingVC.onViewWillAppear = ^{
        TFLevel *nextLevel = [self.levelProvider nextLevelFor:self.settings];
        TFTypingVM *typingVM = [[TFTypingVM alloc] initWithLevel:nextLevel strictTyping:self.settings.defaults.strictTyping];
        [weakTypingVC updateWithViewModel:typingVM];
    };
    typingVC.onDonePressed = ^{
        [self.sounds playButtonClickSound];
        [weakTypingVC.navigationController popViewControllerAnimated:YES];
    };
    typingVC.onMistake = ^{
        [self.sounds playErrorSound];
    };
    typingVC.onLevelCompleted = ^(TFTypingVM *viewModel) {
        TFResultEvent event = [self.resultsProvider saveResult:viewModel.result];
        if (event == TFResultEventNewRank) {
            [self.sounds playNewRankSound];
            [self.leaderboards reportScore:viewModel.result.signsPerMin];
        } else if (event == TFResultEventNewRecord) {
            [self.sounds playNewRecordSound];
            [self.leaderboards reportScore:viewModel.result.signsPerMin];
        }
        [self showRemindMeAlertIfNeeded];
        
        TFResultsVM *resultsVM = [[TFResultsVM alloc] initWithLevel:viewModel.level result:viewModel.result event:event provider:self.resultsProvider];
        [self showResultsWithViewModel:resultsVM];
    };
    [self.rootNC pushViewController:typingVC animated:NO];
}

- (void)showSettings
{
    SettingsVC *settingsVC = [[SettingsVC alloc] initWithViewModel:self.settings];
    __weak typeof(settingsVC) weakSettingsVC = settingsVC;
    settingsVC.onNotificationsSettingChanged = ^(BOOL enabled) {
        if (enabled)
            [self.reminder enableNotifications];
        else
            [self.reminder disableNotifications];
    };
    settingsVC.onCategorySettingChanged = ^{
        [self.sounds playButtonClickSound];
    };
    settingsVC.onDonePressed = ^{
        [self.sounds playButtonClickSound];
        [weakSettingsVC dismissViewControllerAnimated:YES completion:nil];
    };
    [self.rootNC.topViewController presentViewController:settingsVC animated:YES completion:nil];
}

- (void)showResultsWithViewModel:(TFResultsVM *)viewModel;
{
    TFResultsVC *resultsVC = UIStoryboard.resultsVC;
    __weak typeof(resultsVC) weakResultsVC = resultsVC;
    resultsVC.onViewWillAppear = ^{
        [weakResultsVC updateWithViewModel:viewModel];
    };
    resultsVC.onSharePressed = ^(NSString *text) {
        [self.sounds playButtonClickSound];
        [self shareText:text];
    };
    resultsVC.onContinuePressed = ^{
        [self.sounds playButtonClickSound];
        [weakResultsVC.navigationController popViewControllerAnimated:YES];
    };
    resultsVC.onSettingsPressed = ^{
        [self.sounds playButtonClickSound];
        [self showSettings];
    };
    resultsVC.onRatePressed = ^{
        [self.sounds playButtonClickSound];
        [self rateApp];
    };
    [self.rootNC pushViewController:resultsVC animated:YES];
}

#pragma mark - Helpers

- (void)reloadBestScoreIfNeeded
{
    UIViewController *topVC = self.rootNC.topViewController;
    if ([topVC isKindOfClass:MenuVC.class])
    {
        MenuVC *menuVC = (MenuVC *)topVC;
        [menuVC reloadViewModel];
    }
    else if ([topVC isKindOfClass:TFResultsVC.class])
    {
        TFResultsVC *resultsVC = (TFResultsVC *)topVC;
        [resultsVC reloadViewModel];
    }
}

- (void)showRemindMeAlertIfNeeded
{
    if (self.resultsProvider.results.count == 3 && !self.settings.defaults.notifications)
    {
        [UIAlertController showReminMeAlertWithHandler:^(BOOL remind) {
            if (remind)
            {
                self.settings.defaults.notifications = YES;
                [self.reminder enableNotifications];
            }
            else
            {
                self.settings.defaults.notifications = NO;
                [self.reminder disableNotifications];
            }
        }];
    }
}

- (void)shareText:(NSString *)text
{
    NSString *urlString = @"https://apps.apple.com/app/id1013588476";
    text = [text stringByAppendingFormat:@"\n\n%@", urlString];
    UIActivityViewController *controller = [[UIActivityViewController alloc] initWithActivityItems:@[text] applicationActivities:nil];
    controller.excludedActivityTypes = @[UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll, UIActivityTypeAddToReadingList, UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo, UIActivityTypeAirDrop];
    [self.rootNC presentViewController:controller animated:YES completion:nil];
}

- (void)rateApp
{
    NSURL *url = [NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id1013588476"];
    [UIApplication.sharedApplication openURL:url options:@{} completionHandler:nil];
}

- (UINavigationController *)rootNC
{
    return (UINavigationController *) UIApplication.sharedApplication.delegate.window.rootViewController;
}

@end
