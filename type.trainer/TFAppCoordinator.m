//
//  TFAppCoordinator.m
//  type.trainer
//
//  Created by Sergey Mazulev on 09.10.2019.
//  Copyright © 2019 Suricatum. All rights reserved.
//

#import "TFAppCoordinator.h"

#import "type_trainer-Swift.h"
#import "TFSessionResult.h"

@interface TFAppCoordinator()

@property (nonatomic, weak) UINavigationController *rootNC;

@end

@implementation TFAppCoordinator

- (instancetype)init
{
    if (self = [super init])
    {
        NSString *levelsPath = [NSBundle.mainBundle pathForResource:@"Levels" ofType:@"plist"];
        _levelProvider = [[LevelProvider alloc] initWithLevelsPath:levelsPath];
        _resultsProvider = [[ResultProvider alloc] initWithUserDefaults:NSUserDefaults.standardUserDefaults];
        _sounds = [SoundService new];
        _settings = [[SettingsVM alloc] initWithUserDefaults:NSUserDefaults.standardUserDefaults];
        _reminder = [ReminderService new];
        
        __weak typeof(self) weakSelf = self;
        _leaderboards = [LeaderboardService new];
        _leaderboards.onScoreReceived = ^(NSInteger score) {
            [weakSelf.resultsProvider saveWithScore:score];
            [weakSelf reloadBestScoreIfNeeded];
        };
        [_leaderboards authenticateLocalPlayer];
    }
    return self;
}

- (void)start:(UINavigationController *)rootNC
{
    _rootNC = rootNC;
    [self showMenu];
}

- (void)showMenu
{
    MenuVM *menuVM = [[MenuVM alloc] initWithResultProvider:self.resultsProvider];
    MenuVC *menuVC = [[MenuVC alloc] initWithViewModel:menuVM];
    __weak typeof(self) weakSelf = self;
    menuVC.onLeaderboardPressed = ^{
        [self.sounds play:SoundButtonClick];
        if ([self.leaderboards canShowLeaderboard]) {
            [weakSelf.rootNC presentViewController:self.leaderboards.controller animated:YES completion:nil];
        } else {
            [UIAlertController showLoginToGameCenterAlert];
        }
    };
    menuVC.onPlayPressed = ^{
        [self.sounds play:SoundButtonClick];
        [self showGame];
    };
    menuVC.onRatePressed = ^{
        [self.sounds play:SoundButtonClick];
        [self rateApp];
    };
    menuVC.onSetttingsPressed = ^{
        [self.sounds play:SoundButtonClick];
        [self showSettings];
    };
    [self.rootNC pushViewController:menuVC animated:NO];
}

- (void)showGame
{
    TypingVC *typingVC = [TypingVC new];
    __weak typeof(typingVC) weakVC = typingVC;
    typingVC.onViewWillAppear = ^{
        TFLevel *nextLevel = [self.levelProvider nextLevelFor:self.settings];
        weakVC.viewModel = [[TypingVM alloc] initWithLevel:nextLevel strictTyping:self.settings.defaults.strictTyping];
    };
    typingVC.onDonePressed = ^{
        [self.sounds play:SoundButtonClick];
    };
    typingVC.onMistake = ^{
        [self.sounds play:SoundMistake];
    };
    typingVC.onLevelCompleted = ^(TypingVM *viewModel) {
        ResultEvent event = [self.resultsProvider saveWithResult:viewModel.result];
        if (event == ResultEventNewRank) {
            [self.sounds play:SoundNewRank];
            [self.leaderboards reportWithScore:viewModel.result.signsPerMin];
        } else if (event == ResultEventNewRecord) {
            [self.sounds play:SoundNewRecord];
            [self.leaderboards reportWithScore:viewModel.result.signsPerMin];
        }
        [self showRemindMeAlertIfNeeded];
        
        ResultsVM *resultsVM = [[ResultsVM alloc] initWithLevel:viewModel.level result:viewModel.result event:event provider:self.resultsProvider];
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
            [self.reminder enableReminders];
        else
            [self.reminder disableReminders];
    };
    settingsVC.onCategorySettingChanged = ^{
        [self.sounds play:SoundButtonClick];
    };
    settingsVC.onDonePressed = ^{
        [self.sounds play:SoundButtonClick];
        [weakSettingsVC dismissViewControllerAnimated:YES completion:nil];
    };
    [self.rootNC.topViewController presentViewController:settingsVC animated:YES completion:nil];
}

- (void)showResultsWithViewModel:(ResultsVM *)viewModel;
{
    ResultsVC *resultsVC = [[ResultsVC alloc] initWithViewModel:viewModel];
    __weak typeof(resultsVC) weakResultsVC = resultsVC;
    resultsVC.onSharePressed = ^(NSString *text) {
        [self.sounds play:SoundButtonClick];
        [self shareText:text];
    };
    resultsVC.onContinuePressed = ^{
        [self.sounds play:SoundButtonClick];
        [weakResultsVC.navigationController popViewControllerAnimated:YES];
    };
    resultsVC.onSettingsPressed = ^{
        [self.sounds play:SoundButtonClick];
        [self showSettings];
    };
    resultsVC.onRatePressed = ^{
        [self.sounds play:SoundButtonClick];
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
    else if ([topVC isKindOfClass:ResultsVC.class])
    {
        ResultsVC *resultsVC = (ResultsVC *)topVC;
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
                [self.reminder enableReminders];
            }
            else
            {
                self.settings.defaults.notifications = NO;
                [self.reminder disableReminders];
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

@end
